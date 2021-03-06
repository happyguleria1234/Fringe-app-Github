//
//  HostAccountInformationVC.swift
//  Fringe
//
//  Created by Dharmani Apps on 31/08/21.
//

import UIKit
import Foundation
import IQKeyboardManagerSwift

class HostAccountInformationVC : BaseVC {
    
    
    @IBOutlet weak var lblAccountName: FGBaseLabel!
    @IBOutlet weak var lblAccountEmail: FGBaseLabel!
    @IBOutlet weak var lblMobileNumber: FGBaseLabel!
    @IBOutlet weak var lblAccountAddress: FGBaseLabel!
    
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
    
    //MARK: Custome
    
    func setupData()  {
        lblAccountName.text = currentUserHost?.accountHolderName
        lblAccountEmail.text = currentUserHost?.email
        lblMobileNumber.text = currentUserHost?.mobileNo
        lblAccountAddress.text = currentUserHost?.location
    }
    
    //------------------------------------------------------
    
    //MARK: Actions
    
    @IBAction func btnBack(_ sender: Any) {
        self.pop()
    }
    //------------------------------------------------------
    
    //MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
    }
    
    //------------------------------------------------------
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupData()
        NavigationManager.shared.isEnabledBottomMenuForHost = false
    }
    
    //------------------------------------------------------
}
