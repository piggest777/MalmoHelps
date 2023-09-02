//
//  RemoteConfig.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2023-09-01.
//

import Foundation
import Firebase
import FirebaseRemoteConfig
import FirebaseRemoteConfigSwift

class RemoteConfigManager {
    
    static let shared = RemoteConfigManager()
    
    private var remoteConfig: RemoteConfig
    
    private init() {
        remoteConfig = RemoteConfig.remoteConfig()
        
        let settings = RemoteConfigSettings()
        
        // This allows for frequent refreshes during development
        #if DEBUG
        settings.minimumFetchInterval = 0
        #else
        settings.minimumFetchInterval = 3600 // At least 1 hour for production
        #endif
        
        remoteConfig.configSettings = settings
        
        setDefaults()
    }
    
    func setDefaults() {
        // Set default values for your config
        let defaultValues = [
            "reviewMode": false as NSObject
        ]
        remoteConfig.setDefaults(defaultValues)
    }
    
    func fetchRemoteValues(completion: @escaping () -> Void) {
        remoteConfig.fetch(completionHandler: { (status, error) in
            if status == .success {
                self.remoteConfig.activate { (changed, error) in
                    completion()
                }
            } else {
                // Handle the error
                completion()
            }
        })
    }
    
    func getString(forKey key: String) -> String {
        return remoteConfig[key].stringValue ?? ""
    }
    
    func getBool(forKey key: String) -> Bool {
        return remoteConfig[key].boolValue
    }
    
}
