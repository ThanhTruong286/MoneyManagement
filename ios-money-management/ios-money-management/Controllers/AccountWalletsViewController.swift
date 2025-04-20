//
//  AccountWalletsViewController.swift
//  ios-money-management
//
//  Created by AnNguyen on 09/05/2024.
//

import UIKit

class AccountWalletsViewController: UIViewController {
    var wallets:[Wallet] = []
    let UID = UserDefaults.standard.string(forKey: "UID")
    
    @IBOutlet weak var tbv_wallets: UITableView!
    @IBOutlet weak var totalBalance: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Vào AccountWalletsViewController")
        
        //        Lấy userProfile đang nằm trong Tabbar controller
        if let tabBarController = self.tabBarController as? TabHomeViewController {
            // Truy cập dữ liệu trong TabBarController
            if let userProfile = tabBarController.userProfile
            {
                wallets = userProfile.Wallets

            }
            
        }
        
//        Tính tổng số tiền
        var total_balance = 0
        for i in wallets{
            total_balance += i.Balance
            
        }
        self.totalBalance.text = String(total_balance.getVNDFormat())
        
   
        tabBarController?.tabBar.isHidden = true 
        tbv_wallets.dataSource = self
        tbv_wallets.delegate = self
        tbv_wallets.register(WalletTableViewCell.nib(), forCellReuseIdentifier: WalletTableViewCell.identifier)

    }
    //ham duoc goi de reset navbar, load thong tin khac
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavbar()
        print("Vào lai AccountWalletsViewController")
        
        //        Lấy userProfile đang nằm trong Tabbar controller
        if let tabBarController = self.tabBarController as? TabHomeViewController {
            // Truy cập dữ liệu trong TabBarController
            if let userProfile = tabBarController.userProfile
            {
                wallets = userProfile.Wallets

            }
            
        }
        
//        Tính tổng số tiền
        var total_balance = 0
        for i in wallets{
            total_balance += i.Balance
            
        }
        self.totalBalance.text = String(total_balance.getVNDFormat())

        tbv_wallets.reloadData()

    }
    //Ham set navbar
    func setNavbar() {
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.backgroundColor = .white
    }

    
//    MARK: Add new wallet
    @IBAction func btn_NewWallet_Tapped(_ sender: UIButton) {
        //Lấy main.storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //        Lấy màn hình cần chuyển qua
        let view_controller = storyboard.instantiateViewController(withIdentifier: "NewWallet")
        //        set title cho navigation
        view_controller.navigationItem.title = "New Wallet"
        //        Đẩy màn hình vào hàng đợi... (chuyển màn hình)
        navigationController?.pushViewController(view_controller, animated: true)
        //        self.present(view_controller, animated: true)
    }
    

}
extension AccountWalletsViewController: UITableViewDelegate, UITableViewDataSource{
    //    UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return wallets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        Tạo 1 cell từ file xib
        let cell = tableView.dequeueReusableCell(withIdentifier: WalletTableViewCell.identifier, for: indexPath) as! WalletTableViewCell
        
        //        Đổ dữ liệu vào cell
        cell.Wallet_name.text = self.wallets[indexPath.row].getName
        cell.Wallet_img.image = self.wallets[indexPath.row].getImage
        cell.Wallet_balace.text = String(self.wallets[indexPath.row].Balance.getVNDFormat())
        
        return cell
    }
    //    UITableViewDelegate
    //    làm 1 hành động nào đó khi click vào 1 đối tượng
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Lấy main.storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        //            Qua màn hình chi tiết wallet
        let detail_wallet = storyboard.instantiateViewController(withIdentifier: "DetailWalletViewController") as! DetailWalletViewController
        
        //        set title cho navigation
        detail_wallet.navigationItem.title = "Detail Wallet"
        
        // Đổ dữ liệu qua màn hình
        detail_wallet.wallet = self.wallets[indexPath.row]
        
        // Đẩy màn hình vào hàng đợi... (chuyển màn hình)
        navigationController?.pushViewController(detail_wallet, animated: true)
    }
    
    
    
}
