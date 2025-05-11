import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController {
    //MARK: @IBOutlet
    @IBOutlet weak var btn_Continue: UIButton!
    @IBOutlet weak var txt_email: UITextField!
    //MARK: Load lần đầu
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Vào ForgotPasswordViewController")
        
        self.navigationItem.title = "Forgot Password"
    }
    
    //MARK: @IBAction
    //TA: Gửi mã OTP
    @IBAction func continueTapped(_ sender: Any) {
        
        guard let email = txt_email.text else{return}
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error == nil {
                //Hiện ra thông báo đã send OTP cho người dùng
                let alertController = UIAlertController(title: "Sent", message: "Password reset email has been sent, please check again.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alertController, animated: true, completion: nil)
                
            }
            else
            {
                guard let error = error else{return}

                print(error)
                let alertController = UIAlertController(title: "Error", message: "Error sent OTP.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alertController, animated: true, completion: nil)
                
                
            }
            
        }
        
    }
    
}
