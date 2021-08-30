//
//  ChangePasswordVC.swift
//  Fringe
//
//  Created by Dharmani Apps on 19/08/21.
//

import UIKit
import Foundation
import IQKeyboardManagerSwift

class ChangePasswordVC : BaseVC , UITextViewDelegate , UITextFieldDelegate {
    
    @IBOutlet weak var txtOldPassword: FGPasswordTextField!
    @IBOutlet weak var txtNewPassword: FGPasswordTextField!
    @IBOutlet weak var txtConfirmPassword: FGPasswordTextField!
    var returnKeyHandler: IQKeyboardReturnKeyHandler?
    
    var textTitle: String?
    //------------------------------------------------------
    
    //MARK: Memory Management Method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //------------------------------------------------------
    
    deinit { //same like dealloc in ObjectiveC
        
    }
    //------------------------------------------------------
    
    //MARK: Customs
    
    func setup() {
        
        title = textTitle
        
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler?.delegate = self
        
        txtOldPassword.delegate = self
        txtNewPassword.delegate = self
        txtConfirmPassword.delegate = self
    }
    func validate() -> Bool {
        
        if ValidationManager.shared.isEmpty(text: txtOldPassword.text) == true {
            DisplayAlertManager.shared.displayAlert(target: self, animated: true, message: LocalizableConstants.ValidationMessage.enterPassword) {
            }
            return false
        }
        
        if ValidationManager.shared.isEmpty(text: txtNewPassword.text) == true {
            DisplayAlertManager.shared.displayAlert(target: self, animated: true, message: LocalizableConstants.ValidationMessage.enterNewPassword) {
            }
            return false
        }
        
        if ValidationManager.shared.isValid(text: txtNewPassword.text!, for: RegularExpressions.password8AS) == false {
            DisplayAlertManager.shared.displayAlert(target: self, animated: true, message: LocalizableConstants.ValidationMessage.enterValidNewPassword) {
            }
            return false
        }
        
        if ValidationManager.shared.isEmpty(text: txtConfirmPassword.text) == true {
            DisplayAlertManager.shared.displayAlert(target: self, animated: true, message: LocalizableConstants.ValidationMessage.enterRetypePassword) {
            }
            return false
        }
        
        if ValidationManager.shared.isValid(text: txtConfirmPassword.text!, for: RegularExpressions.password8AS) == false {
            DisplayAlertManager.shared.displayAlert(target: self, animated: true, message: LocalizableConstants.ValidationMessage.enterValidRetypePassword) {
            }
            return false
        }
        
        if (txtOldPassword.text == txtNewPassword.text) {
            DisplayAlertManager.shared.displayAlert(target: self, animated: true, message: LocalizableConstants.ValidationMessage.oldNewPasswordNotSame) {
            }
            return false
        }
        
        if (txtNewPassword.text != txtConfirmPassword.text) {
            DisplayAlertManager.shared.displayAlert(target: self, animated: true, message: LocalizableConstants.ValidationMessage.NewRetypePasswordNotMatch) {
            }
            return false
        }
        
        return true
    }
    
    private func performUpdatePassword(completion:((_ flag: Bool) -> Void)?) {

        let parameter: [String: Any] = [
            Request.Parameter.userID: currentUser?.userID ?? String(),
            Request.Parameter.oldPassword: txtOldPassword.text ?? String(),
            Request.Parameter.newPassword: txtNewPassword.text ?? String()
        ]
        
        RequestManager.shared.requestPOST(requestMethod: Request.Method.changePassword, parameter: parameter, showLoader: true, decodingType: BaseResponseModal.self, successBlock: { (response: BaseResponseModal) in

            LoadingManager.shared.hideLoading()
            
            if response.code == Status.Code.success {

                delay {

                    DisplayAlertManager.shared.displayAlert(animated: true, message: LocalizableConstants.SuccessMessage.passwordChanged) {

                        self.pop()
                        completion?(true)
                    }
                }

            } else {

                completion?(false)

                delay {
//                    self.handleError(code: response.code)
                }
            }

        }, failureBlock: { (error: ErrorModal) in

            completion?(false)

            delay {

                self.handleError(code: error.code)
            }
        })
    }
    
    
    //------------------------------------------------------
    
    //MARK: Actions
    
    @IBAction func btnBack(_ sender: Any) {
        self.pop()
    }
    
    
    @IBAction func btnSave(_ sender: Any) {
        if validate() == false {
            return
        }
        
        self.view.endEditing(true)
        
        LoadingManager.shared.showLoading()
        
        self.performUpdatePassword { (flag : Bool) in
            
        }
    }
    
    
    //------------------------------------------------------
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if IQKeyboardManager.shared.canGoNext {
            IQKeyboardManager.shared.goNext()
        } else {
            self.view.endEditing(true)
        }
        return true
    }
    
    //------------------------------------------------------
    
    //MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
       
    }
    
    //------------------------------------------------------
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NavigationManager.shared.isEnabledBottomMenu = false
    }
    
    //------------------------------------------------------
}
