import UIKit
import FirebaseAuth
import FirebaseFirestore
class SignUpViewController: UIViewController {
    //MARK: @IBOutlet
    @IBOutlet weak var txt_name: UITextField!
    @IBOutlet weak var txt_password: UITextField!
    @IBOutlet weak var txt_email: UITextField!
    
    @IBOutlet weak var btn_SignUp: UIButton!
    
    
    //MARK: Load lần đầu
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Debug
        print("Vào SignUpViewController")
        
        //Set title cho navigation
        self.navigationItem.title = "Sign Up"
        
        //Name
        txt_name.layer.borderColor = UIColor.black.cgColor
        txt_name.layer.borderWidth = 0.5
        txt_name.layer.cornerRadius = 10.0
        
        //Email
        txt_email.layer.borderColor = UIColor.black.cgColor
        txt_email.layer.borderWidth = 0.5
        txt_email.layer.cornerRadius = 10.0
        
        //Password
        txt_password.layer.borderColor = UIColor.black.cgColor
        txt_password.layer.borderWidth = 0.5
        txt_password.layer.cornerRadius = 10.0
    }
    
    //MARK: @IBAction
    //TA: checkbox
    @IBAction func btn_check_tapped(_ sender: UIButton) {
        //Mac dinh hinh anh
        if sender.isSelected{
            sender.setImage(UIImage(named: "checkbox_false"), for: .normal)
        }
        else{
            sender.setImage(UIImage(named: "checkbox_true"), for: .normal)
        }
        sender.isSelected = !sender.isSelected
        
    }
    //TA:: Show password
    @IBAction func btn_ShowPassword_tapped(_ sender: UIButton) {
        if sender.isSelected{
            sender.setImage(UIImage(named: "eye-slash-solid"), for: .normal)
            
        }
        else{
            sender.setImage(UIImage(named: "eye-solid"), for: .normal)
        }
        sender.isSelected = !sender.isSelected
        txt_password.isSecureTextEntry = !txt_password.isSecureTextEntry
    }
    
    //TA: Đăng ký
    @IBAction func btn_SignUp_tapped(_ sender: UIButton) {
        //Kiểm tra xem giá trị văn bản từ txt_email.text có nil hay không. Nếu nil, câu lệnh sẽ thực thi khối mã else.
        guard let email = txt_email.text else {return}
        guard let password = txt_password.text else {return}
        
        //Kiểm tra + Thông báo cho người dùng trường fullname không được để trống
        if txt_name.text! == ""{
            let alertController = UIAlertController(title: "Registration error", message: "The full name field cannot be empty", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            present(alertController, animated: true, completion: nil)
            
            return //Thoát khỏi hàm nếu không hợp lệ
        }
        
        
        Auth.auth().createUser(withEmail: email, password: password) { [self] (authResult, error) in //closure (Hàm đóng), truyền cho createUser và được gọi lại sau khi quá trình tạo tài khoản hoàn tất, với hai tham số trên
            
            if let error = error {
                //In lỗi ở log
                print("Registration error: \(error.localizedDescription)")
                
                //Hiện ra cảnh báo cho người dùng
                let alertController = UIAlertController(title: "Error", message: "Registration error", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default))
                present(alertController, animated: true, completion: nil)
                return //Thoát khỏi hàm nếu không hợp lệ
                
                
            } else if let authResult = authResult {
                //Đăng ký thành công, lấy ID của người dùng
                let userId = authResult.user.uid
                
                //Lấy fullname
                if let fullname = txt_name.text
                {
                    //Tạo 1 đối tượng userProfile
                    let userProfile = UserProfile(UID: userId, fullname: fullname, avatar: nil)
                    
                    //Chạy trên thread khác
                    Task {
                        
                        //do-catch: xử lý ngoại lệ
                        do {
                            //try: Từ khóa này được đặt trước một biểu thức có thể ném ra lỗi.
                            //Tạo userProfile mới trên db -> trả ra ID
                            let _ =   try await UserProfile.createUserProfile(userProfile: userProfile)
                            
                            //Tạo ví mới mặc định cho người dùng trên DB -> Trả ra ID ví
                            let _ =    try await Wallet.createNewWallet(UID: userId, balance: 0, image: "cash", name: "Cash")
                            
                            //Trở ra màn hình
                            navigationController?.popViewController(animated: true)
                            
                        } catch {
                            
                            print("Tạo userProfile thất bại")
                            
                            let alertController = UIAlertController(title: "Error", message: "Create user profile failed", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .default))
                            present(alertController, animated: true, completion: nil)
                            return //Thoát khỏi hàm nếu không hợp lệ
                        }
                    }
                    print("User created with ID: \(userId)")
                }
            }
        }
    }
}
