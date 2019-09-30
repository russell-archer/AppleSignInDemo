//
//  ViewController.swift
//  AppleSignInDemo
//
//  Created by Russell Archer on 27/09/2019.
//  Copyright © 2019 Russell Archer. All rights reserved.
//

import UIKit
import AuthenticationServices

class ViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    
    fileprivate var userIdentifier: String?  // Used to save the id of an authenticated user
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a Sign in with Apple button, set a target for the touchUpInside event and then add it to our stackview
        let signInBtn = ASAuthorizationAppleIDButton()
        signInBtn.frame.size = CGSize(width: 280, height: 60)   // 280 x 60 is the Apple recommended size
        signInBtn.addTarget(self, action: #selector(handleSignInWithApple), for: .touchUpInside)
        stackView.addArrangedSubview(signInBtn)
    }
    
    /// Request an authorization using Sign in with Apple
    @objc func handleSignInWithApple() {
        let request = ASAuthorizationAppleIDProvider().createRequest()  // Create a request object
        request.requestedScopes = [.fullName, .email]  // Configure what info you'd like returned from the user
        
        // Create a controller object that manages the authorization request
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])

        // Set ourselves as the controller's delegate (we must implement ASAuthorizationControllerDelegate protocol)
        authorizationController.delegate = self
        
        // Set ourselves as a delegate so we can tell it which window to attach the sign in window to
        // This means we must implement the ASAuthorizationControllerPresentationContextProviding protocol
        authorizationController.presentationContextProvider = self
        
        // Do the actual authorization request by presenting the sign in window.
        // Authorization succeeds: the controller calls authorizationController(controller:didCompleteWithAuthorization:)
        // Authorization fails: the system calls the authorizationController(controller:didCompleteWithError:)
        authorizationController.performRequests()
    }
    
    @IBAction func performSecureTaskTapped(_ sender: Any) {
        guard userIdentifier != nil else { return }
        
        let provider = ASAuthorizationAppleIDProvider()
        
        // See if there is valid crential for the user.
        // Apple recommends this is done before performing any task that relies on the user being
        // signed-in with an Apple ID. This is because at any time a user can sign out
        provider.getCredentialState(forUserID: userIdentifier!) { (credentialState, error) in
            switch credentialState {
                case .authorized:
                    print("Apple ID credential is valid and authorized! OK to perform secure task :-)")
                    break
                case .revoked: fallthrough
                case .notFound:
                    self.userIdentifier = nil
                    print("Apple ID credential not found. Need to re-authenticate")
                    break
                default: break
            }
        }
    }
}

// MARK: ASAuthorizationControllerDelegate protocol implementation

extension ViewController: ASAuthorizationControllerDelegate {
    
    /// Handles the result of an authorization request
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // Get the credential returned from the authorization
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("Error getting authorization credential")
            return
        }
        
        // Here we just print out the credential returned. In a real app we'd then store the credential details
        // in a database or the keychain. Note that the appleIDCredential.user should be used as a primary key
        // when storing credential details. On subsequent authorization requests for a particular user ONLY
        // appleIDCredential.user is returned, the other credential details (name and email) are NOT returned.
        // This is because Apple assumes (because you've had a successful first sign in by the user) that
        // you've added the user's name and email to your system previously.
        print("Authorized!")
        print(appleIDCredential.user)  // Identifier associated with an authenticated user. Use as Primary Key when storing
        print(appleIDCredential.fullName?.givenName ?? "No name")
        print(appleIDCredential.email ?? "No email")
        
        userIdentifier = appleIDCredential.user  // Save the user id
    }
    
    /// Handle error authorization errors
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Authorization failed: \(error.localizedDescription)")
        userIdentifier = nil
    }
}

// MARK: ASAuthorizationControllerPresentationContextProviding protocol implementation

extension ViewController: ASAuthorizationControllerPresentationContextProviding {

    /// iOS 13 supports multiple windows so tell the authorization controller which window to use
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!  // ASPresentationAnchor is a typealias for UIWindow
    }
}
