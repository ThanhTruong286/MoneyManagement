import Foundation
import UIKit
import FirebaseCore
import FirebaseFirestore
class Category{
    //    MARK: Properties

    private let ID:String
    private let Name:String
    private let Image: UIImage?
    private let inCome: Bool
    //    MARK: Constructor

    init(ID: String, Name: String, Image: UIImage?, inCome: Bool) {
        self.ID = ID
        self.Name = Name
        self.Image = Image
        self.inCome = inCome
    }
    
    var getID:String{
        get{
            return ID
        }
    }
    var getName:String{
        get{
            return Name
        }
    }
    var getinCome:Bool{
        get{
            return inCome
        }
    }
    var getImage:UIImage?{
        get{
            return Image
        }
    }
    //    MARK: Method
//    Lấy 1 đối tượng Category từ ID
    public static func getCategory(Category_ID:String) async -> Category?{
        let db = Firestore.firestore()

        let categoryRef = db.collection("Category").document(Category_ID)
        
        do{
            let snapshot = try await categoryRef.getDocument() // Lấy tất cả documents
            guard let data = snapshot.data() else { return nil } // Không tìm thấy hồ sơ
            
            return  Category(ID: data["ID"] as! String, Name: data["Name"] as! String , Image: UIImage(named: data["Image"] as! String), inCome: data["isIncome"] as! Bool)
            
        }
        catch{
            print("Lỗi truy vấn - getCategory: \(error)")
            return nil
            
        }
    }
//    Lấy danh sách category Income
    public static func getIncome() async -> [Category] {
        let db = Firestore.firestore()
        let cateRef = db.collection("Category").whereField("isIncome", isEqualTo: true)
        var income = [Category]()
        do {
            let querySnapshot = try await cateRef.getDocuments()
            for document in querySnapshot.documents {
                let data = document.data()
                income.append(Category(ID: data["ID"] as! String, Name: data["Name"] as! String, Image: UIImage(named: data["Image"] as! String), inCome: true))
            }
        } catch {
            print("Lỗi khi truy vấn: \(error)")
            // Xử lý lỗi tại đây
        }
        return income
    }
    // Lấy danh sách category Expenses
    public static func getExpenses() async -> [Category] {
        let db = Firestore.firestore()
        let cateRef = db.collection("Category").whereField("isIncome", isEqualTo: false)
        var expenses = [Category]()

        do {
            let querySnapshot = try await cateRef.getDocuments()
            
            for document in querySnapshot.documents {
                let data = document.data()

                // Kiểm tra và ép kiểu an toàn cho các trường dữ liệu
                if let id = data["ID"] as? String,
                   let name = data["Name"] as? String,
                   let imageName = data["Image"] as? String,
                   let image = UIImage(named: imageName) {  // Kiểm tra xem ảnh có tồn tại không
                    // Nếu tất cả dữ liệu hợp lệ, thêm vào danh sách
                    expenses.append(Category(ID: id, Name: name, Image: image, inCome: false))
                } else {
                    // Nếu có dữ liệu thiếu hoặc không hợp lệ, in ra thông báo
                    print("Lỗi dữ liệu không hợp lệ: \(data)")
                }
            }
        } catch {
            print("Lỗi khi truy vấn: \(error)")
            // Xử lý lỗi tại đây
        }
        
        return expenses
    }

}
