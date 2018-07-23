//
//  EnterPasscodeState.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

public let PasscodeLockIncorrectPasscodeNotification = Notification.Name("passcode.lock.incorrect.passcode.notification")

struct EnterPasscodeState: PasscodeLockStateType {
    
    let title: String
    var description: String
    let isCancellableAction: Bool
    var isTouchIDAllowed = true
    
    private var inccorectPasscodeAttempts = 0
    private var isNotificationSent = false
    
    init(allowCancellation: Bool = false) {
        
        isCancellableAction = allowCancellation
        title = localizedStringFor("PasscodeLockEnterTitle", comment: "Enter passcode title")
        description = localizedStringFor("PasscodeLockEnterDescription", comment: "Enter passcode description")
    }
    
    mutating func acceptPasscode(_ passcode: [String], fromLock lock: PasscodeLockType) {
        
        guard let currentPasscode = lock.repository.passcode else {
            return
        }
        
        if passcode == currentPasscode {
            
            lock.delegate?.passcodeLockDidSucceed(lock)
            
        } else {
            
            inccorectPasscodeAttempts += 1
            
            if inccorectPasscodeAttempts >= lock.configuration.maximumInccorectPasscodeAttempts {
                
                postNotification()
            }
            lock.delegate?.passcodeLockDidFail(lock)
        }
    }
    
    fileprivate mutating func postNotification() {

        guard !isNotificationSent else { return }

        NotificationCenter.default.post(name: PasscodeLockIncorrectPasscodeNotification, object: nil)

        isNotificationSent = true
    }
}
