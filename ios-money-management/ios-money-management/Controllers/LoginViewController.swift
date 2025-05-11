import UIKit
import FirebaseAuth
class LoginViewController: UIViewController {
    //MARK: @IBOutlet
    @IBOutlet weak var txt_username: UITextField!
    @IBOutlet weak var txt_password: UITextField!
    
    @IBOutlet weak var view_loading: UIView!
    @IBOutlet weak var view_opacity: UIView!
    
    //MARK: Load lần đầu
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Debug
        print("Vào Login View Controller")
        
        //Ẩn loading
        view_opacity.isHidden = true
        view_loading.isHidden = true
        
        //Set title cho navigation
        self.navigationItem.title = "Login"
    }
    
    //MARK: IBAction
    //TA: Show password
    @IBAction func btn_password_tapped(_ sender: UIButton) {
        //Nếu đang được chọn
        if sender.isSelected{
            //Chuyển thành mở mắt
            sender.setImage(UIImage(named: "eye-solid"), for: .normal)
        }
        else{
            //Chuyển thành đóng mắt
            sender.setImage(UIImage(named: "eye-slash-solid"), for: .normal)
        }
        
        //Đảo ngược tính chất của ảnh button và textfield
        sender.isSelected = !sender.isSelected
        txt_password.isSecureTextEntry = !txt_password.isSecureTextEntry
    }
    //TA: Hàm đăng nhập
    @IBAction func btn_login(_ sender: UIButton) {
        //Kiểm tra xem giá trị văn bản có nil hay không. Nếu nil, câu lệnh sẽ thực thi khối mã else.
        guard let email = txt_username.text else {return}
        guard let password = txt_password.text else {return}
        
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            //Nếu có lỗi
            if let error = error {
                print("Eror: \(error)")
                
                //Hiện ra cảnh báo cho người dùng
                let alertController = UIAlertController(title: "Error", message: "Login error.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alertController, animated: true, completion: nil)
                
                //Thoát khỏi hàm nếu không hợp lệ
                return
                
                //Nếu không lỗi và trả ra kết quả xác thực
            } else if let authResult = authResult {
                //Đăng nhập thành công, lấy ID của người dùng
                let userId = authResult.user.uid
                
                print("User login with ID: \(userId)")
                
                //Set key value UID: là id người dùng
                UserDefaults.standard.set(userId, forKey: "UID")
                //Hiển thị loading
                self.view_opacity.isHidden = false
                self.view_loading.isHidden = false
                
                //Thực thi khối mã bên trong ở 1 Thread khác
                Task{
                    
                    //Gọi hàm lấy userProfile từ UID
                    if let userProfile = await UserProfile.getUserProfine(UID: userId){
                        
                        //Lấy màn hình main storyboard
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        
                        //Lấy controller TabHomeController
                        let vc = storyBoard.instantiateViewController(withIdentifier: "TabBarHomeController") as! TabHomeViewController
                        
                        //Cho màn hình full màn hình
                        vc.modalPresentationStyle = .fullScreen
                        
                        //Gán giá trị controller là userProfile
                        vc.userProfile = userProfile
                        
                        //Ẩn loading
                        self.view_opacity.isHidden = true
                        self.view_loading.isHidden = true
                        //Chuyển màn hình: Hiển thị 1 view controller mới dưới dạng 1 màn hình che phủ toàn bộ màn hình hiện tại
                        //VC mới nằm trên cùng của VC hiện tại, nhưng ko thuộc navigation stack
                        self.present(vc, animated: true )
                        
                        //Xoá mật khẩu
                        self.txt_password.text = nil
                    }
                }
            }
        }
    }
}
