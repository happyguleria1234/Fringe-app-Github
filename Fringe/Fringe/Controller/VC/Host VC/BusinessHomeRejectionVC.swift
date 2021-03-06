//
//  BusinessHomeRejectionVC.swift
//  Fringe
//
//  Created by Dharmani Apps on 30/08/21.
//

import UIKit
import Alamofire
import Foundation
import IQKeyboardManagerSwift

class BusinessHomeRejectionVC : BaseVC {
    
    
    @IBOutlet weak var btnCancel: FGActiveButton!
    @IBOutlet weak var btnReject: FGActiveButton!
    @IBOutlet weak var reasonTextView: UITextView!
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var popUpView: UIView!
    
    var returnKeyHandler: IQKeyboardReturnKeyHandler?
    var centerFrame : CGRect!
    var requestID = String()
    var bookingStatus = String()
    var updateTblViewData:(()->Void)?
    //------------------------------------------------------
    
    //MARK: Memory Management Method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //------------------------------------------------------
    
    deinit { //same like dealloc in ObjectiveC
        
    }
    
    //------------------------------------------------------
    
    //MARK: Custome
    
    func presentPopUp()  {
        
        dataView.frame = CGRect(x: centerFrame.origin.x, y: view.frame.size.height, width: centerFrame.width, height: centerFrame.height)
        dataView.isHidden = false
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.90, initialSpringVelocity: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.dataView.frame = self.centerFrame
        }, completion: nil)
    }
    
    func dismissPopUp(_ dismissed:@escaping ()->())  {
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.90, initialSpringVelocity: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            
            self.dataView.frame = CGRect(x: self.centerFrame.origin.x, y: self.view.frame.size.height, width: self.centerFrame.width, height: self.centerFrame.height)
            
        },completion:{ (completion) in
            self.dismiss(animated: false, completion: {
            })
        })
    }
    
    //------------------------------------------------------
    
    //MARK: Validation
    
    func validate() -> Bool {
        
        if ValidationManager.shared.isEmpty(text: reasonTextView.text) == true {
            DisplayAlertManager.shared.displayAlert(target: self, animated: true, message: LocalizableConstants.ValidationMessage.rejectResn) {
            }
            return false
        }
        return true
    }
    
    private func performRequestAccept(completion:((_ flag: Bool) -> Void)?) {
        
        let headers:HTTPHeaders = [
            "content-type": "application/json",
            "Token": PreferenceManager.shared.authToken ?? String(),
        ]
        
        let parameter: [String: Any] = [
            Request.Parameter.id: requestID,
            Request.Parameter.type: "3",
            Request.Parameter.addReason: reasonTextView.text ?? String(),
            
        ]
        
        RequestManager.shared.requestPOST(requestMethod: Request.Method.acceptReject, parameter: parameter, headers: headers, showLoader: false, decodingType: BaseResponseModal.self, successBlock: { (response: BaseResponseModal) in
            LoadingManager.shared.hideLoading()
            
            if response.code == Status.Code.success {
                
                delay {
                    
                    DisplayAlertManager.shared.displayAlert(target: self, animated: true, message: response.message ?? String()) {
                        self.dismiss(animated: true) {
                            self.updateTblViewData?()
                        }
                    }
                    
                    completion?(true)
                }
                
            } else {
                
                completion?(false)
                
                delay {
                    
                    DisplayAlertManager.shared.displayAlert(target: self, animated: true, message: response.message ?? String()) {
                        
                    }
                }
            }
            
        }, failureBlock: { (error: ErrorModal) in
            
            LoadingManager.shared.hideLoading()
            
            delay {
                DisplayAlertManager.shared.displayAlert(animated: true, message: error.errorDescription, handlerOK: nil)
            }
        })
    }
    
    
    //------------------------------------------------------
    
    //MARK: Actions
    
    @IBAction func btnReject(_ sender: Any) {
        
        if validate() == false {
            return
        }
        
        self.view.endEditing(true)
        
        LoadingManager.shared.showLoading()
        
        self.performRequestAccept { (flag : Bool) in
            
        }
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }
    
    //------------------------------------------------------
    
    //MARK:  Dismiss Popup
    
    @objc func handleTap(_ sender:UITapGestureRecognizer){
        self.dismiss(animated: true) {
        }
    }
    //------------------------------------------------------
    
    //MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let mytapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.view.addGestureRecognizer(mytapGestureRecognizer)
        
    }
    
    //------------------------------------------------------
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //------------------------------------------------------
}

