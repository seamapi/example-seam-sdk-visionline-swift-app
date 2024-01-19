//
//  LoginViewModel.swift
//  sample-swift-app
//
//  Created by Severin Ibarluzea on 1/7/24.
//

import SwiftUI
import SeamSDK

class LoginViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var isLoadingCredentials = false
    @Published var areCredentialsLoaded = false
    @Published var isScanning = false
    @Published var doorUnlockedSuccess = false
    @Published var doorUnlockedFailure = false

    @Published var loginError: String?
    @Published var entrances: [String]?

    var seam: SeamApi?
    var isEntranceScanningAvailable: Bool { areCredentialsLoaded }
    var canUnlockNearest: Bool { entrances != nil && entrances!.count > 0 }
    
    
    func login(username: String, password: String) {
        loginError = nil
        if (!password.contains("seam_cst")) {
            loginError = "The password wasn't a Client Session Token, for this demo you have to use a client session token"
            return
        }
        
        seam = SeamApi(authToken: password)
        isLoggedIn = true
        startLoadingCredentials()
    }
    
    func startLoadingCredentials() {
        Task {
            isLoadingCredentials = true
            let _ = await seam?.mobileController.launch(providers: ["assa_abloy"])
            areCredentialsLoaded = true
        }
    }
    
    func startUnlockByTapping() {
        Task {
            await seam?.mobileController.startUnlockByTapping()
            isScanning = true
        }
    }
    
    func stopUnlockByTapping() {
        Task {  
            await seam?.mobileController.stopUnlockByTapping()
            isScanning = false
        }
    }
    
    func listCredentials() {
        Task {
            let credentialsResult = await seam?.mobileController.listCredentials()
            
            switch(credentialsResult!) {
            case .success(let credentials):
                print(credentials)
            case .failure(let error):
                print("Failed to list credentials: \(error)")
            }
        }
    }
    
    func health() {
        let seam = SeamApi()
        Task {
            print(await seam.health())
        }
    }
}
