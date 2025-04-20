//
//  NewIncomeController.swift
//  ios-money-management
//
//  Created by nguyenthanhnhan on 09/02/1403 AP.
//

import UIKit
import PhotosUI
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

class NewIncomeController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, PHPickerViewControllerDelegate {
    
    
    //MARK: properties
    @IBOutlet weak var popupWalletButton: UIButton!
    @IBOutlet weak var textFieldValue: UITextField!
    @IBOutlet weak var textFieldDescription: UITextField!
    @IBOutlet weak var popupCategoryButton: UIButton!
    @IBOutlet weak var collectionImagesView: UICollectionView!
    
    @IBOutlet weak var addImgButton: UIBarButtonItem!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var view_loading: UIActivityIndicatorView!
    @IBOutlet weak var view_opacity: UIView!
    var selectedImages = [UIImage]()

//    Ví của người dùng
    var wallets: [Wallet] = []
    var categoryID = ""
    var wallet:Wallet? = nil
    var UID = ""
    
    
    
    
    var selectedWallet:String?
    var detail_trans:Transaction?
    
//    Biến trả về sau khi edit
    var detailIncome: DetailIncomeViewController?
    override func viewDidLoad() {
 
        super.viewDidLoad()
        print("Vào NewIncomeController")
        
        view_opacity.isHidden = true
        view_loading.isHidden = true

        datePicker.maximumDate = Date()
        //       Lấy UID
        UID = UserDefaults.standard.string(forKey: "UID") ?? ""
        //button custom
        setFrontEnd()
        
        //        Đổ category vào pop up category
        setCategoryExpenses()
        setWallets(wallets: wallets)
        setNavbar()
    }
    
    //MARK: set up data in popup button

    
    func setNavbar() {
        //set background for navigation controller
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0/255, green: 180/255, blue: 126/255, alpha: 1);
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    func setCategoryExpenses() {
//        lấy tab bar controller
        if let tabBarController = self.tabBarController as? TabHomeViewController {
//            lấy danh sách income
            let category_income = tabBarController.category_income
            
//            Đổ dữ liệu vào pop up
            let actions = category_income.map { category in
                UIAction(title: category.getName, image: category.getImage) { [weak self] action in
                    guard let self = self else { return } 
                    self.categoryID = category.getID
                    self.popupCategoryButton.setAttributedTitle(NSAttributedString(string: action.title), for: .normal)
                    self.popupCategoryButton.setImage(action.image, for: .normal)
                }
            }
//            set pop up
            let menu = UIMenu(children: actions)
            if let detailTrans = detail_trans, let action = menu.children.first(where: {$0.title == detailTrans.getCategory.getName}) as? UIAction{
                self.popupCategoryButton.setAttributedTitle(NSAttributedString(string: action.title), for: .normal)
                self.popupCategoryButton.setImage(action.image, for: .normal)
                action.state = .on
                
            }
            
            popupCategoryButton.menu = menu 
            popupCategoryButton.showsMenuAsPrimaryAction = true
            
        }
    }
    func setWallets(wallets:[Wallet])  {
        // Tạo các UIAction từ danh sách Wallet
        let actions = wallets.map { wallet in
            UIAction(title: wallet.getName, image: wallet.getImage) { [weak self] action in
                guard let self = self else { return }
                
                // Cập nhật giao diện của popup button (tùy chọn)
                self.popupWalletButton.setAttributedTitle(NSAttributedString(string: wallet.getName), for: .normal)
                self.popupWalletButton.setImage(wallet.getImage, for: .normal) // Đặt lại ảnh
                self.wallet = wallet
                // Xử lý khi người dùng chọn một ví
                // Gọi hàm xử lý đã chọn ví (đã được khai báo ở đâu đó trong ViewController)
                //                    self.handleWalletSelection(wallet: wallet)
            }
        }
        
        // Tạo UIMenu từ các UIAction và gán cho popup button
        let menu = UIMenu(children: actions)
        if let selectedWallet = self.selectedWallet , let selectedAction = actions.first(where: { $0.title == selectedWallet }) {
   
            selectedAction.state = .on
            self.wallet = wallets.first(where: { $0.getName == selectedWallet }) // Lấy ví tương ứng
            self.popupWalletButton.setAttributedTitle(NSAttributedString(string: selectedAction.title), for: .normal)
            self.popupWalletButton.setImage(selectedAction.image, for: .normal) // Đặt lại ảnh
        }
        popupWalletButton.menu = menu
        popupWalletButton.showsMenuAsPrimaryAction = true
    }
    //MARK: events
    
    @IBAction func addImagesTapped(_ sender: Any) {
        var config = PHPickerConfiguration()
        config.selectionLimit =  3 - selectedImages.count
        let phVC = PHPickerViewController(configuration: config)
        phVC.delegate = self
        self.present(phVC, animated: true)
        
    }
    
    //MARK: implementing classes
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        for r in results {
            r.itemProvider.loadObject(ofClass: UIImage.self) {(object,err) in
                if let img = object as? UIImage {
                    self.selectedImages.append(img)
                }
                DispatchQueue.main.sync {
                    self.collectionImagesView.reloadData()
                }
            }
        }
        if results.count >= 3 || results.count + selectedImages.count >= 3 {
            addImgButton.isEnabled = false
        }
    }
    
    @IBAction func NewIncome_Tapped(_ sender: UIButton)  {
        // Edit trans
        if selectedWallet != nil{
            view_opacity.isHidden = false
            view_loading.isHidden = false

            Task{
                //                Xoá transaction trên db
                try await Transaction.deleteTransaction(walletID: self.detail_trans!.getWalletID, transactionID: self.detail_trans!.getID)
                //                Xoá transaction ở mảng local
                if let tabBarController = self.tabBarController as? TabHomeViewController {
                    if let userProfile = tabBarController.userProfile{
                        //                        Tìm được ví chứa giao dịch
                        let wallet = userProfile.Wallets.first(where: {$0.getID == self.detail_trans?.getWalletID})
                        //                        Tìm giao dịch trong ví đó
                        if let index =  wallet?.getTransactions().firstIndex(where: {$0.getID == self.detail_trans?.getID})
                        {
                            // xoá giao dịch khỏi mảng
                            wallet?.transactions_get_set.remove(at: index)
                        }
                        //                    Cộng trừ tiền lại vào ví:
                        //                        wallet.balance trung gian = wallet.balance trung gian - (self.transaction.balance)
                        tabBarController.userProfile?.Wallets.first(where: {$0.getID == self.detail_trans?.getWalletID})?.Balance = (tabBarController.userProfile?.Wallets.first(where: {$0.getID == self.detail_trans?.getWalletID})!.Balance)! - self.detail_trans!.getBalance
                        //                        Cộng trừ tiền trên db
                                                Wallet.set_updateWallet(UID: userProfile.getUID, wallet: Wallet(ID: wallet!.getID, Name: wallet!.getName, Balance: wallet!.Balance, Image: wallet?.getImage, Transaction: wallet!.transactions_get_set))

                    }
                    
                }
                
                //            Thêm trans ở local
                //            Thêm trans trên db
                
//Nếu người dùng ko thay đổi category ->
                if categoryID == ""{
//                    gán lại category bằng là category cũ
                    categoryID = (detail_trans?.getCategory.getID)!
                }
                
                if let balanceString = textFieldValue.text,
                       let balance = Int(balanceString),
                       let description = textFieldDescription.text,
                       let wallet = wallet
                    {
                        
                            do {
                                // Thêm giao dịch mới lên DB và lấy ID của nó
                                let transactionID = try await Transaction.addTransaction(
                                    wallet_id: wallet.getID,
                                    balance: balance,
                                    category_id: categoryID,
                                    des: description,
                                    images: selectedImages,
                                    created_at: datePicker.date
                                )

                                // Cập nhật số dư ví trên DB
                                Wallet.set_updateWallet(UID: UID, wallet: Wallet(ID: wallet.getID, Name: wallet.getName ,Balance: wallet.Balance + balance, Image: wallet.getImage , Transaction: wallet.getTransactions()))
                                

                                
                                
                                

                                // Thêm transaction mới tạo vào mảng transactions của ví ở local
                                // Tạo transaction mới với ID vừa nhận được
                                let newTransaction = await Transaction(id: transactionID, description: description, balance: balance, category: Category.getCategory(Category_ID: categoryID)!, create_at: datePicker.date, wallet_id: wallet.getID, images: selectedImages)
//                                Trả dữ liệu mới về
                                detailIncome?.transaction = newTransaction
                                detailIncome?.arrImgs = selectedImages
                                
        //                        Đẩy lên tabbar ở trung gian
                                if let tabBarController = self.tabBarController as? TabHomeViewController {
                                    if let userProfile = tabBarController.userProfile {
                                        if let wallet = userProfile.Wallets.first(where: {$0.getID == wallet.getID}) {
                                            // Thêm transaction vào wallet
                                            wallet.addTransaction(transaction: newTransaction)
                                        
                                            //                        Cập nhật tiền của ví dưới local
                                            wallet.Balance = wallet.Balance + balance
                                            
                                        }
                                        
                                    }
                                }

                            } catch {
                                // Xử lý lỗi nếu có
                                print("Error adding transaction: \(error)")
                                let alertController = UIAlertController(title: "Error", message: "Error adding transaction.", preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: "OK", style: .default))
                                self.present(alertController, animated: true, completion: nil)
                            }
                            
                        
                    } else {
                        // Xử lý trường hợp UID hoặc walletID không tồn tại
                        print("Error: UID or walletID is missing")
                        let alertController = UIAlertController(title: "Error", message: "UID or walletID is missing.", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alertController, animated: true, completion: nil)
                    }
                view_opacity.isHidden = true
                view_loading.isHidden = true

                navigationController?.popViewController(animated: true)
//                navigationController?.popViewController(animated: true)
            }
            

        }
//        Add trans
        else{
            
            if let balanceString = textFieldValue.text,
                   let balance = Int(balanceString),
                   let description = textFieldDescription.text,
                   let wallet = wallet
                {
                self.view_opacity.isHidden = false
                self.view_loading.isHidden = false
                    Task {
                        do {
                            
                            // Thêm giao dịch mới lên DB và lấy ID của nó
                            let transactionID = try await Transaction.addTransaction(
                                wallet_id: wallet.getID,
                                balance: balance,
                                category_id: categoryID,
                                des: description,
                                images: selectedImages,
                                created_at: datePicker.date
                            )

                            // Cập nhật số dư ví trên DB
                            Wallet.set_updateWallet(UID: UID, wallet: Wallet(ID: wallet.getID, Name: wallet.getName ,Balance: wallet.Balance + balance, Image: wallet.getImage , Transaction: wallet.getTransactions()))

                            
                            
                            

                            // Thêm transaction mới tạo vào mảng transactions của ví ở local
                            // Tạo transaction mới với ID vừa nhận được
                            let newTransaction = await Transaction(id: transactionID, description: description, balance: balance, category: Category.getCategory(Category_ID: categoryID)!, create_at: datePicker.date, wallet_id: wallet.getID, images: selectedImages)
                            
    //                        Đẩy lên tabbar ở trung gian
                            if let tabBarController = self.tabBarController as? TabHomeViewController {
                                if let userProfile = tabBarController.userProfile {
                                    if let wallet = userProfile.Wallets.first(where: {$0.getID == wallet.getID}) {
                                        // Thêm transaction vào wallet
                                        wallet.addTransaction(transaction: newTransaction)
                                    
                                        //                        Cập nhật tiền của ví dưới local
                                        wallet.Balance = wallet.Balance + balance
                                        
                                    }
                                    
                                }
                            }

                        } catch {
                            // Xử lý lỗi nếu có
                            print("Error adding transaction: \(error)")
                            let alertController = UIAlertController(title: "Error", message: "Error adding transaction.", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alertController, animated: true, completion: nil)
                        }
                        self.view_opacity.isHidden = true
                        self.view_loading.isHidden = true
                        navigationController?.popViewController(animated: true)
                    }
                } else {
                    // Xử lý trường hợp UID hoặc walletID không tồn tại
                    print("Error: UID or walletID is missing")
                    let alertController = UIAlertController(title: "Error", message: "UID or walletID is missing.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alertController, animated: true, completion: nil)
                }
        }
        
       
    }
        
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuse = "IncomeImageCell"
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuse, for: indexPath) as? IncomeImageCell{
            cell.imgView.image = selectedImages[indexPath.row]
            
            //cancel button
            cell.cancelButton.addTarget(self, action: #selector(cancelButtonTapped(_ :)), for: .touchUpInside)
            cell.cancelButton.tag = indexPath.row
            
            return cell
        }
        fatalError("Khong the return Income ")
    }
    func setFrontEnd()  {
        
        
        
        if let detail_trans = self.detail_trans {
            textFieldValue.text = "\(detail_trans.getBalance )"
            textFieldDescription.text = "\(detail_trans.getDescription)"
            selectedImages.append(contentsOf: detail_trans.Images)
            datePicker.date =  detail_trans.getCreateAt
        }
        
        
        
        
        // Thiết lập tiêu đề của nut
        let attributedTitleCategory = NSAttributedString(string: "Category")
        popupCategoryButton.setAttributedTitle(attributedTitleCategory, for: .normal)
        
        let attributedTitleWallet = NSAttributedString(string: "Wallet")
        popupWalletButton.setAttributedTitle(attributedTitleWallet, for: .normal)
        //chinh mau chu cho textfield $0
        textFieldValue.attributedPlaceholder = NSAttributedString(string: "0₫",attributes: [.foregroundColor: UIColor.white])
        
        // Thiết lập các thuộc tính cho các nút khác
        popupCategoryButton.layer.borderColor = UIColor(red: 241/255, green: 241/255, blue: 250/255, alpha: 1).cgColor
        popupCategoryButton.layer.borderWidth = 1
        popupCategoryButton.layer.cornerRadius = 6
        popupWalletButton.layer.borderColor = UIColor(red: 241/255, green: 241/255, blue: 250/255, alpha: 1).cgColor
        popupWalletButton.layer.borderWidth = 1
        popupWalletButton.layer.cornerRadius = 6
        
       
        
        
        
        
        //        Xoá navigation bottom
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func cancelButtonTapped(_ sender: UIButton) {
        selectedImages.remove(at: sender.tag)
        if selectedImages.count < 3 {
            addImgButton.isEnabled = true
        }
        collectionImagesView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionImagesView.frame.size.width/3 - 10, height: 128 - 10)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     @IBAction func popupWalletButton(_ sender: UIButton) {
     }
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
