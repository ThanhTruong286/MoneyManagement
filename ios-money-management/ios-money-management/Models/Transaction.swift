import Foundation
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

class Transaction  {
//    MARK: Properties
    private let id:String
    private var description:String
    private var balance: Int
    private let category: Category
    private let create_at:Date
    private let wallet_id: String
    private  var images: [UIImage]?
    

    public func toString(){
        print("\(self.id) - \(self.description) - \(self.balance) - \(self.category.getName) - \(self.create_at) || Ví \(wallet_id)")
    }
//    MARK: Constructor
    init(id: String, description: String, balance: Int, category: Category, create_at: Date, wallet_id: String, images: [UIImage]) {
        self.id = id
        self.description = description
        self.balance = balance
        self.category = category
        self.create_at = create_at
        self.wallet_id = wallet_id
        self.images = images
    }

    var getID:String{
        get{
            return id
            
        }
    }
    var Images:[UIImage]{
        get{
            return self.images!
        }
        set{
            self.images = newValue
        }
    }
    var getWalletID:String{
        get{
            return wallet_id
            
        }
    }
    var getDescription:String{
        get{
            return description
        }
    }
    var getBalance:Int{
        get{
            return balance
        }
    }
    var getCategory:Category{
        get{
            return category
        }
    }
    var getCreateAt:Date{
        get{
            return create_at
        }
    }
//    MARK: Method
    
///Hàm này có nhiệm vụ tải lên một mảng các ảnh (UIImage) vào Firebase Storage
    /// Trả về một mảng các URL ([String]) của các ảnh đó sau khi tải lên thành công.
    /// async throws: Hàm là bất đồng bộ (có thể đợi) và có thể ném ra lỗi.
    public static func uploadImagesToStorage(images: [UIImage]) async throws -> [String] {
//       Lưu trữ các URL của ảnh sẽ trả về
        var imageUrls: [String] = []
//        reference đến root của Firebase Storage.
        let storageRef = Storage.storage().reference()

//        Duyệt danh sách ảnh
        for image in images {
//(UUID().uuidString): 1 chuỗi ngẫu nhiên
//storageRef.child: Tạo 1 ref đến thư mục images trong storage
            let imageRef = storageRef.child("images/\(UUID().uuidString).jpg")

//            Chuyển đổi UI Image thành dữ liệu jpg với độ nén là xx
//             guard let: Kiểm tra xem việc chuyển đổi có thành công hay không, nếu không -> else
            guard let imageData = image.jpegData(compressionQuality: 0.001) else {
                print("Chuyển đổi UI Image thành JPEG data thất bại!!!")
                throw NSError(domain: "YourAppDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error converting image to data"])
            }
        //try await: Đợi cho đến khi quá trình tải ảnh lên Storage hoàn tất.
        //Lấy imageData là ảnh UI Image vừa chuyển đổi ở trên -> lên Storage theo đường dẫn imageRef
            _ = try await imageRef.putDataAsync(imageData)
//Lấy URL của ảnh trên Firebase Storage
            let downloadURL = try await imageRef.downloadURL()
            
            imageUrls.append(downloadURL.absoluteString)
        }

        return imageUrls
    }

    /// Lấy tất cả giao dịch của 1 ví
    public static func getAllMyTransactions(walletID:String) async -> [Transaction]?{
//        Kết nối đến DB
        let db = Firestore.firestore()
        let walletRef = db.collection("Transactions").document(walletID).collection("Transaction")
//        Mảng chứa các giao dịch của 1 ví sẽ được trả về
        var myTransactions = [Transaction]()
        
//        do-catch: xử lý các lỗi có thể xảy ra trong quá trình truy vấn và tải ảnh.
        do {
//            Lấy tất cả doccument của transaction trong 1 ví
            let snapshot = try await walletRef.getDocuments()
//            Duyệt danh sách các giao dịch
            for transaction in snapshot.documents{
//                Mảng UI Image để gán vào fiel của trans
                var arr_image_transaction:[UIImage] = []
//                Duyệt danh sách URL
                for image_url in transaction["imageUrls"] as! Array<String>{
//                    Tải ảnh xuống
                    guard let imageUrl = URL(string: image_url) else {
                            print("Download ảnh thất bại")
                            return nil
                        }
                    do {
                        let (imageData, _) = try await URLSession.shared.data(from: imageUrl)
//                        Tạo đối tượng UIImage từ imageData nếu thành công.
                        if let image = UIImage(data: imageData) {
//                            Nạp vào mảng UI Image
                            arr_image_transaction.append(image)
                        }
                    } catch {
                        print("Error loading image: \(error.localizedDescription)")
                        return nil
                    }

                }
//  Hoàn thành tải ảnh
                
//Tạo đối tượng Transaction và thêm vào mảng myTransactions:
                await myTransactions.append(
                    Transaction(
                        id: transaction["ID"] as! String,
                        description:  transaction["Description"] as! String,
                        balance: transaction["Balance"] as! Int,
//await => Tìm đối tượng Category từ fiel categoryID
                        category: Category.getCategory(Category_ID: (transaction["Category_ID"] as! String))!,
                        create_at: (transaction["CreateAt"] as? Timestamp)?.dateValue() ?? Date(),
                        wallet_id: walletID,
//                        mảng ui image ở trên
                        images:arr_image_transaction
                    )
                )
            }
            
            return myTransactions
        } catch {
            print("Lỗi truy vấn - getMyWallets: \(error)")
            return nil
        }
    }
    ///  Xóa một giao dịch khỏi Firestore, bao gồm cả việc xóa các hình ảnh liên quan nếu có
    public static func deleteTransaction(walletID: String, transactionID: String) async throws {
//        Trỏ đến giao dịch cần xoá
        let db = Firestore.firestore()
        let transactionRef = db.collection("Transactions").document(walletID).collection("Transaction").document(transactionID)
        
//        Lấy thông tin giao dịch
        let transactionData = try await transactionRef.getDocument()
        
//        Lấy mảng url image của giao dịch
        if let imageUrls = transactionData.get("imageUrls") as? [String] {
//            Duyệt urls
            for imageUrl in imageUrls {
//                Xoá ảnh từ URL
                try await deleteImageFromStorage(urlString: imageUrl)
            }
        }
//        Xoá giao dịch
        try await transactionRef.delete()
        
        print("Transaction deleted successfully!")
    }

        /// Hàm xóa ảnh khỏi Storage từ URL
        private static func deleteImageFromStorage(urlString: String) async throws {
//            Chuyển đổi chuỗi URL thành đối tượng URL
            guard let _ = URL(string: urlString) else {return}
//            Kết nối đến ảnh từ url
            let storageRef = Storage.storage().reference(forURL: urlString)
//            xoá ảnh
            try await storageRef.delete()
        }
    /// Hàm chuyển đồ từ Date sang String
    func DateToString(str_date date:Date) -> String{
        // Lấy ra 1 biến Date ở thời gian hiện tại
        let currentDateAndTime = date
        // Tạo ra 1 biến format
        let dateFormatter = DateFormatter()
        
        // Ngày: 5/9/24
        dateFormatter.dateStyle = .short
        
        // Giờ none
        dateFormatter.timeStyle = .none
        
        // Địa điểm
//        dateFormatter.locale = Locale(identifier: "vi_VN")
        
        
        
        return dateFormatter.string(from: currentDateAndTime)
    }
    /// Hàm Chuyển đổi từ String sang Date
    func StringToDate(_ str_date:String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateStyle = .short
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
    ///Hàm ghi 1 giao dịch mới lên DB trong wallet_id, bao gồm tải ảnh lên Storage
    ///Và trả về 1 String là ID của giao dịch mới được khởi tạo
    public static func addTransaction(wallet_id:String, balance:Int, category_id:String, des:String, images: [UIImage], created_at:Date )async throws -> String{
            let db = Firestore.firestore()
            
            // Tạo một DocumentReference để lấy ID sau khi document được tạo
            let transactionRef = db.collection("Transactions").document(wallet_id).collection("Transaction").document()
            
        // Tải ảnh lên Storage và lấy URL
        let imageUrls = try await uploadImagesToStorage(images: images)
        
            let transactionData: [String: Any] = [
                "Balance": balance,
                "Category_ID": category_id,
                "Description": des,
                "CreateAt": created_at,
                "imageUrls": imageUrls // Lưu mảng URL vào Firestore

            ]
            // Sử dụng transactionRef để thêm document
            try await transactionRef.setData(transactionData)

            // Cập nhật lại document với trường ID
            try await transactionRef.updateData(["ID": transactionRef.documentID])
            print("Transaction added successfully!")

            return transactionRef.documentID // Trả về ID giao dịch mới
                
    }
}
