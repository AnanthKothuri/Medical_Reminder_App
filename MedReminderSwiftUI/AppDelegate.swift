//
//  AppDelegate.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/5/22.
//

import UIKit
import AWSCognitoIdentityProvider
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // creating user pools with Cognito
        let configuration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: nil)
        let poolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: "53lpddp7v8o8ttahigfd110k2j",
        clientSecret: nil, poolId: "us-east-1_YmQkRIc29")
        AWSCognitoIdentityUserPool.register(with: configuration, userPoolConfiguration: poolConfiguration, forKey: "users")
        
        return true
    }
    
}
