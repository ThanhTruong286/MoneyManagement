import UIKit

class TabHomeViewController: UITabBarController {
    var userProfile:UserProfile? = nil
    var category_income:[Category] = []
    var category_expenses:[Category] = []
    var category_all:[Category] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Đọc category
        Task {
            category_income = await Category.getIncome()
            category_expenses = await Category.getExpenses()
            
            category_all = category_income + category_expenses
        }
    }
    //Hàm sử dụng để tìm đối tượng wallet từ Wallet_ID
    public func getWalletFromTransaction(wallet_ID:String)->Wallet?{
        if let userProfile = self.userProfile{
            for wallet in userProfile.Wallets{
                if wallet.getID == wallet_ID{
                    return wallet
                }
            }
        }
        return nil
    }
}
