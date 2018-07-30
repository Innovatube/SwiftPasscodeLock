import Foundation

struct RemovePasscodeState: PasscodeLockStateType {

    let title: String = ""
    var description: String = ""
    let isCancellableAction: Bool
    var isTouchIDAllowed = true
    var isAllowReset: Bool = true

    private var inccorectPasscodeAttempts = 0
    private var isNotificationSent = false

    init(allowCancellation: Bool = false) {

        isCancellableAction = allowCancellation
    }

    func acceptPasscode(_ passcode: [String], fromLock lock: PasscodeLockType) {
        lock.repository.deletePasscode()
    }
}
