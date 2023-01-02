import json
import boto3
import re

client = boto3.client(service_name='comprehendmedical', region_name='us-east-1')

def lambda_handler(event, context):
    note = event["queryStringParameters"]["note"]
    result = client.detect_entities(Text=note)["Entities"]
    medDict = {}
    createDict(medDict, result, note)
    
    return {
        'statusCode': 200,
        'body': json.dumps(medDict)
    }
    
    
# filters the result to only the info needed
def createDict(med, result, note):
    for entity in result:
        
        # date1 or date2 (changed to start/end date in swift)
        if entity["Type"] == "DATE":
            if "medDate1" in med:
                med["medDate2"] = entity["Text"]
            else:
                med["medDate1"] = entity["Text"]
    
        if entity["Category"] == "MEDICATION":
            medName = entity["Text"]
            
            # adding attributes for the medication
            med["medName"] = medName
            med["medNote"] = note
            
            for att in entity["Attributes"]:
                # dosage
                if att["Type"] == "DOSAGE":
                    string = att["Text"]
                    med["medDosageString"] = string
                    dos, unit = getDosageAndUnit(string)
                    
                    med["medDosage"] = dos
                    med["medDosageUnit"] = unit
                    
                # frequency
                if att["Type"] == "FREQUENCY":
                    med["medFrequencyString"] = att["Text"]
                    med["medFrequency"] = frequencyToSeconds(att["Text"])
                        
                        
# changes a string frequency into the number of seconds between doses
def frequencyToSeconds(frequency):
    frequency = frequency.lower()
    time = 1.0
    interval = 86400 # default as a day
    intervalDict = {
        "second": 1,
        "seconds": 1,
        "sec": 1,
        "secs": 1,
        "minute": 60,
        "minutes": 60,
        "min": 60,
        "mins": 60,
        "hour": 3600,
        "hourly": 3600,
        "hr": 3600,
        "hrs": 3600,
        "day": 86400,
        "daily": 86400,
        "week": 604800,
        "weekly": 604800,
        "wk": 604800,
        "wks": 604800,
        "month": 2592000,
        "monthly": 2592000,
        "year": 31536000,
        "yearly": 31536000,
        "yr": 31536000,
        "yrs": 31536000
    }
    timeDict = {
        "once": 1,
        "twice": 2
    }
    
    # getting time
    s = frequency.split()
    first = s[0]
    if first in timeDict:
        time = timeDict[first]
    else:
        ndx = 0
        periodCounter = 0
        while ndx < len(first):
            
            if first[ndx:ndx + 1] == ".":
                if periodCounter >= 1 or ndx == 0:
                    break
                else:
                    periodCounter += 1
                    
            else:
                try: 
                    cur = float(first[ndx:ndx + 1])
                except:
                    break
                    
            ndx += 1
        
        num = first[:ndx]
        try:
            time = float(num)
        except:
            time = 1.0
            
    # getting interval
    for i in intervalDict: 
        for word in s:
            
            if i in word:
                ndx = s.index(word)
                if ndx == 0:
                    interval = intervalDict[i]
                else:
                    before = s[ndx - 1]
                    try:
                        interval = float(before) * intervalDict[i]
                    except:
                        interval = intervalDict[i]
                break
    
    # calculating seconds for frequency
    return round(interval / time)
        
# processes the input string into a dosage and unit
def getDosageAndUnit(string):
    string = string.strip()
    dos = 0.0
    unit = ""
    s = string.split()
    
    # "num unit" format (EX: 2 mg)
    # Case 1
    if len(s) == 2:
        try:
            dos = float(s[0])
        except:
            dos = 0.0
        unit = s[1]
        
    # "numUnit" format (EX: 2mg)
    # Case 2 and 3
    else:
        ndx = 0
        periodCounter = 0
        
        while ndx < len(string):
            
            if string[ndx:ndx + 1] == ".":
                if periodCounter >= 1 or ndx == 0:
                    break
                else:
                    periodCounter += 1
                    
            else:
                try: 
                    cur = float(string[ndx:ndx + 1])
                except:
                    break
                    
            ndx += 1
            
        try:
            dos = float(string[0:ndx])
        except:
            dos = 0.0
        unit = string[ndx:]
        
    return dos, unit
