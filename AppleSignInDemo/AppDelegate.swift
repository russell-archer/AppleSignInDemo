//
//  AppDelegate.swift
//  AppleSignInDemo
//
//  Created by Russell Archer on 27/09/2019.
//  Copyright © 2019 Russell Archer. All rights reserved.
//

import UIKit
import AuthenticationServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Get saved user identifier (e.g. from keychain or database). Using hard-coded example for demo
        let userIdentifier = "001664.3aa027ba9878489ca624ee2020936ff8.1946"

        let provider = ASAuthorizationAppleIDProvider()
        
        // See if we have an existing valid crential for the user
        provider.getCredentialState(forUserID: userIdentifier) { (credentialState, error) in
            switch credentialState {
                case .authorized:
                    print("Apple ID credential is valid and authorized")
                    break
                case .revoked:
                    print("Apple ID credential has been revoked")
                    break
                case .notFound:
                    print("Apple ID credential not found - need to re-authenticate")
                    break
                default:
                    break
            }
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
