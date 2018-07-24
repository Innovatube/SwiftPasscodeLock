//
//  ResetPasscodeState.swift
//  PasscodeLock
//
//  Created by Tran Anh on 7/23/18.
//  Copyright © 2018 Yanko Dimitrov. All rights reserved.
//

import Foundation
struct ResetPasscodeState: PasscodeLockStateType {
    var isAllowReset: Bool = true

    var isCancellableAction: Bool = true
    
    var isTouchIDAllowed: Bool = false

    let title: String
    let description: String

    init() {

        title = localizedStringFor("PasscodeLockEnterTitle", comment: "Enter passcode title")
        description = localizedStringFor("PasscodeLockEnterDescription", comment: "Enter passcode description")
    }

    func acceptPasscode(_ passcode: [String], fromLock lock: PasscodeLockType) {

        let nextState = ResetPasscodeState()
        lock.repository.resetPasscode()
        lock.changeStateTo(nextState)

    }

}
