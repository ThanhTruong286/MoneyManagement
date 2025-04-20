//
//  TransactionViewController.swift
//  ios-money-management
//
//  Created by AnNguyen on 06/05/2024.
//

import UIKit

class TransactionViewController: UIViewController {
    //    Cấu trúc để chia giao dịch theo ngày
    struct Section {
        let date: Date
        var transactions: [Transaction]
    }
    
    
    
    struct RangeTime{
        var time_from: Date?
        var time_to: Date?
    }
    //    Cấu trúc chia filter
    struct FilterState{
        //        left
        var filter_left: RangeTime?
        
        //        Right
        var isIncome: Bool?
        var sort_new: Bool = true
        var category_id: String?
        var wallet_id: String?
    }
    
    var currentFilterState = FilterState()
    
    //    MARK: Properties
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var filter_left: UIView!
    @IBOutlet weak var popup_cate: UIButton!
    @IBOutlet weak var filter_right: UIView!
    @IBOutlet weak var filter_opacity: UIView!
    
    @IBOutlet weak var popup_wallet: UIButton!
    @IBOutlet weak var btn_sortOld: UIButton!
    @IBOutlet weak var btn_sortNew: UIButton!
    @IBOutlet weak var btnCategory_Expenses: UIButton!
    @IBOutlet weak var btnCategory_Income: UIButton!
    @IBOutlet weak var time_from: UIDatePicker!
    @IBOutlet weak var time_to: UIDatePicker!
    //    Dữ liệu
    private var transactions = [Transaction]()
    private var wallets = [Wallet]()
    var sections: [Section] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Lấy UID
        let UID = UserDefaults.standard.string(forKey: "UID") ?? ""
        
        
        //debug
        print("Vào TransactionViewController - \(UID)")
        
        //        Lấy userProfile đang nằm trong Tabbar controller
        if let tabBarController = self.tabBarController as? TabHomeViewController {
            // Truy cập dữ liệu trong TabBarController
            if let userProfile = tabBarController.userProfile
            {
                for wallet in userProfile.Wallets {
                    setTransactions(data: wallet.getTransactions())
                }
                //                Sắp xếp mới nhất
                transactions.sort { $0.getCreateAt > $1.getCreateAt }
                
                //                Lọc transactions theo ngày
                sections = createSections(from: transactions)
            }
        }
        
        
        
        //        Setting cho table view
        tableview.dataSource = self
        tableview.delegate = self
        tableview.register(TransactionTableViewCell.nib(), forCellReuseIdentifier: TransactionTableViewCell.identifier)
        
        setFrontEnd()
        setCategory()
        setWallet()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Load lại TransactionViewController")
        // Set lại màu cho nav
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        self.tabBarController?.tabBar.isHidden = false
        
        
        
        
        
        
        
        
        
             
        
        //        Lấy userProfile đang nằm trong Tabbar controller
        if let tabBarController = self.tabBarController as? TabHomeViewController {
            // Truy cập dữ liệu trong TabBarController
            if let userProfile = tabBarController.userProfile
            {
                transactions = []
                for wallet in userProfile.Wallets {
                    setTransactions(data: wallet.getTransactions())
                }
                //                Sắp xếp mới nhất
                transactions.sort { $0.getCreateAt > $1.getCreateAt }
                
                //                Lọc transactions theo ngày
                sections = createSections(from: transactions)
            }
        }
        
        updateTransactions()
        
        //        Setting cho table view
        tableview.dataSource = self
        tableview.delegate = self
        tableview.register(TransactionTableViewCell.nib(), forCellReuseIdentifier: TransactionTableViewCell.identifier)
        
        setFrontEnd()
        setCategory()
        setWallet()
        tableview.reloadData()
    }
    /// Hàm chuyển đồ từ Date sang String
    func DateToString(_ date:Date) -> String{
        // Lấy ra 1 biến Date ở thời gian hiện tại
        let currentDateAndTime = date
        // Tạo ra 1 biến format
        let dateFormatter = DateFormatter()
        
        // Ngày: 5/9/24
        dateFormatter.dateStyle = .medium
        
        // Giờ none
        dateFormatter.timeStyle = .none
        
        // Địa điểm
//        dateFormatter.locale = Locale(identifier: "vi_VN")
        
        
        
        
        return dateFormatter.string(from: currentDateAndTime)
    }
    func setFrontEnd() {
        time_to.maximumDate = Date()
        time_from.maximumDate = Date()
        
        btn_sortNew.backgroundColor = UIColor(red: 118/255, green: 64/255, blue: 246/255, alpha: 1.0)
        btn_sortNew.layer.cornerRadius = 20
        
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
    ///Nạp tất cả transaction được truyền vào vào mảng transactions để đổ lên table view
    func setTransactions(data: [Transaction]) {
        
        for i in data{
            transactions.append(i)
        }
    }
    func setWallet()  {
        if let tabBarController = self.tabBarController as? TabHomeViewController {
            if let wallets = tabBarController.userProfile?.Wallets{
                //            Đổ dữ liệu vào pop up
                let actions = wallets.map { wallet in
                    UIAction(title: wallet.getName, image: wallet.getImage) { [weak self] action in
                        guard let self = self else { return } // Tránh strong reference cycle

                        self.currentFilterState.wallet_id = wallet.getID
                        self.popup_wallet.setAttributedTitle(NSAttributedString(string: action.title), for: .normal)
                        
                    }
                    
                }
                // Tạo UIAction "Tất cả" và thêm vào đầu danh sách
                        let allAction = UIAction(title: "All", state: .on) { [weak self] action in
                            guard let self = self else { return }
                            
                            self.currentFilterState.wallet_id = nil
                            self.popup_wallet.setAttributedTitle(NSAttributedString(string: action.title), for: .normal)

                        }
                //            set pop up
                popup_wallet.menu = UIMenu(children: [allAction] + actions)
                popup_wallet.showsMenuAsPrimaryAction = true
                
            }
        }
       
            
    }
        
    func setCategory()  {
        //        Lấy userProfile đang nằm trong Tabbar controller
        if let tabBarController = self.tabBarController as? TabHomeViewController {
            
//Khai báo mảng chứa category sẽ đẩy lên pop up
            var categories:[Category] = []
//            nếu người dùng không chọn category income/expenses
            if currentFilterState.isIncome == nil{
//                Lấy hết
                categories = tabBarController.category_all
            }
            else{
//                lấy income
                if currentFilterState.isIncome!{
                    categories = tabBarController.category_income
                }
//                lấy expenses
                else{
                    categories = tabBarController.category_expenses
                }
            }
            
            //            Đổ dữ liệu vào pop up
            let actions = categories.map { category in
                UIAction(title: category.getName, image: category.getImage) { [weak self] action in
                    guard let self = self else { return } // Tránh strong reference cycle

                    self.currentFilterState.category_id = category.getID
                    self.popup_cate.setAttributedTitle(NSAttributedString(string: action.title), for: .normal)
                    
                }
                
            }
            
            // Tạo UIAction "Tất cả" và thêm vào đầu danh sách
                    let allAction = UIAction(title: "All", state: .on) { [weak self] action in
                        guard let self = self else { return }
                        
                        self.currentFilterState.category_id = nil
                        self.popup_cate.setAttributedTitle(NSAttributedString(string: action.title), for: .normal)

                    }
            //            set pop up
            popup_cate.menu = UIMenu(children: [allAction] + actions)
            popup_cate.showsMenuAsPrimaryAction = true
            
            
        }
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
            print("<<<<<String to Date KHÔNG THÀNH CÔNG - TransactionViewController>>>>>")
            return Date.now
        }
    }
    
    
    @IBAction func btn_left_tapped(_ sender: Any) {
        // Nếu filter_left đang hiển thị, ẩn nó đi
        if !filter_left.isHidden {
            filter_left.isHidden = true
            filter_opacity.isHidden = true // Ẩn filter_opacity
        } else {
            // Nếu filter_left đang ẩn, hiển thị nó và ẩn filter_right (nếu đang hiển thị)
            filter_left.isHidden = false
            filter_right.isHidden = true
            filter_opacity.isHidden = false // Hiển thị filter_opacity
        }
    }
    
    @IBAction func btn_right_tapped(_ sender: Any) {
        // Nếu filter_right đang hiển thị, ẩn nó đi
        if !filter_right.isHidden {
            filter_right.isHidden = true
            filter_opacity.isHidden = true // Ẩn filter_opacity
        } else {
            // Nếu filter_right đang ẩn, hiển thị nó và ẩn filter_left (nếu đang hiển thị)
            filter_right.isHidden = false
            filter_left.isHidden = true
            filter_opacity.isHidden = false // Hiển thị filter_opacity
        }
    }
    
    @IBAction func time_from_ValueChange(_ sender: UIDatePicker) {
        
        time_to.minimumDate = time_from.date
    }
    
    @IBAction func time_to_ValueChange(_ sender: UIDatePicker) {
        
        
    }
    
    
    @IBAction func btnCategory_Expenses_Tapped(_ sender: UIButton) {
        //        Xoá active button Income
        btnCategory_Income.backgroundColor = .white
        btnCategory_Income.layer.cornerRadius = 20
        
        
        //        Bật active button expenses
        sender.backgroundColor = UIColor(red: 253/255, green: 60/255, blue: 74/255, alpha: 1.0) // Đổi màu nền
        sender.layer.cornerRadius = 20
        
        //        bật biến filter
        currentFilterState.isIncome = false
        popup_cate.setAttributedTitle(NSAttributedString(string: "All"), for: .normal)
        currentFilterState.category_id = nil
        setCategory()
    }
    @IBAction func btnCategory_Income_Tapped(_ sender: UIButton) {
        //        Xoá active button expenses
        btnCategory_Expenses.backgroundColor = .white
        btnCategory_Expenses.layer.cornerRadius = 20
        
        
        //        Bật active button income
        sender.backgroundColor = UIColor(red: 0/255, green: 168/255, blue: 107/255, alpha: 1.0) // Đổi màu nền
        sender.layer.cornerRadius = 20
        //        bật biến filter
        currentFilterState.isIncome = true
        popup_cate.setAttributedTitle(NSAttributedString(string: "All"), for: .normal)
        currentFilterState.category_id = nil
//        set pop up
        setCategory()
    }
    
    
    @IBAction func btn_reset_tapped(_ sender: UIButton) {
        //        new lại đối tượng mới
        currentFilterState = FilterState()
        
        //        xoá giao diện filter category
        btnCategory_Expenses.backgroundColor = .white
        btnCategory_Expenses.layer.cornerRadius = 20
        
        btnCategory_Income.backgroundColor = .white
        btnCategory_Income.layer.cornerRadius = 20
        
        
        //        reset giao diện filter sort by
        btn_sortNew.backgroundColor = UIColor(red: 118/255, green: 64/255, blue: 246/255, alpha: 1.0)
        btn_sortNew.layer.cornerRadius = 20
        
        btn_sortOld.backgroundColor = .white
        
//        Gọi lại hàm set category -> Lấy tất cả category
            popup_cate.setAttributedTitle(NSAttributedString(string: "All"), for: .normal)
        currentFilterState.category_id = nil
        setCategory()
        
        
        popup_wallet.setAttributedTitle(NSAttributedString(string: "All"), for: .normal)
        setWallet()

        
    }
    @IBAction func btn_submit_right_tapped(_ sender: UIButton) {
        
        
        // Ẩn view chứa các date picker
        filter_left.isHidden = true
        filter_opacity.isHidden = true
        
        // Cập nhật table view
        updateTransactions()
    }
    
    @IBAction func btn_sortOld_tapped(_ sender: UIButton) {
        btn_sortOld.backgroundColor = UIColor(red: 118/255, green: 64/255, blue: 246/255, alpha: 1.0)
        btn_sortOld.titleLabel?.textColor = .white
        btn_sortOld.layer.cornerRadius = 20
        btn_sortNew.backgroundColor = .white
        btn_sortNew.titleLabel?.textColor = .black
        currentFilterState.sort_new = false
    }
    @IBAction func btn_sortNew_tapped(_ sender: UIButton) {
        btn_sortNew.backgroundColor = UIColor(red: 118/255, green: 64/255, blue: 246/255, alpha: 1.0)
        btn_sortNew.layer.cornerRadius = 20
        btn_sortNew.titleLabel?.textColor = .white
        btn_sortOld.backgroundColor = .white
        btn_sortOld.titleLabel?.textColor = .black
        currentFilterState.sort_new = true
    }
    
    @IBAction func btn_submit_left_tapped(_ sender: UIButton) {
        //        Lấy thời gian người dùng chọn
        let time_from_selected = time_from.date
        let time_to_selected = time_to.date
        
        // Điều chỉnh time_from_selected về 0 giờ sáng
        let calendar = Calendar.current
        let timeFromStartOfDay = calendar.startOfDay(for: time_from_selected) // 00:00:00
        
        // Điều chỉnh time_to_selected về 23:59:59
        if let timeToEndOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: time_to_selected) {
            // ... (rest of the code remains the same)
            
            currentFilterState.filter_left = RangeTime(time_from: timeFromStartOfDay, time_to: timeToEndOfDay)
        } else {
            // Xử lý lỗi nếu không thể tính toán timeToEndOfDay
            print("Error calculating end of day for time_to_selected")
            let alertController = UIAlertController(title: "Error", message: "Error calculating end of day for time_to_selected.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true, completion: nil)
        }
        
        
        
        
        //        // Nếu time_from_selected lớn hơn hoặc bằng time_to_selected
        //        if DateToString(time_from.date) == DateToString(time_to.date) {
        //            // Hiện ra cảnh báo cho người dùng
        //            let alertController = UIAlertController(title: "Lỗi", message: "Thời gian bắt đầu phải nhỏ hơn thời gian kết thúc.", preferredStyle: .alert)
        //            alertController.addAction(UIAlertAction(title: "OK", style: .default))
        //            present(alertController, animated: true, completion: nil)
        //            return // Thoát khỏi hàm nếu không hợp lệ
        //        }
        
        
        
        
        
        // Nếu hợp lệ
        //            currentFilterState.filter_left = RangeTime(time_from: time_from_selected, time_to: time_to_selected)
        
        // Ẩn view chứa các date picker
        filter_left.isHidden = true
        filter_opacity.isHidden = true
        
        // Cập nhật table view
        updateTransactions()
    }
    
    func updateTransactions(){
        //        Tạo 1 bản sao của toàn bộ transactions
        var filteredTransactions = transactions
        
        //        filter bên trái: Có lựa chọn nào
        if (currentFilterState.filter_left !=  nil){
            // Lọc các giao dịch theo thời gian
            filteredTransactions = transactions.filter { transaction in
                return (currentFilterState.filter_left?.time_from!)! <= transaction.getCreateAt && transaction.getCreateAt <= (currentFilterState.filter_left?.time_to!)!
            }        }
        
        
        
        
        //       Category có sự lựa chọn True False
        if currentFilterState.isIncome != nil{
            
            //            Nếu lựa chọn Income
            if currentFilterState.isIncome!{
                filteredTransactions = filteredTransactions.filter { $0.getCategory.getinCome == true } // Lọc các giao dịch có isIncome = true
            }
            else{
                filteredTransactions = filteredTransactions.filter { $0.getCategory.getinCome == false } // Lọc các giao dịch có isIncome = true
            }
        }
        
//        Nếu category được chọn
        if currentFilterState.category_id != nil{
            filteredTransactions = filteredTransactions.filter {$0.getCategory.getID == currentFilterState.category_id}
        }
        
//        Nếu wallet được chọn
        if currentFilterState.wallet_id != nil{
            filteredTransactions = filteredTransactions.filter{
                $0.getWalletID == currentFilterState.wallet_id
            }
        }
        
        
        
        
        
        //        Mặc định để mới nhất
        filteredTransactions.sort { $0.getCreateAt > $1.getCreateAt }
        //        Nếu không phải mới nhất -> Cũ nhất
        if (!currentFilterState.sort_new){
            filteredTransactions.sort { $0.getCreateAt < $1.getCreateAt }
        }
        sections = createSections(from: filteredTransactions)
        tableview.reloadData()
    }
}
extension TransactionViewController: UITableViewDataSource, UITableViewDelegate{
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
