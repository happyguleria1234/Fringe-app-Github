//
//  BookingsVC.swift
//  Fringe
//
//  Created by Dharmani Apps on 30/08/21.
//

import UIKit
import Alamofire
import Foundation

class BookingsVC : BaseVC, UITableViewDataSource, UITableViewDelegate, SegmentViewDelegate {
    
    @IBOutlet weak var noDataLbl: FGSemiboldLabel!
    @IBOutlet weak var segment3: SegmentView!
    @IBOutlet weak var segment2: SegmentView!
    @IBOutlet weak var segment1: SegmentView!
    @IBOutlet weak var tblBooking: UITableView!
    
    var selectedDateDelegate : SendSelectedDate?
    var needToshowInfoView: Bool = false
    var btnTapped = true
    var isSelected = "0"
    var userId = String()
    var chatRoomData : CreateRoomModal?
    var items: [HostlistingModal] = []
    var requestID = String()
    var isRequesting: Bool = false
    var lastRequestId: String = String()
    
    //------------------------------------------------------
    
    //MARK: Memory Management Method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //------------------------------------------------------
    
    deinit { //same like dealloc in ObjectiveC
        
    }
    
    //------------------------------------------------------
    
    //MARK: Custom
    
    func setup() {
        tblBooking.dataSource = self
        tblBooking.delegate = self
        segment1.btn.setTitle("Pending", for: .normal)
        segment2.btn.setTitle("Awaiting", for: .normal)
        segment3.btn.setTitle("Confirmed", for: .normal)
        
        segment1.delegate = self
        segment2.delegate = self
        segment3.delegate = self
        
        segment1.isSelected = true
        segment2.isSelected = !segment1.isSelected
        segment3.isSelected = !segment1.isSelected
        
        var identifier = String(describing:HostPendingCell.self)
        var nibCell = UINib(nibName: identifier, bundle: Bundle.main)
        tblBooking.register(nibCell, forCellReuseIdentifier: identifier)
        
        identifier = String(describing: HostAwaitingCell.self)
        nibCell = UINib(nibName: identifier, bundle: Bundle.main)
        tblBooking.register(nibCell, forCellReuseIdentifier: identifier)
        
        identifier = String(describing: HostConfirmedCell.self)
        nibCell = UINib(nibName: identifier, bundle: Bundle.main)
        tblBooking.register(nibCell, forCellReuseIdentifier: identifier)
    }
    
    func updateUI() {
        
        if items.count == 0{
            self.noDataLbl.isHidden = false
        }else{
            self.noDataLbl.isHidden = true
        }
        
        if segment1.isSelected == true {
            
            noDataLbl.text = LocalizableConstants.Controller.FringeDataForGolfclub.pending.localized()
            noDataLbl.isHidden = items.count != .zero
            
        } else if segment2.isSelected == true {
            
            noDataLbl.text = LocalizableConstants.Controller.FringeDataForGolfclub.awating.localized()
            noDataLbl.isHidden = items.count != .zero
            
        } else if segment3.isSelected == true {
            
            noDataLbl.text = LocalizableConstants.Controller.FringeDataForGolfclub.confirmed.localized()
            noDataLbl.isHidden = items.count != .zero
            
        }
        tblBooking.reloadData()
    }
    
    private func performRequestAccept(id : String,completion:((_ flag: Bool) -> Void)?) {
        
        let headers:HTTPHeaders = [
            "content-type": "application/json",
            "Token": PreferenceManager.shared.authToken ?? String(),
        ]
        
        let parameter: [String: Any] = [
            Request.Parameter.id: id,
            Request.Parameter.type: "1",
        ]
        
        RequestManager.shared.requestPOST(requestMethod: Request.Method.acceptReject, parameter: parameter, headers: headers, showLoader: false, decodingType: BaseResponseModal.self, successBlock: { (response: BaseResponseModal) in
            LoadingManager.shared.hideLoading()
            
            if response.code == Status.Code.success {
                
                delay {
                    
                    DisplayAlertManager.shared.displayAlert(target: self, animated: true, message: response.message ?? String()) {
                    }
                    
                    completion?(true)
                }
                
            } else {
                
                completion?(false)
                
                delay {
                    
                    // self.handleError(code: response.code)
                    
                }
            }
            
        }, failureBlock: { (error: ErrorModal) in
            
            LoadingManager.shared.hideLoading()
            
            delay {
                DisplayAlertManager.shared.displayAlert(animated: true, message: error.errorDescription, handlerOK: nil)
            }
        })
    }
    
    func performGetRequestData(completion:((_ flag: Bool) -> Void)?) {
        
        let headers:HTTPHeaders = [
            "content-type": "application/json",
            "Token": PreferenceManager.shared.authToken ?? String(),
        ]
        
        self.noDataLbl.isHidden = true
        
        isRequesting = true
        
        if self.lastRequestId == ""{
            self.items.removeAll()
        }
        
        var parameter: [String: Any] = [:]
        
        if segment1.isSelected == true{
            
            parameter = [Request.Parameter.userID: PreferenceManager.shared.userId ?? String(),
                         Request.Parameter.bookedStatus: isSelected,
                         Request.Parameter.lastID: lastRequestId,
            ]
            
        }else if segment2.isSelected == true{
            
            parameter = [Request.Parameter.userID: PreferenceManager.shared.userId ?? String(),
                         Request.Parameter.bookedStatus: isSelected,
                         Request.Parameter.lastID: lastRequestId,
            ]
            
        }else if segment3.isSelected == true {
            
            parameter = [Request.Parameter.userID: PreferenceManager.shared.userId ?? String(),
                         Request.Parameter.bookedStatus: isSelected,
                         Request.Parameter.lastID: lastRequestId,
            ]
            
        }else{
            
            parameter = [Request.Parameter.userID: PreferenceManager.shared.userId ?? String(),
                         Request.Parameter.bookedStatus: isSelected,
                         Request.Parameter.lastID: lastRequestId,
            ]
        }
        
        RequestManager.shared.requestPOST(requestMethod: Request.Method.playersBooking, parameter: parameter, headers: headers, showLoader: false, decodingType: ResponseModal<[HostlistingModal]>.self, successBlock: { (response: ResponseModal<[HostlistingModal]>) in
            
            LoadingManager.shared.hideLoading()
            
            self.isRequesting = false
            
            if response.code == Status.Code.success {
                
                delay {
                    
                    if self.lastRequestId.isEmpty {
                        
                        self.items.removeAll()
                    }
                    
                    self.items.append(contentsOf: response.data ?? [])
                    self.lastRequestId = response.data?.last?.id ?? String()
                    self.updateUI()
                    
                }
                
            } else if response.code == Status.Code.nofoundDat {
                
                LoadingManager.shared.hideLoading()
                
                self.items.removeAll()
                
                self.updateUI()
                
                LoadingManager.shared.hideLoading()
                
                self.noDataLbl.isHidden = false
                
            }
            
        }, failureBlock: { (error: ErrorModal) in
            
            self.isRequesting = false
            
            LoadingManager.shared.hideLoading()
            
            delay {
                DisplayAlertManager.shared.displayAlert(animated: true, message: error.errorDescription, handlerOK: nil)
            }
        })
    }
    
    func performGetUserProfile() {
        
        let headers:HTTPHeaders = [
            "content-type": "application/json",
            "Token": PreferenceManager.shared.authToken ?? String(),
        ]
        
        RequestManager.shared.requestPOST(requestMethod: Request.Method.hostProfile, parameter: [:], headers: headers, showLoader: false, decodingType: ResponseModal<HostModal>.self, successBlock: { (response: ResponseModal<HostModal>) in
            
            LoadingManager.shared.hideLoading()
            
            if response.code == Status.Code.success {
                
                if let stringUser = try? response.data?.jsonString() {
                    
                    PreferenceManager.shared.currentUserHost = stringUser
                    PreferenceManager.shared.golfId = response.data?.golfID
                    self.updateUI()
                }
                                
            } else {
                
                delay {
                    
                    
                }
            }
            
        }, failureBlock: { (error: ErrorModal) in
            
            LoadingManager.shared.hideLoading()
            
            delay {
                
                DisplayAlertManager.shared.displayAlert(target: self, animated: false, message: LocalizableConstants.Error.anotherLogin) {
                    PreferenceManager.shared.userId = nil
                    PreferenceManager.shared.currentUser = nil
                    PreferenceManager.shared.authToken = nil
                    NavigationManager.shared.setupSingIn()
                }
            }
            
        })
    }

    func performGetBadgeCount(completion:((_ flag: Bool) -> Void)?) {
        
        let parameter: [String: Any] = [
            Request.Parameter.userID: PreferenceManager.shared.userId ?? String(),
            Request.Parameter.role: PreferenceManager.shared.curretMode ?? String(),
        ]
        
        RequestManager.shared.requestPOST(requestMethod: Request.Method.badgeCount, parameter: parameter, headers: [:], showLoader: false, decodingType: ResponseModal<BadgeModal>.self, successBlock: { (response: ResponseModal<BadgeModal>) in
                        
            self.isRequesting = false
            
            if response.code == Status.Code.success {
                
                if let stringUser = try? response.data?.jsonString() {
                    
                    PreferenceManager.shared.badgeModal = stringUser
                    
                }
                
            } else {
                
                completion?(true)
            }
            
            LoadingManager.shared.hideLoading()
            
        }, failureBlock: { (error: ErrorModal) in
            
            LoadingManager.shared.hideLoading()
            self.isRequesting = false
            
//            delay {
//
//                DisplayAlertManager.shared.displayAlert(target: self, animated: false, message: error.localizedDescription) {
//                    PreferenceManager.shared.userId = nil
//                    PreferenceManager.shared.currentUser = nil
//                    PreferenceManager.shared.authToken = nil
//                    NavigationManager.shared.setupSingIn()
//                }
//            }
        })
    }

    func performCreateRoom(userID : String , completion:((_ flag: Bool) -> Void)?) {

        let headers:HTTPHeaders = [
           "content-type": "application/json",
            "Token": PreferenceManager.shared.authToken ?? String(),
          ]

        let parameter: [String: Any] = [
            Request.Parameter.hostID: userID ?? String(),
        ]

        RequestManager.shared.requestPOST(requestMethod: Request.Method.createRoomForChat, parameter: parameter, headers: headers, showLoader: false, decodingType: ResponseModal<CreateRoomModal>.self, successBlock: { (response: ResponseModal<CreateRoomModal>) in
            print(response)

            LoadingManager.shared.hideLoading()

            if response.code == Status.Code.success {

                self.chatRoomData = response.data
                
                delay {
                    let controller = NavigationManager.shared.messageListingVC
                    controller.roomID = self.chatRoomData?.roomID ?? String()
                    controller.otherUserName = self.chatRoomData?.name ?? String()
                    controller.otherUserImg = self.chatRoomData?.image ?? String()
                    self.push(controller: controller)
                }
                
            } else {

                delay {

                }
            }

        }, failureBlock: { (error: ErrorModal) in

            LoadingManager.shared.hideLoading()

            delay {
                
                DisplayAlertManager.shared.displayAlert(target: self, animated: false, message: LocalizableConstants.Error.anotherLogin) {
                    PreferenceManager.shared.userId = nil
                    PreferenceManager.shared.currentUser = nil
                    PreferenceManager.shared.authToken = nil
                    NavigationManager.shared.setupSingIn()
                }
            }
        })
    }

    
    //------------------------------------------------------
    
    //MARK: UITableViewDataSource,UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segment1.isSelected {
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HostPendingCell.self)) as? HostPendingCell{
                if items.count > 0 {
                    let data = items[indexPath.row]
                    cell.btnMoreInfo.addTarget(self, action: #selector(showHideView), for: .touchUpInside)
//                    cell.btnMoreInfo.tag = indexPath.row
                    cell.btnReject.tag = indexPath.row
                    cell.btnAccept.tag = indexPath.row
                    cell.setup(bookingData: data)
                    if needToshowInfoView {
                        cell.cancelView.isHidden = true
//                        cell.detailView.isHidden = true
                        cell.btnClose.isHidden = true
                        cell.btnMoreInfo.isHidden = false
                    }
                    cell.btnClose.addTarget(self, action: #selector(showViews), for: .touchUpInside)
                    cell.btnReject.addTarget(self, action: #selector(showpopUpView), for: .touchUpInside)
                    cell.btnAccept.addTarget(self, action: #selector(requestAccept), for: .touchUpInside)
                    return cell
                }else{
                    
                }
            }
            
        } else if segment2.isSelected {
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HostAwaitingCell.self)) as? HostAwaitingCell {
                if items.count > 0 {
                    let data = items[indexPath.row]
                    cell.setup(bookingData: data)
                    return cell
                }
            }
        }
        
        else if segment3.isSelected {
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HostConfirmedCell.self)) as? HostConfirmedCell {
                if items.count > 0 {
                    let data = items[indexPath.row]
                    cell.setup(bookingData: data)
                    cell.chatBtn.tag = indexPath.row
                    cell.chatBtn.addTarget(self, action: #selector(chatAction), for: .touchUpInside)
                    return cell
                }
            }
        }
        return UITableViewCell()
    }
    
    //------------------------------------------------------
    
    //MARK:  TableView cell button Actions
        
    @objc func showHideView(sender : UIButton) {
        if let cell = sender.superview?.superview?.superview?.superview?.superview as? HostPendingCell{
            self.needToshowInfoView = false
            cell.cancelView.isHidden = false
//            cell.detailView.isHidden = false
            cell.btnClose.isHidden = false
            cell.btnMoreInfo.isHidden = true
//            self.tblBooking.reloadData()
            btnTapped = false
        }
    }
    
    @objc func showViews(sender : UIButton) {
        if let cell = sender.superview?.superview?.superview?.superview?.superview as? HostPendingCell{
            btnTapped = true
            cell.cancelView.isHidden = true
//            cell.detailView.isHidden = true
            cell.btnClose.isHidden = true
            cell.btnMoreInfo.isHidden = false
//            tblBooking.reloadData()
        }
    }
    
    @objc func showpopUpView(sender : UIButton) {
        let controller = NavigationManager.shared.businessHomeRejectionVC
        let data = items[sender.tag]
        controller.requestID = data.id ?? ""
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .flipHorizontal
        controller.updateTblViewData = {
            
            DispatchQueue.main.async {
                self.lastRequestId = ""
                self.needToshowInfoView = true
                self.performGetRequestData { (flag: Bool) in
                    self.updateUI()
                }
            }
        }
        
        self.present(controller, animated: true) {
        }
    }
    
    @objc func requestAccept(sender : UIButton) {
        let data = items[sender.tag]
        self.requestID = data.id ?? ""
        LoadingManager.shared.showLoading()
        
        delayInLoading {
            
            LoadingManager.shared.hideLoading()
            self.performRequestAccept(id: data.id ?? String()) { (flag: Bool) in
                if flag {
                    
                    //                    self.dismiss(animated: true, completion: nil)
                    self.needToshowInfoView = true
                    self.lastRequestId = ""
                    self.performGetRequestData { (flag: Bool) in
                    }
                }
            }
        }
    }
    
    @objc func chatAction(sender : UIButton) {
        let data = items[sender.tag]
        performCreateRoom(userID: data.userDetails?.userID ?? String()) { (flag : Bool) in
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    //------------------------------------------------------
    
    //MARK: SegmentViewDelegate
    
    func segment(view: SegmentView, didChange flag: Bool) {
        
        tblBooking.reloadData()
        
        self.lastRequestId = ""
        
        self.needToshowInfoView = true
        
        if view == segment1 {
            
            isSelected = "0"
            
            LoadingManager.shared.showLoading()
            
            self.performGetRequestData { (flag : Bool) in
                
            }
            
            segment2.isSelected = false
            segment3.isSelected = false
            
        } else if view == segment2 {
            
            isSelected = "1"
            
            LoadingManager.shared.showLoading()
            
            self.performGetRequestData { (flag : Bool) in
                
            }
            
            segment1.isSelected = false
            segment3.isSelected = false
        }
        else if view == segment3 {
            
            isSelected = "2"
            
            LoadingManager.shared.showLoading()
            
            self.performGetRequestData { (flag : Bool) in
                
            }
            
            segment1.isSelected = false
            segment2.isSelected = false
        }
    }    
    
    //------------------------------------------------------
    
    //MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //------------------------------------------------------
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationManager.shared.isEnabledBottomMenuForHost = true

        if currentUserHost?.stripeAccountStatus == "0" {
            let controller = NavigationManager.shared.popUpViewForAddAccountVC
            controller.modalPresentationStyle = .overFullScreen
            controller.modalTransitionStyle = .flipHorizontal
            self.present(controller, animated: true) {
                
            }
        }
        
        self.lastRequestId = ""
        
        isSelected = "0"
        
        self.performGetUserProfile()
        
//        LoadingManager.shared.showLoading()
        
        self.performGetRequestData { (flag : Bool) in
            
        }
        
        self.performGetBadgeCount { (flag : Bool) in
            
        }
        
        setup()
        
    }
    
    //------------------------------------------------------
}
