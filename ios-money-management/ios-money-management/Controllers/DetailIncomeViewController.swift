//
//  DetailIncomeViewController.swift
//  ios-money-management
//
//  Created by nguyenthanhnhan on 16/02/1403 AP.
//

import UIKit

class DetailIncomeViewController: UIViewController,  UICollectionViewDelegateFlowLayout, UICollectionViewDataSource  {
//    var detailExpense:Transaction?
    var transaction:Transaction? = nil
    
    @IBOutlet weak var txt_des: UILabel!
    @IBOutlet weak var txt_wallet: UILabel!
    @IBOutlet weak var txt_category: UILabel!
    @IBOutlet weak var txt_time: UILabel!
    @IBOutlet weak var txt_balance: UILabel!
    @IBOutlet weak var borderView: UIView!
 
    var wallets:[Wallet]?
    var detailTrans:Transaction?
    //tao mang luu hinh anh 
    var arrImgs:[UIImage]? = []
    
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Load lại DetailIncomeViewController")
        
       
        setFrontEnd()
        arrImgs = []
         

        //        Lấy userProfile đang nằm trong Tabbar controller
        if let tabBarController = self.tabBarController as? TabHomeViewController {
            if let transaction = transaction{
                setBackEnd(wallet: tabBarController.getWalletFromTransaction(wallet_ID: transaction.getWalletID)!, transaction: transaction)
                self.detailTrans = transaction
            }
            if let userprofile = tabBarController.userProfile  {
                self.wallets = userprofile.Wallets
            }
            
        }
        
        
         

      
        imagesCollectionView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        setFrontEnd()
        
         

        //        Lấy userProfile đang nằm trong Tabbar controller
        if let tabBarController = self.tabBarController as? TabHomeViewController {
            if let transaction = transaction{
                setBackEnd(wallet: tabBarController.getWalletFromTransaction(wallet_ID: transaction.getWalletID)!, transaction: transaction)
                self.detailTrans = transaction
            }
            if let userprofile = tabBarController.userProfile  {
                self.wallets = userprofile.Wallets
            }
            
        }
    }
    /// Hàm chuyển đồ từ Date sang String
    func DateToString(_ date:Date) -> String{
        // Lấy ra 1 biến Date ở thời gian hiện tại
        let currentDateAndTime = date
        // Tạo ra 1 biến format
        let dateFormatter = DateFormatter()
        
        // Ngày: 5/9/24
        dateFormatter.dateStyle = .full
        
        // Giờ none
        dateFormatter.timeStyle = .none
        
        // Địa điểm
//        dateFormatter.locale = Locale(identifier: "vi_VN")
        
        
        
        
        return dateFormatter.string(from: currentDateAndTime)
    }
    func setBackEnd(wallet:Wallet, transaction:Transaction){
        let maximumString = 185
        txt_des.text = transaction.getDescription.getShorterString(max: maximumString )
        txt_wallet.text = wallet.getName
        txt_category.text = transaction.getCategory.getName
        txt_time.text = DateToString(transaction.getCreateAt)
        txt_balance.text = String(transaction.getBalance.getVNDFormat())
        
        for image in transaction.Images{
            arrImgs?.append(image)
        }
    }
    func setFrontEnd(){
        //set background for navigation controller
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0/255, green: 168/255, blue: 107/255, alpha: 1);
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        //custom border of UIVIew
        borderView.layer.borderColor = CGColor(red: 241/250, green: 241/250, blue: 250/250, alpha: 1)
        self.tabBarController?.tabBar.isHidden = true

    }
    //MARK: events
    
    @IBAction func edit_income_tapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detail_ex = storyboard.instantiateViewController(withIdentifier: "Income") as! NewIncomeController
        detail_ex.navigationItem.title = "Edit Income"
        if let wallets = self.wallets {
//            Truyền mảng wallets của người dùng có qua
            detail_ex.wallets = wallets
//            lấy txt wallet truyền sang -> Ví hiện tại của trans
            detail_ex.selectedWallet = txt_wallet.text
            detail_ex.detail_trans = self.detailTrans

//            cái gì đó để trả về dữ liệu
            detail_ex.detailIncome = self
        }
        
        self.navigationController?.pushViewController(detail_ex, animated: true)
    }
    
    
    
    // Function to display the confirm dialog
    func showConfirmDialog() {
        let alertController = UIAlertController(title: "Delete transaction", message: "Are you sure you want to delete this transaction?", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
//        Nếu người dùng xác nhận delete
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            // Perform deletion action here
            Task{
//              1:  Xoá transaction trên db
                try await Transaction.deleteTransaction(walletID: self.transaction!.getWalletID, transactionID: self.transaction!.getID)
//               2: Xoá transaction ở mảng local
                if let tabBarController = self.tabBarController as? TabHomeViewController {
                    
                    if let userProfile = tabBarController.userProfile{
//                        Tìm được ví chứa giao dịch
                        let wallet = userProfile.Wallets.first(where: {$0.getID == self.transaction?.getWalletID})
//                        Tìm giao dịch trong ví đó
                       if let index =  wallet?.getTransactions().firstIndex(where: {$0.getID == self.transaction?.getID})
                        {
                           // xoá giao dịch khỏi mảng
                           wallet?.transactions_get_set.remove(at: index)
                       }
                        //                  3:  Cộng trừ tiền lại vào ví ở local
//                        wallet.balance trung gian = wallet.balance trung gian - (self.transaction.balance)
                        tabBarController.userProfile?.Wallets.first(where: {$0.getID == self.transaction?.getWalletID})?.Balance = (tabBarController.userProfile?.Wallets.first(where: {$0.getID == self.transaction?.getWalletID})!.Balance)! - self.transaction!.getBalance
                        
//                        4: Cộng trừ tiền trên db:
                        Wallet.set_updateWallet(UID: userProfile.getUID, wallet: Wallet(ID: wallet!.getID, Name: wallet!.getName, Balance: wallet!.Balance, Image: wallet?.getImage, Transaction: wallet!.transactions_get_set))
                    }

                }

//                Trở về màn hình trước
                self.navigationController?.popViewController(animated: true)

            }
        }
        alertController.addAction(deleteAction)
        
        // Configure presentation style as custom
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(alertController, animated: true, completion: nil)
    }
    @IBAction func deleteTransaction(_ sender: UIBarButtonItem) {
        showConfirmDialog()
    }
    //MARK: implements
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImgs?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuse = "DetailIncomeCell"
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuse, for: indexPath) as? DetailIncomeCell {
            cell.imgView.image = arrImgs?[indexPath.row]
           
            return cell
        }
        
        fatalError("khong the return cell : DetailExpenseViewController")
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 3 - 10 , height: 128 - 10)
    }
    


}


