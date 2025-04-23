import Foundation
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import SDWebImage


class UserProfile {
//    MARK: Properties
    private let UID: String
    private var fullname: String
    private var avatar: UIImage?
    private var wallets = [Wallet]()

//    MARK: Constructor
    init(UID: String, fullname: String, avatar: UIImage?, wallets: [Wallet] = [Wallet]()) {
        self.UID = UID
        self.fullname = fullname
        self.avatar = avatar
        self.wallets = wallets
    }
    var getUID:String{
        get{
            return UID
        }
    }
    var Fullname:String{
        get{
            return fullname
        }
        set{
            self.fullname = newValue
        }
    }
    var Avatar:UIImage?{
        get{
            return avatar
        }
        set{
            self.avatar = newValue
        }
    }
    var Wallets:[Wallet]{
        get{
            return wallets
        }
        set{
            wallets = newValue
        }
    }
    
    
// MARK: Method
    /// Hàm cập nhật lại Fullname, avatarURL lên trên Firestore
    public static func updateUserProfile(UID:String, fullname:String, avatarURL: String){
//Kết nối DB
        let db = Firestore.firestore()
                let profileRef = db.collection("Profile").document(UID)
//        Cập nhật data
                profileRef.updateData([
                    "Fullname": fullname,
                    "Avatar": avatarURL
                ]) { error in
                    if let error = error {
                        print("Error updating user profile: \(error)")
                    } else {
                        print("User profile updated successfully!")
                    }
                }
    }
    
    ///Tạo 1 doccument Profile trên DB (Đăng ký) -> Trả ra ID của userProfile
    public static func createUserProfile(userProfile: UserProfile) async throws -> String {
//        Kết nối DB
        let db = Firestore.firestore()
        

        
        // Tạo dictionary chứa dữ liệu hồ sơ
        let profileData: [String: Any] = [
            "ID": userProfile.getUID,
            "Fullname": userProfile.Fullname,
//            Nếu chưa có avatar: Gán avatar mặc định
            "Avatar": userProfile.Avatar ?? "https://firebasestorage.googleapis.com:443/v0/b/moneymanager-885d2.appspot.com/o/images%2Favatar_default.png?alt=media&token=da4b8328-2b7e-4067-b7af-daa8e40d8c9d"
        ]
        
        // Tạo tài liệu mới trong collection "Profile"
        let documentRef = db.collection("Profile").document(userProfile.getUID)
        
        // Ghi dữ liệu vào tài liệu mới
        try await documentRef.setData(profileData)
        
        print("User profile created with ID: \(userProfile.getUID)")
        return userProfile.getUID
    }
    
    
/// Lấy userProfile bằng UID (Đăng nhập)
    public static func getUserProfine(UID: String) async -> UserProfile? {
        let db = Firestore.firestore()
        let profileRef = db.collection("Profile").document(UID)
        
        do {
//            Lấy dữ liệu người dùng
            let snapshot = try await profileRef.getDocument()
//Kiểm tra xem có dữ liệu trong tài liệu hay không.
            guard let data = snapshot.data() else { return nil }
            
            
//            Lấy thông tin người dùng
            let fullName = data["Fullname"] as? String ?? ""
//            Mặc định avatar là defalt
            var avatarImage = UIImage(named: "avatar_default")
            
//            Lấy URL ảnh đại diện từ dữ liệu
            let avatar_url = data["Avatar"] as! String
//            Kiểm tra tính hợp lệ của URL. Nếu không hợp lệ, in ra thông báo lỗi và trả về nil
            guard let imageUrl = URL(string: avatar_url) else {
                    print("Download ảnh thất bại")
                    return nil
                }
                
                do {
                    // Tải dữ liệu ảnh (Data) từ URL
                    let (imageData, _) = try await URLSession.shared.data(from: imageUrl)

//Tạo UIImage từ imageData và gán vào avatarImage
                    if let image = UIImage(data: imageData) {
                        avatarImage = image
                    }
                } catch {
                    print("Error loading image: \(error.localizedDescription)")
                    return nil
                }

            
            
            print("Truy vấn thành công getUserProfine")
            return await UserProfile(UID: UID, fullname: fullName, avatar: avatarImage, wallets: Wallet.getMyWallets(UID: UID)!)
        } catch {
            print("Lỗi truy vấn - getUserProfine: \(error)")
            return nil
        }
        
    }
    public func ToString(){
        
        
        print("---------")
        print("User: \(UID) - \(Fullname)")
        for i in Wallets{
            print(i.ToString())
        }
        print("---------")
    }
}
