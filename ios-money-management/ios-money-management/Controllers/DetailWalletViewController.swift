//
//  DetailWalletViewController.swift
//  ios-money-management
//
//  Created by AnNguyen on 10/05/2024.
//

import UIKit

class DetailWalletViewController: UIViewController {


    @IBOutlet weak var wallet_balance: UILabel!
    @IBOutlet weak var wallet_name: UILabel!
    @IBOutlet weak var wallet_img: UIImageView!
    @IBOutlet weak var tableview: UITableView!
    
    
    
    var wallet:Wallet? = nil
    var transactions:[Transaction] = []
    var sections: [Section] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        print("Vào DetailWalletViewController - \(wallet?.getName ?? "")")
//        Đổ dữ liệu lên các UI
        setFrontEnd()
//        bỏ các transaction của ví vào mảng -> đẩy lên table view
        setTransactions(data: (wallet?.getTransactions())!)
//        sắp xếp lại mảng
        transactions.sort { $0.getCreateAt > $1.getCreateAt }
        
        //                Lọc transactions theo ngày
        sections = createSections(from: transactions)
        
//        Kết nối
        tableview.dataSource = self
        tableview.delegate = self
        tableview.register(TransactionTableViewCell.nib(), forCellReuseIdentifier: TransactionTableViewCell.identifier)
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        
        print("Vào DetailWalletViewController - \(wallet?.getName ?? "")")
        setFrontEnd()
        setNavbar()
        transactions = []

//        bỏ các transaction của ví vào mảng -> đẩy lên table view
        setTransactions(data: (wallet?.getTransactions())!)
//        sắp xếp lại mảng
        transactions.sort { $0.getCreateAt > $1.getCreateAt }
        
        //                Lọc transactions theo ngày
        sections = createSections(from: transactions)
        
//        Kết nối
        tableview.dataSource = self
        tableview.delegate = self
        tableview.register(TransactionTableViewCell.nib(), forCellReuseIdentifier: TransactionTableViewCell.identifier)
        
        tableview.reloadData()
        
    }
    
    func createSections(from transactions: [Transaction]) -> [Section] {
        var sections: [Section] = []
        var currentSection: Section?
        
        for transaction in transactions {
            let date = Calendar.current.startOfDay(for: transaction.getCreateAt)
            
            // Check if currentSection is nil or the date has changed
            if currentSection == nil || currentSection!.date != date {
                // If the currentSection has transactions, append it to sections
                if let section = currentSection, !section.transactions.isEmpty {
                    sections.append(section)
                }
                // Create a new Section for the new date
                currentSection = Section(date: date, transactions: [])
            }
            
            // Add transaction to the current section
            currentSection?.transactions.append(transaction)
        }
        
        // Append the last section if it contains transactions
        if let section = currentSection, !section.transactions.isEmpty {
            sections.append(section)
        }
        
        return sections
    }
    func setTransactions(data: [Transaction]) {
        
        for i in data{
            transactions.append(i)
        }
    }
    func setFrontEnd() {
//        set ảnh
        wallet_img.image = wallet?.getImage
        wallet_name.text = wallet?.getName
        wallet_balance.text = (wallet?.Balance.getVNDFormat())
    }
    //Ham set navbar
    func setNavbar() {
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.backgroundColor = .white
    }

    /// Hàm chuyển đồ từ Date sang String
    func DateToString(_ date:Date) -> String{
        //      Lấy ra 1 biến Date ở thời gian hiện tại
        let currentDateAndTime = date
        //        Tạo ra 1 biến format
        let dateFormatter = DateFormatter()
        
        //        Ngày: 5/9/24
        dateFormatter.dateStyle = .medium
        
        //        Giờ none
        dateFormatter.timeStyle = .none
        
        //        Địa điểm
//        dateFormatter.locale = Locale(identifier: "vi_VN")
        
        
        
        
        return dateFormatter.string(from: currentDateAndTime)
    }
    /// Hàm Chuyển đổi từ String sang Date
    func StringToDate(_ str_date:String) -> Date? {
       let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "vi_VN")
        
        if let rs = dateFormatter.date(from: str_date){
            

            return rs
        }
        else
        {
            print("<<<<<String to Date KHÔNG THÀNH CÔNG - DetailWalletViewController>>>>>")
            return Date.now
        }
    }
    
    //MARK: event
    //nguoi dung an vao chinh sua vi
    @IBAction func edit_wallet_tapped(_ sender: UIButton) {
        //Lấy main.storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //qua man hinh de edit wallet (trong AddNewWalletControllor)
        let edit_wallet = storyboard.instantiateViewController(withIdentifier: "NewWallet") as! AddWalletViewController
        edit_wallet.detail_wallet = self.wallet
        edit_wallet.navigationItem.title = "Edit wallet"
        navigationController?.pushViewController(edit_wallet, animated: true)
    }
    //nguoi dung an xoa vi
    
    @IBAction func deleteWalletTapped(_ sender: UIBarButtonItem) {
        showConfirmDialog()
    }
    
    
    
    // ham hien thi dialog xac nhan xoa
    func showConfirmDialog() {
        let alertController = UIAlertController(title: "Delete wallet", message: "Are you sure you want to delete this wallet?", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
          
            if let tabBarController = self.tabBarController as? TabHomeViewController {
                if let userprofile = tabBarController.userProfile {
                    //kiem tra so luong vi co trong tai khoan
                    if (userprofile.Wallets.count > 1) {
                        //xoa giao dich o backend
                        Task {
                            await Wallet.deleteAWallet(userID: userprofile.getUID, walletId: self.wallet!.getID)
                        }
                        //thuc hien xoa giao dich o front end
                        if let index = userprofile.Wallets.firstIndex(where: {$0.getID == self.wallet?.getID}) {
                            print("index of current wallet in array: \(index)")
                            userprofile.Wallets.remove(at: index)
                            //tro ve
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    //thong bao loi khi nguoi dung chi con <= 1 vi
                    else {
                        let alertError = UIAlertController(title: "Error", message: "You must have at least one wallet in your account!", preferredStyle: .actionSheet)
                        alertError.addAction(UIAlertAction(title: "Ok", style: .cancel,handler: nil))
                        self.present(alertError, animated: true, completion: nil)
                        
                    }
                    
                }
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
}
extension DetailWalletViewController: UITableViewDataSource, UITableViewDelegate{
//    UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].transactions.count // Trả về số lượng giao dịch trong section đó
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let maximumString = 25
        let cell = tableview.dequeueReusableCell(withIdentifier: TransactionTableViewCell.identifier, for: indexPath) as! TransactionTableViewCell
        let transaction = sections[indexPath.section].transactions[indexPath.row]
        
        //Bỏ thông tin vào các UI của cell
        cell.transaction_name.text = transaction.getCategory.getName
        cell.transaction_img.image = transaction.getCategory.getImage
        cell.transaction_description.text = transaction.getDescription.getShorterString(max: maximumString)
        cell.transaction_balance.text = String(transaction.getBalance.getVNDFormat())
        cell.transaction_time.text = DateToString(transaction.getCreateAt)
        
        
        //        Nếu là thu nhập: Đổi màu chữ qua xanh
        if (transaction.getBalance > 0 && transaction.getCategory.getinCome){
            cell.transaction_balance.textColor = .green
        }
        else{
            cell.transaction_balance.textColor = .red
        }
        return cell
    }
    //    Hàm set title TODAY, YESTERDAY...
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: sections[section].date)
    }
   

    
    //  UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let transaction = sections[indexPath.section].transactions[indexPath.row]

        
        
        //Lấy main.storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        //        Màn hình màu xanh
        if (transaction.getBalance > 0 && transaction.getCategory.getinCome){
//            Lấy màn hình
            let detail_Income_ViewController = storyboard.instantiateViewController(withIdentifier: "detail_transaction_Income") as! DetailIncomeViewController
            
            //        set title cho navigation
            detail_Income_ViewController.navigationItem.title = "Detail Income Transaction"
            
            // Đổ dữ liệu qua màn hình
            detail_Income_ViewController.transaction = transaction
            
            // Đẩy màn hình vào hàng đợi... (chuyển màn hình)
            navigationController?.pushViewController(detail_Income_ViewController, animated: true)
            
        }
//        Màn hình màu đỏ
        else{
            let detail_Expense_ViewController = storyboard.instantiateViewController(withIdentifier: "detail_transaction_Expenses") as! DetailExpenseViewController
            
            detail_Expense_ViewController.navigationItem.title = "Detail Expenses Transaction"
            
            // Lấy màn hình cần chuyển qua
            detail_Expense_ViewController.transaction = transaction

            // Đẩy màn hình vào hàng đợi... (chuyển màn hình)
            navigationController?.pushViewController(detail_Expense_ViewController, animated: true)
            
        }
        
       
    }
}
struct Section {
    let date: Date
    var transactions: [Transaction]
}
