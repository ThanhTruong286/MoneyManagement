//
//  AddWalletViewController.swift
//  ios-money-management
//
//  Created by nguyenthanhnhan on 19/02/1403 AP.
//

import UIKit
import FirebaseFirestore

class AddWalletViewController: UIViewController,UITextViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
    
    //MARK: properties
    @IBOutlet weak var collectionIconsView: UICollectionView!
    @IBOutlet weak var walletName: UITextField!
    @IBOutlet weak var balanceTextField: UITextField!
  
    var detail_wallet:Wallet?

    
    var icons:[String] = [
        "heart","paypal","money","hospital","basket","book","meal","bank","cash","mbb","bitcoin","salary"
    ]//string cac images trong asset
    var preSelectedButton:UIButton?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Vào AddWalletViewController")
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.backgroundColor = UIColor(red: 127/255, green: 61/255, blue: 255/255, alpha: 1)
        
        balanceTextField.delegate = self
        walletName.layer.borderColor =  CGColor(red: 241/250, green: 241/250, blue: 250/250, alpha: 1)
        balanceTextField.attributedPlaceholder = NSAttributedString(string: "0₫ ",attributes: [.foregroundColor: UIColor.white])
        self.tabBarController?.tabBar.isHidden = true
        
        //neu bien detai_wallet ton tai thi load du lieu len, va chon icon da chon
        if let detailWallet  = detail_wallet {
            walletName.text = detailWallet.getName
            balanceTextField.text = "\(detailWallet.Balance)"
            
        }
        
    }
    
    //MARK: events
    
    
    
    @IBAction func newWalletTapped(_ sender: UIButton)  {
        Task {
            
            //neu doi tuong detail_wallet ton tai thi la sua vi
            let icon = icons[preSelectedButton?.tag ?? 0]
            if let detail_wallet = self.detail_wallet {
                if let balance = Int(balanceTextField.text!), let walletName = walletName.text {
                    
                    //sua thong tin doi tuong duoc truyen vao
                    detail_wallet.getName = walletName
                    detail_wallet.Balance = balance
                    detail_wallet.getImage = UIImage(named: icon)
                    
                   
                    //cap nhat doi tuong duoc chinh sua len db
                    if let tabBarController = self.tabBarController as? TabHomeViewController {
                        if let userprofile = tabBarController.userProfile {
                            let uid = userprofile.getUID
                            Wallet.set_updateWallet(UID: uid, wallet: detail_wallet)
                        }
                    }
                    
                    
                    navigationController?.popViewController(animated: true)
                }
            }
            //neu khong ton tai thi la them vi
            else {

                //        Lấy userProfile (thong tin cua user) đang nằm trong Tabbar controller
                if let tabBarController = self.tabBarController as? TabHomeViewController {
                    if let userprofile = tabBarController.userProfile {
                        //lay user id va icon duoc chon
                        let uid = userprofile.getUID
                        let icon = icons[preSelectedButton?.tag ?? 0]
                        
                        if let balance = Int(balanceTextField.text ?? "0"),
                           let walletName = walletName.text
                        {
                        
                            //tao vi moi tren db
                           let walletID = try await Wallet.createNewWallet(UID:  uid, balance: balance, image:icon, name: walletName)
                            
                            //tao doi tuong vi moi
                            let newWallet = Wallet(ID: walletID, Name: walletName, Balance: balance,Image: UIImage(named: icon), Transaction: [])
                            
                           
                            //cap nhat vao man hinh TabarController (trung gian)
                            userprofile.Wallets.append(newWallet)
                            
                            navigationController?.popViewController(animated: true)
                            
                        }
                        
                    }
                }
            }
         
         
            
        
            
        }
    }
    
    
    //MARK: implementing classes
    //chan user nhap chu
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let _ = string.rangeOfCharacter(from: NSCharacterSet.decimalDigits.inverted) {
                // Nếu có ký tự không phải số, không cho phép thay đổi
                return false
            }
                
         
        
            // Nếu chỉ có số, cho phép thay đổi
            return true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuse = "IconAddWalletCell"
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuse, for: indexPath) as? AddIconWalletCell {
            cell.iconButton.addTarget(self, action: #selector(selectIconTapped(_ :)), for: .touchUpInside)
            cell.iconButton.tag = indexPath.row
            if let image = UIImage(named: icons[indexPath.row]) {
                
                cell.iconButton.setBackgroundImage(image, for: .normal)
                cell.iconButton.setTitle("", for: .normal)
                cell.iconButton.layoutIfNeeded()
                cell.iconButton.subviews.first?.contentMode = .scaleAspectFit
                cell.iconButton.backgroundColor = UIColor(red: 241/255, green: 241/255, blue: 250/255, alpha: 1)
                cell.iconButton.layer.cornerRadius = 8
                
                //hien thi icon da chon cho vi
                if icons[indexPath.row] == detail_wallet?.getImageName  {
                    cell.iconButton.layer.borderColor = CGColor(red: 127/255, green: 61/255, blue: 255/255, alpha: 1)
                    cell.iconButton.backgroundColor = UIColor(red: 238/255, green: 229/255, blue: 255/255, alpha: 1)
                    cell.iconButton.layer.borderWidth = 1
                    preSelectedButton = cell.iconButton
                }
            }
            return cell
        }
        fatalError("khong the return button")
    }
    
    @objc func selectIconTapped(_ sender:UIButton) {
        sender.layer.borderColor = CGColor(red: 127/255, green: 61/255, blue: 255/255, alpha: 1)
        sender.backgroundColor = UIColor(red: 238/255, green: 229/255, blue: 255/255, alpha: 1)
        sender.layer.borderWidth = 1
        if let prvButton = preSelectedButton {
            prvButton.backgroundColor = UIColor(red: 241/255, green: 241/255, blue: 250/255, alpha: 1)
            prvButton.layer.borderWidth = 0
        }
        preSelectedButton = sender
    }
    
}
