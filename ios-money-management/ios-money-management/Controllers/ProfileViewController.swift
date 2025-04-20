
import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
//MARK: Properties
    @IBOutlet weak var settingTableView: UITableView!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var cornerTable: UIView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var fullname: UILabel!
    var settings:[[String:Any]] = [
        ["setting_name": "Wallet", "setting_icon": "iconWallet"],
        ["setting_name": "Setting", "setting_icon": "iconSetting"],
        ["setting_name": "Logout", "setting_icon": "iconLogout"]
    ]
    var userProfile:UserProfile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Lấy UID
        let UID = UserDefaults.standard.string(forKey: "UID") ?? ""
        print("Vào ProfileViewController - \(UID)")
        //        Lấy userProfile đang nằm trong Tabbar controller
        if let tabBarController = self.tabBarController as? TabHomeViewController {
            // Truy cập dữ liệu trong TabBarController
            if let userProfile = tabBarController.userProfile
            {
                        self.image.image = userProfile.Avatar
                        self.fullname.text = userProfile.Fullname
                        self.userProfile = userProfile
            }
            
        }
        

        
        setFrontEnd()
        settingTableView.dataSource = self
        settingTableView.delegate = self
        
    }
  
    func setFrontEnd(){
        //cau hinh cho avatar
        imageView.layer.borderWidth = 2
        imageView.layer.masksToBounds = true
        
        //rgba(173, 0, 255, 1)
        imageView.layer.borderColor = CGColor(red: 173/255, green: 0/255, blue: 255/255, alpha: 1)
        imageView.layer.cornerRadius = imageView.frame.height/2

        image.layer.cornerRadius = image.frame.height/2
        //settingTableView.dataSource = self
        //settingTableView.delegate = self
        
        cornerTable.layer.cornerRadius = 16
        cornerTable.layer.masksToBounds = true
    }
    func setUserInfo () {
        Task{
            if let UID = UserDefaults.standard.string(forKey: "UID") {
                if let user =  await UserProfile.getUserProfine(UID: UID){
                    self.image.image = user.Avatar
                    self.fullname.text = user.Fullname
                    
                }
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        print("Load lại ProfileViewController")
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
        
        tabBarController?.tabBar.isHidden = false
        
        
        //        Lấy userProfile đang nằm trong Tabbar controller
        if let tabBarController = self.tabBarController as? TabHomeViewController {
            // Truy cập dữ liệu trong TabBarController
            if let userProfile = tabBarController.userProfile
            {
                        self.image.image = userProfile.Avatar
                        self.fullname.text = userProfile.Fullname
                        self.userProfile = userProfile
            }
            
        }
    }
    //MARK: implementing classes
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        Lấy main story board
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
//        Chuyển màn hình khi nhấn
        if indexPath.row == 0{
            //        Lấy màn hình cần chuyển qua
            let view_controller = storyboard.instantiateViewController(withIdentifier: "AccountWallets")
            //        set title cho navigation
            view_controller.navigationItem.title = "Account"
            //        Đẩy màn hình vào hàng đợi... (chuyển màn hình)
            navigationController?.pushViewController(view_controller, animated: true)
            //        self.present(view_controller, animated: true)
            
        }
        else if indexPath.row == 1{
            
            //        Lấy màn hình cần chuyển qua
            let view_controller = storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
            //        set title cho navigation
            view_controller.navigationItem.title = "Edit Profile"
            
            view_controller.userProfile = userProfile
            //        Đẩy màn hình vào hàng đợi... (chuyển màn hình)
            navigationController?.pushViewController(view_controller, animated: true)
            //        self.present(view_controller, animated: true)
        }
        else if indexPath.row == 2{
            dismiss(animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuse = "SettingCell"
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuse, for: indexPath) as? SettingCell {
            if let imgStr = settings[indexPath.row]["setting_icon"], let nameStr = settings[indexPath.row]["setting_name"] {
                cell.selectionStyle = .none
                cell.settingImage.image = UIImage(named: imgStr as! String)
                cell.settingName.text = nameStr as? String
                return cell
            }
        }
        fatalError("Khong the return")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
