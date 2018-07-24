//
//  PasscodeLockViewController.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit

public class PasscodeLockViewController: UIViewController, PasscodeLockTypeDelegate {
    
    public enum LockState {
        case EnterPasscode
        case SetPasscode
        case ChangePasscode
        case RemovePasscode
        case ResetPasscode
        
        func getState() -> PasscodeLockStateType {
            
            switch self {
            case .EnterPasscode: return EnterPasscodeState()
            case .SetPasscode: return SetPasscodeState()
            case .ChangePasscode: return ChangePasscodeState()
            case .RemovePasscode: return EnterPasscodeState(allowCancellation: true)
            case .ResetPasscode: return ResetPasscodeState()
            }
        }
    }
    
    @IBOutlet public weak var titleLabel: UILabel?
    @IBOutlet public weak var descriptionLabel: UILabel?
    @IBOutlet public var placeholders: [PasscodeSignPlaceholderView] = [PasscodeSignPlaceholderView]()
    @IBOutlet public weak var cancelButton: UIButton?
    @IBOutlet public weak var deleteSignButton: UIButton?
    @IBOutlet public weak var touchIDButton: UIButton?
    @IBOutlet public weak var placeholdersX: NSLayoutConstraint?

    @IBOutlet weak var oneBtn: PasscodeSignButton!
    @IBOutlet weak var twoBtn: PasscodeSignButton!
    @IBOutlet weak var threeBtn: PasscodeSignButton!
    @IBOutlet weak var fourBtn: PasscodeSignButton!
    @IBOutlet weak var fiveBtn: PasscodeSignButton!
    @IBOutlet weak var sixBtn: PasscodeSignButton!
    @IBOutlet weak var sevenBtn: PasscodeSignButton!
    @IBOutlet weak var eightBtn: PasscodeSignButton!
    @IBOutlet weak var nineBtn: PasscodeSignButton!
    @IBOutlet weak var zeroBtn: PasscodeSignButton!
    @IBOutlet weak var resetBtn: UIButton!

    
    open var successCallback: ((_ lock: PasscodeLockType) -> Void)?
    public var dismissCompletionCallback: (()->Void)?
    public var animateOnDismiss: Bool
    open var notificationCenter: NotificationCenter?

    internal let passcodeConfiguration: PasscodeLockConfigurationType
    internal var passcodeLock: PasscodeLockType
    internal var isPlaceholdersAnimationCompleted = true
    
    private var shouldTryToAuthenticateWithBiometrics = true
    
    // MARK: - Initializers
    
    public init(state: PasscodeLockStateType, configuration: PasscodeLockConfigurationType, animateOnDismiss: Bool = true) {
        
        self.animateOnDismiss = animateOnDismiss
        
        passcodeConfiguration = configuration
        passcodeLock = PasscodeLock(state: state, configuration: configuration)
        
        let nibName = "PasscodeLockView"
        let bundle: Bundle = bundleForResource(name: nibName, ofType: "nib")

        super.init(nibName: nibName, bundle: bundle)
        
        passcodeLock.delegate = self
        notificationCenter = NotificationCenter.default
    }
    
    public convenience init(state: LockState, configuration: PasscodeLockConfigurationType, animateOnDismiss: Bool = true) {
        
        self.init(state: state.getState(), configuration: configuration, animateOnDismiss: animateOnDismiss)
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        clearEvents()
    }
    
    // MARK: - View
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        updatePasscodeView()
        deleteSignButton?.isEnabled = false
        setupEvents()
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureUI()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if shouldTryToAuthenticateWithBiometrics {

            authenticateWithBiometrics()

        }
    }
    
    internal func updatePasscodeView() {
        
        titleLabel?.text = passcodeLock.state.title
        descriptionLabel?.text = passcodeLock.state.description
        cancelButton?.isHidden = !passcodeLock.state.isCancellableAction
        touchIDButton?.isHidden = !passcodeLock.isTouchIDAllowed
        resetBtn?.isHidden = !passcodeLock.isAllowReset
    }
    
    // MARK: - Events

    fileprivate func setupEvents() {
        notificationCenter?.addObserver(self, selector: #selector(PasscodeLockViewController.appWillEnterForegroundHandler(_:)), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        notificationCenter?.addObserver(self, selector: #selector(PasscodeLockViewController.appDidEnterBackgroundHandler(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }

    fileprivate func clearEvents() {
        notificationCenter?.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        notificationCenter?.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }

    @objc open func appWillEnterForegroundHandler(_ notification: Notification) {
        passcodeLock.authenticateWithBiometrics()
    }

    @objc open func appDidEnterBackgroundHandler(_ notification: Notification) {
        shouldTryToAuthenticateWithBiometrics = false
    }

    internal func configureUI() {
        oneBtn.borderRadius = oneBtn.bounds.height / 2
        twoBtn.borderRadius = twoBtn.bounds.height / 2
        threeBtn.borderRadius = threeBtn.bounds.height / 2
        fourBtn.borderRadius = fourBtn.bounds.height / 2
        fiveBtn.borderRadius = fiveBtn.bounds.height / 2
        sixBtn.borderRadius = sixBtn.bounds.height / 2
        sevenBtn.borderRadius = sevenBtn.bounds.height / 2
        eightBtn.borderRadius = eightBtn.bounds.height / 2
        nineBtn.borderRadius = nineBtn.bounds.height / 2
        zeroBtn.borderRadius = zeroBtn.bounds.height / 2
    }


    // MARK: - Actions
    
    @IBAction func passcodeSignButtonTap(_ sender: PasscodeSignButton) {
        
        guard isPlaceholdersAnimationCompleted else { return }
        
        passcodeLock.addSign(sender.passcodeSign)
    }
    
    @IBAction func cancelButtonTap(_ sender: UIButton) {
        
        dismissPasscodeLock(passcodeLock)
    }
    
    @IBAction func deleteSignButtonTap(_ sender: UIButton) {
        
        passcodeLock.removeSign()
    }
    
    @IBAction func touchIDButtonTap(_ sender: UIButton) {
        
        passcodeLock.authenticateWithBiometrics()
    }
    @IBAction func resetPassword(_ sender: UIButton) {
        passcodeLockResetPass()
    }

        fileprivate func authenticateWithTouchID() {
            if passcodeConfiguration.shouldRequestTouchIDImmediately && passcodeLock.isTouchIDAllowed {
                passcodeLock.authenticateWithBiometrics()
            }
        }

    private func authenticateWithBiometrics() {
//        passcodeLock.authenticateWithBiometrics()

        if passcodeConfiguration.shouldRequestTouchIDImmediately && passcodeLock.isTouchIDAllowed {

            passcodeLock.authenticateWithBiometrics()
        }
    }
    
    internal func dismissPasscodeLock(_ lock: PasscodeLockType, completionHandler: (() -> Void)? = nil) {
        // if presented as modal
        if presentingViewController?.presentedViewController == self {
            dismiss(animated: animateOnDismiss) { [weak self] in
                self?.dismissCompletionCallback?()
                completionHandler?()
            }
        } else {
            // if pushed in a navigation controller
            _ = navigationController?.popViewController(animated: animateOnDismiss)
            //dismiss if present with navigation controller
            dismiss(animated: animateOnDismiss) { [weak self] in
                self?.dismissCompletionCallback?()
                completionHandler?()
            }
        }
        dismissCompletionCallback?()
        completionHandler?()
    }
    
    // MARK: - Animations
    
    internal func animateWrongPassword() {
        descriptionLabel?.text = "パスコードが合致しません"
        descriptionLabel?.textColor = UIColor(red: 204 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1.0)

        deleteSignButton?.isEnabled = false
        isPlaceholdersAnimationCompleted = false
        
        animatePlaceholders(placeholders, toState: .Error)
        
        placeholdersX?.constant = -40
        view.layoutIfNeeded()
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 0,
            options: [],
            animations: {
                self.placeholdersX?.constant = 0
                self.view.layoutIfNeeded()
        },
            completion: { completed in
                self.isPlaceholdersAnimationCompleted = true
                self.animatePlaceholders(self.placeholders, toState: .Inactive)
        })
    }
    
    internal func animatePlaceholders(_ placeholders: [PasscodeSignPlaceholderView], toState state: PasscodeSignPlaceholderView.State) {
        
        for placeholder in placeholders {
            placeholder.animateState(state)
        }
    }
    
    private func animatePlacehodlerAtIndex(_ index: Int, toState state: PasscodeSignPlaceholderView.State) {
        
        guard index < placeholders.count && index >= 0 else { return }
        
        placeholders[index].animateState(state)
    }

    // MARK: - PasscodeLockDelegate
    
    open func passcodeLockDidSucceed(_ lock: PasscodeLockType) {
        deleteSignButton?.isEnabled = true
        animatePlaceholders(placeholders, toState: .Inactive)

        dismissPasscodeLock(lock) { [weak self] in
            self?.successCallback?(lock)
        }
    }

    
    public func passcodeLockDidFail(_ lock: PasscodeLockType) {
        
        animateWrongPassword()
    }
    
    public func passcodeLockDidChangeState(_ lock: PasscodeLockType) {
        
        updatePasscodeView()
        animatePlaceholders(placeholders, toState: .Inactive)
        deleteSignButton?.isEnabled = false
    }
    
    public func passcodeLock(_ lock: PasscodeLockType, addedSignAtIndex index: Int) {
        
        animatePlacehodlerAtIndex(index, toState: .Active)
        deleteSignButton?.isEnabled = true
    }
    
    public func passcodeLock(_ lock: PasscodeLockType, removedSignAtIndex index: Int) {
        
        animatePlacehodlerAtIndex(index, toState: .Inactive)
        
        if index == 0 {
            
            deleteSignButton?.isEnabled = false
        }
    }

    public func passcodeLockResetPass() {
        let alert = UIAlertController(title: "パスコードを忘れた場合は\nアプリを削除して再インストール\nしてください。\n", message: "そのあとログインIDとパスワードで\nログインしていただけば過去のデータを\n維持したままご利用を再開できます。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "はい", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)

    }

}
