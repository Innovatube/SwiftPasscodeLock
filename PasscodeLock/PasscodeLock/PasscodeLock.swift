//
//  PasscodeLock.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation
import LocalAuthentication

public class PasscodeLock: PasscodeLockType {
    public weak var delegate: PasscodeLockTypeDelegate?
    public let configuration: PasscodeLockConfigurationType
    
    public var repository: PasscodeRepositoryType {
        return configuration.repository
    }
    
    public var state: PasscodeLockStateType {
        return lockState
    }
    
    public var isTouchIDAllowed: Bool {
        return isTouchIDEnabled() && configuration.isTouchIDAllowed && lockState.isTouchIDAllowed
    }

    public var isAllowReset: Bool {
        return configuration.isAllowReset && lockState.isAllowReset
    }

    
    private var lockState: PasscodeLockStateType
    private lazy var passcode = [String]()
    
    public init(state: PasscodeLockStateType, configuration: PasscodeLockConfigurationType) {
        
        precondition(configuration.passcodeLength > 0, "Passcode length sould be greather than zero.")
        
        self.lockState = state
        self.configuration = configuration
    }
    
    open func addSign(_ sign: String) {

        passcode.append(sign)
        delegate?.passcodeLock(self, addedSignAtIndex: passcode.count - 1)

        if passcode.count >= configuration.passcodeLength {

            // handles "requires exclusive access" error at Swift 4
            var lockStateCopy = lockState
            lockStateCopy.acceptPasscode(passcode, fromLock: self)
            passcode.removeAll(keepingCapacity: true)
        }
    }

    public func removeSign() {
        
        guard passcode.count > 0 else { return }
        
        passcode.removeLast()
        delegate?.passcodeLock(self, removedSignAtIndex: passcode.count)
    }
    
    public func changeStateTo(_ state: PasscodeLockStateType) {
        
        lockState = state
        delegate?.passcodeLockDidChangeState(self)
    }
    
    public func authenticateWithBiometrics() {
        
//        guard isTouchIDAllowed else { return }
        
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "ロックを解除"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [unowned self] (success, authenticationError) in
                DispatchQueue.main.async {
                    if success {
                        self.handleTouchIDResult(success)
                    } else {
                        // error
                    }
                }
            }
        } else {
            // no biometry
        }

    }
    
    fileprivate func handleTouchIDResult(_ success: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard success, let strongSelf = self else { return }
            strongSelf.delegate?.passcodeLockDidSucceed(strongSelf)
        }
    }

    fileprivate func isTouchIDEnabled() -> Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }}
