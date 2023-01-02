import boto3
import json
import copy

tableName = "MedicalRecordsDBase"
DOCTOR = "D"
PATIENT = "P"

client = boto3.client('dynamodb')

### Main method to handle all requests
def lambda_handler(event, context):
    
    statusCode = 200
    PATH = event["rawPath"]

    if PATH == '/createUser':
        result = json.dumps(createUser(event))
        body = result
        
    elif PATH == '/getUser':
        result = json.dumps(getUser(event))
        body = result
        
    elif PATH == '/deleteUser':
        result = json.dumps(deleteUser(event))
        body = result
        
    elif PATH == '/updateSettings':
        result = json.dumps(updateSettings(event))
        body = result
        
    elif PATH == '/getPatientMedications':
        result = json.dumps(getPatientMedications(event))
        body = result
        
    elif PATH == '/addMedicationToPatient':
        result = json.dumps(addMedicationToPatient(event))
        body = result
        
    elif PATH == '/removeMedicationFromPatient':
        result = json.dumps(removeMedicationFromPatient(event))
        body = result
        
    elif PATH == '/getDoctorPatients':
        result = json.dumps(getDoctorPatients(event))
        body = result
        
    elif PATH == '/addPatientToDoctor':
        result = json.dumps(addPatientToDoctor(event))
        body = result
        
    elif PATH == '/removePatientFromDoctor':
        result = json.dumps(removePatientFromDoctor(event))
        body = result
        
    elif PATH == '/containsID':
        result = json.dumps(containsID(event))
        body = result
        
    elif PATH == '/getAllBasicPatients':
        result = json.dumps(getAllBasicPatients())
        body = result
        
    else:
        statusCode = 400
        body = 'error incorrect path'
  
    response = {
        'statusCode': statusCode,
        'body': body,
        'headers': {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
        },
    }
    
    return response
 
 
 
 
  
 # METHODS ---------------------------------------------------
    

''' 
Creates a new user based on input parameters. All users have a userID, 
userType, firstName, lastName, and email. Doctors also have a list of 
patients as a string of userIDs, each separated by a space. Patients 
have a list of medications. Medications are stored as strings in the 
form with each characteristic (name, dosage, etc.) separated by a space.

Returns: string error or success statement
'''
def createUser(event):
    userType = event['queryStringParameters']['userType']
    userID = event['queryStringParameters']['userID']
    parameters = event['queryStringParameters']
    if 'userType' not in parameters:
        return {"ERROR": "User must have a userType"}
    
    ids = getIds(userType)
    if userID in ids:
        return {"ERROR": "id {} already exists".format(userID)}
        
    ids[userID] = ""
    updateListSuccess = updateIDs(userType, ids)
    
    parameters["settings"] = {
        "doctorCanAddReminders" : True,
        "startTimeLimit" : "9:00",
        "endTimeLimit": "19:00",
        "pauseNotifications": False,
        "remindAtAnyTime": False,
        "voiceReminders": True,
        "sendWeeklyReports": False,
        "reportEmailDestination" : ""
        
    }
    
    dict = reformatDict(parameters)
    dict = dict["M"]
    
    client.put_item(
        TableName=tableName,
        Item=dict
    )

    return {"SUCCESS": 'successfully created user for {} {}'
            .format(parameters['firstName'], parameters['lastName'])

    }


'''
Retrieves a user based on ther userID and userType that calls the method, 
as well as the getUserID and getUserType. Doctors can only access their
own information and their patients' information. Patients can only access 
their own information. 

Returns: an String error if the user cannot access the getUserID, else
a dictionary containing the getUserID information
'''
def getUser(event):
    
    userType = event['queryStringParameters']['userType']
    userID = event['queryStringParameters']['userID']
    getUserType = event['queryStringParameters']['getUserType']
    getUserID = event['queryStringParameters']['getUserID']
    
    ids = getIds(getUserType)
    #return {"ERROR": ids}
    if getUserID not in ids:
        return {"ERROR" : "ID {} doesn't exist, cannot retrive information".format(getUserID)}
    
    if userType == PATIENT:
        if (userType != getUserType or userID != getUserID):
            return {"ERROR": "patient {} can only access their own information.".format(userID) }
    
    elif userType == DOCTOR:
        # Doctor accessing another doctor
        if (userType == getUserType and userID != getUserID):
            return {"ERROR": "doctor cannot access another doctor's information." }
        # Doctor accessing a patient (not themselves)
        if (userType != getUserType and userID != getUserID):
            doctor = client.get_item(
                TableName=tableName,
                Key={
                    'userID': {
                        "S": userID
                    },
                    'userType': {
                        "S": userType
                    }
                }
            )
            doctor = doctor["Item"]
            doctor = unReformatDict(doctor)
            doctorPatients = doctor['patients']
            
            patientPresent = False
            if getUserID in doctorPatients:
                patientPresent = True
            
            if not patientPresent:
                return {"ERROR": "doctor {} cannot access patient {}.".format(userID, getUserID) }

    # getting user (either themselves or one of their patients if they're a doctor)
    data = client.get_item(
        TableName=tableName,
        Key={
            'userID': {
                "S": getUserID
            },
            'userType': {
                "S": getUserType
            }
        }
    )
    
    data = data["Item"]
    data = unReformatDict(data)
    return data
    
def deleteUser(event):
    parameters = event['queryStringParameters']
    userID = parameters['userID']
    getUserID = parameters['getUserID']
    userType = parameters['userType']
    getUserType = parameters['getUserType']
    
    ids = getIds(getUserType)
    #return {"IDS": ids}
    if getUserID not in ids:
        return {"ERROR": "user {} does not exist, cannot delete".format(getUserID)}
    
    if userID != getUserID:
        return {"ERROR": "only user {} can delete user {}".format(getUserID, getUserID)}
    
    client.delete_item(
        TableName=tableName,
        Key={
            'userID': {
                'S': getUserID
            },
            'userType': {
                'S': getUserType
            }
        }
    )
    
    del ids[getUserID]
    updateListSuccess = updateIDs(userType, ids)

    return {"SUCCESS": 'successfully deleted user {}'
            .format(getUserID)
    }
    
def updateSettings(event):
    parameters = event["queryStringParameters"]
    user = getUser(event)
    if "ERROR" in user: 
        return user
    
    for set in parameters:
        if set in user["settings"]:
            if (parameters[set] == "true" or parameters[set] == "false"):
                user["settings"][set] = parameters[set] == "true"
            else:    
                user["settings"][set] = parameters[set]
            
    
    dict = reformatDict(user)
    dict = dict["M"]
    
            
    client.put_item(
        TableName=tableName,
        Item= dict
    )
    
    return dict
    return {"SUCCESS": "successfully updated settings for patient {}"
            .format(parameters["getUserID"])}
    
def getAllBasicPatients():
    ids = getIds(PATIENT)
    
    basicInfo = {}
    for id in ids:
        data = client.get_item(
            TableName=tableName,
            Key={
                'userID': {
                    "S": id
                },
                'userType': {
                    "S": PATIENT
                }
            }
        )
        
        data = data["Item"]
        data = unReformatDict(data)
        if "picture" not in data:
            data["picture"] = ""
        
        basicInfo[id] = {
            'userType': data['userType'],
            'firstName': data['firstName'],
            'lastName': data['lastName'],
            'picture': data['picture']
        }
        
    return basicInfo


    
'''
Retrieves a patients medications. Same access rules apply as getUser().

Returns: an String error if the user cannot access the getUserID, else
a dictionary containing the getUserID medication
'''
def getPatientMedications(event):
    # if the getUserType is DOCTOR, throw an error
    if event["queryStringParameters"]["getUserType"] == DOCTOR:
        return {"ERROR": "getPatientMedications() cannot be called on a Doctor"}
    
    data = getUser(event)
    
    # checking if there was an error
    if "ERROR" in data:
        return data
    
    if 'medications' in data:
        return data['medications']
    else:
        return {}
    
    

'''
Adds a medication to a patients data. Both doctors and patients can add
medications. 

Return: string error or success statement
'''
def addMedicationToPatient(event):
    # if the getUserType is DOCTOR, throw an error
    if event["queryStringParameters"]["getUserType"] == DOCTOR:
        return {"ERROR": "addMedicationToPatient() cannot be called on a Doctor"}
        
    getUserID = event['queryStringParameters']['getUserID']
    data = getUser(event)
    
    # checking if there are errors (as strings)
    if "ERROR" in data:
        return data
        
    if "medications" not in data:
        data["medications"] = {}
    
    medName = event['queryStringParameters']['medName']
    data["medications"][medName] = {}
    
    for key in event['queryStringParameters']:  
        if "med" in key:
            data["medications"][medName][key] = event["queryStringParameters"][key]
    #data["medications"][medName]["medCompletionDates"] = []
        
    data = reformatDict(data)
    data = data["M"]
    #return data
    
    client.put_item(
        TableName=tableName,
        Item= data
    )
    
    return {"SUCCESS": "successfully added medication to patient {}".format(getUserID)}
    
'''
Removes a medication from a patient's data. Both doctors and patients can
remove medications. 

Return: string error or success statement
'''
def removeMedicationFromPatient(event):
    # if the getUserType is DOCTOR, throw an error
    if event["queryStringParameters"]["getUserType"] == DOCTOR:
        return "Error: addMedicationToPatient() cannot be called on a Doctor"
        
    getUserID = event['queryStringParameters']['getUserID']
    removeMed = event['queryStringParameters']['removeMed']
    data = getUser(event)
    
    # checking if there are errors (as strings)
    if "ERROR" in data:
        return data
        
    if 'medications' not in data:
        return {"ERROR": "User {} has no logged medications, cannot delete {}".format(getUserID, removeMed)}
    
    if removeMed in data['medications']:
        del data['medications'][removeMed]
    else:
        return {"ERROR": "User {} does not have {} medication, cannot delete".format(getUserID, removeMed)}
        
    data = reformatDict(data)
    data = data["M"]
    
    client.put_item(
        TableName=tableName,
        Item=data
    )
    
    return {"SUCCESS": "successfully removed medication from patient {}".format(getUserID) }


def getDoctorPatients(event):
    if event["queryStringParameters"]["userType"] == PATIENT:
        return {"ERROR": "patient cannot call getDoctorPatients()"}
    elif event["queryStringParameters"]["getUserType"] == PATIENT:
        return {"ERROR": "getDoctorPatients cannot be called on a patient"}
        
    data = getUser(event)
        
    # checking if there was an error
    if "ERROR" in data:
        return data
        
    # accounting for if the patient account was deleted
    ids = getIds(PATIENT)
    newList = {}
    
    if 'patients' in data:
        for patientID in data['patients']:
            if patientID in ids:
                newList[patientID] = data['patients'][patientID]
        
        # updating patients list in case an old patient was deleted
        if newList != data['patients']:
            data['patients'] = newList
            data = reformatDict(data)
            data = data["M"]
            
            client.put_item(
                TableName=tableName,
                Item=data
            )
        return newList
    else:
        return {}
    
    
def addPatientToDoctor(event):
    if event["queryStringParameters"]["userType"] == PATIENT:
        return {"ERROR": "patient cannot call addPatientToDoctor()"}
    elif event["queryStringParameters"]["getUserType"] == PATIENT:
        return {"ERROR": "addPatientToDoctor() cannot be called on a patient"}
        
    addPatientID = event['queryStringParameters']['addPatientID']
    getUserID = event['queryStringParameters']['addPatientID']
    ids = getIds(PATIENT)
    if addPatientID not in ids:
        return {"ERROR": "ID {} is not linked to a user, cannot add to doctor {}"
                .format(addPatientID, getUserID)}
    
    getUserID = event['queryStringParameters']['getUserID']
    data = getUser(event)
    
    # checking if there are errors (as strings)
    if "ERROR" in data:
        return data
        
    if 'patients' not in data:
        data['patients'] = {}

    data['patients'][addPatientID] = {}
    data = reformatDict(data)
    data = data["M"]
    
    client.put_item(
        TableName=tableName,
        Item=data
    )
    
    return {"SUCCESS":"successfully added patient {} to doctor {}".format(addPatientID, getUserID) }
    

def removePatientFromDoctor(event):
    # if the getUserType is PATIENT, throw an error
    if event["queryStringParameters"]["userType"] == PATIENT:
        return {"Error": "patient cannot call removePatientFromDoctor()"}
    elif event["queryStringParameters"]["getUserType"] == PATIENT:
        return {"Error": "removePatientFromDoctor() cannot be called on a patient"}
        
    removePatientID = event['queryStringParameters']['removePatientID']
    ids = getIds(PATIENT)
    if removePatientID not in ids:
        return {"ERROR": "ID {} is not linked to a user, cannot remove from doctor {}"
                .format(removePatientID, getUserID)}
    
    getUserID = event['queryStringParameters']['getUserID']
    data = getUser(event)
    
    # checking if there are errors (as strings)
    if "ERROR" in data:
        return data

    if 'patients' not in data:
        return {"ERROR": "doctor {} has not patients, cannot remove patient {}"
                .format(getUserID, removePatientID)}
    
    if removePatientID in data['patients']:
        del data['patients'][removePatientID]
    else:
        return {"ERROR": "doctor {} does not have patient {}, cannot delete"
            .format(getUserID, removePatientID)}
    data = reformatDict(data)
    data = data["M"]
    
    client.put_item(
        TableName=tableName,
        Item=data
    )
    
    return {"SUCCESS": "successfully removed patient {} from doctor {}".format(removePatientID, getUserID) }
    
def containsID(event):
    userID = event['queryStringParameters']['userID']
    doctorIDs = getIds(DOCTOR)
    patientIDs = getIds(PATIENT)
    
    if userID in doctorIDs:
        return {"True": "D"}
    elif userID in patientIDs:
        return {"True": "P"}
        
    return {"False": ""}
    



# HELPER METHODS -------------------------------------------

def getIds(userType):
    if userType == DOCTOR:
        key = "DoctorList"
    else: 
        key = "PatientList"
        
    data = client.get_item(
        TableName=tableName,
        Key={
            'userID': {
                "S": "0"
            },
            'userType': {
                "S": key
            }
        }
    )
    data = data["Item"]
    data = unReformatDict(data)
    if userType == DOCTOR:
        ids = data["DoctorIDs"]
    else:
        ids = data["PatientIDs"]
    
    return ids
        
def updateIDs(userType, newIdList):
    if userType == PATIENT:
        key = "PatientList"
        idKey = "PatientIDs"
    else:
        key = "DoctorList"
        idKey = "DoctorIDs"
        
    data = {
        'userID': "0",
        'userType': key,
        idKey : newIdList
    }
    
    data = reformatDict(data)
    data = data["M"]
    
    client.put_item(
        TableName=tableName,
        Item=data
    )
    return "success"
    
def reformatDict(dict) :
    if type(dict) == type(""):
        return { 'S': dict }
        
    elif type(dict) == type(False):
        return { 'BOOL': dict }
        
    elif type(dict) == type([]):
        list = []
        for val in dict:
            list.add(reformatDict(val))
        return { 'L': list }
        
    elif type(dict) == type(0):
        return { 'N': dict }
        
    elif type(dict) == type({}):
        dict2 = {}
        for key in dict:
            dict2[key] = reformatDict(dict[key])
        return { 'M': dict2 }
        
def unReformatDict(dict):
    if type(dict) == type("") or type(dict) == type(0) or type(dict) == type(False):
        return dict
        
    elif type(dict) == type({}):
        dict2 = {}
        for key in dict:
            if key == "S" or key == "L" or key == "M" or key == "N" or key == "BOOL":
                return unReformatDict(dict[key])
            else:
                dict2[key] = unReformatDict(dict[key])
        return dict2
