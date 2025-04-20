//
//  Wallet.swift
//  ios-money-management
//
//  Created by AnNguyen on 09/05/2024.
//

import Foundation
import FirebaseFirestore
import UIKit

import FirebaseCore
import FirebaseFirestore
class Wallet {
//    MARK: Properties
    private let id:String
    private var name: String
    private var balance: Int
    private  var image: UIImage?
    private var transactions = [Transaction]()
    
//    MARK: Constructor
    init(ID: String, Name: String, Balance: Int, Image: UIImage?, Transaction: [Transaction]) {
        self.id = ID
        self.name = Name
        self.balance = Balance
        self.image = Image
        self.transactions = Transaction
    }
    var getID:String{
        get{
            return id
            
        }
    }
    var getImageName:String{
        get{
            return image?.imageAsset?.value(forKey: "assetName") as! String
            
        }
       
       
    }
    var getName:String{
        get{
            return name
        }
        set {
            self.name = newValue
        }
    }
    var Balance:Int{
        get{
            return balance
        }
        set{
            balance = newValue
        }
    }
    var getImage:UIImage?{
        get{
            return image
        }
        set {
                self.image = newValue
        }
    }
    var transactions_get_set:[Transaction]{
        get{
            return transactions
        }
        set{
            transactions = newValue
        }
    }
    

    
    
// MARK: Method
    func getTransactions() -> [Transaction] {
            return transactions
        }
    func addTransaction(transaction: Transaction) {
            transactions.append(transaction)
        }
    public func ToString(){
        print("Wallet: \(id) - \(name) - \(balance)")
    }
    
/// Lấy danh sách ví của người dùng
    public static func getMyWallets(UID:String) async -> [Wallet]?{
        let db = Firestore.firestore()
        let walletRef = db.collection("Wallets").document(UID).collection("Wallet")
        var myWallets = [Wallet]()
        
        do {
            let snapshot = try await walletRef.getDocuments()
            
            for i in snapshot.documents{
                
                await myWallets.append(
                    Wallet(
                        ID: i["ID"] as! String,
                        Name: i["Name"] as! String,
                        Balance:i["Balance"] as! Int,
                        Image: UIImage(named: i["Image"] as! String),
//                        lấy danh sách transaction của 1 ví
                        Transaction: Transaction.getAllMyTransactions(walletID: i.documentID)!
                    )
                )
                
            }
            return myWallets
        } catch {
            print("Lỗi truy vấn - getMyWallets: \(error)")
            return nil
        }
    }
    
   
    ///Tạo ví mới -> Trả ra ID của ví
    public static func createNewWallet(UID: String, balance:Int, image: String, name: String)async throws -> String{
        let db = Firestore.firestore()

        // Tạo một DocumentReference để lấy ID sau khi document được tạo
        let walletRef = db.collection("Wallets").document(UID).collection("Wallet").document()
        
        let walletData: [String: Any] = [
            "Balance": balance,
            "Image": image,
            "Name": name
        ]
        // Sử dụng transactionRef để thêm document
        try await walletRef.setData(walletData)

        // Cập nhật lại document với trường ID
        try await walletRef.updateData(["ID": walletRef.documentID])
        print("Wallet added successfully!")

        // Trả về ID wallet moisw
        return walletRef.documentID
        
    }

    //xoa vi
    static func deleteAWallet(userID UID: String, walletId walletID:String) async {
        let db = Firestore.firestore()
        
    //lay ra tat ca giao dich tren db bang walletID
    //xoa giao dich tren db
        let walletFromTransactions = db.collection("Transactions").document(walletID)
        let transactionsDocs = walletFromTransactions.collection("Transaction")
       //duyet for va xoa tung giao dich ben trong vi
        do {
            let snapshot =  try await transactionsDocs.getDocuments()
            for i in snapshot.documents{
//                print("called")
//               print(i["ID"] as! String)
                try await Transaction.deleteTransaction(walletID: walletID, transactionID: i["ID"] as! String)
            }
            
        } catch {
            print("Lỗi truy vấn - getMyWallets: \(error)")
        }
        //xoa vi sau khi xoa xong giao dich ben trong
        Task {
            do {
                try await walletFromTransactions.delete()
                }
            catch {
                print("Error deleting wallet: \(error)")
                // Xử lý lỗi
            }
        }
        
    //lay ra tat ca vi cua user
        let walletRef = db.collection("Wallets").document(UID)
        let walleDoc = walletRef.collection("Wallet").document(walletID)
        
    //xoa vi
        Task {
            do {
                try await walleDoc.delete()
                print("Wallet deleted successfully")
                // Thực hiện các hành động sau khi xóa thành công
            } catch {
                print("Error deleting wallet: \(error)")
                // Xử lý lỗi
            }
        }
        
    }
    /// Cập nhật lại thông tin wallet của UID
    static func set_updateWallet(UID:String, wallet: Wallet){
        let db = Firestore.firestore()
        let walletRef = db.collection("Wallets").document(UID)
        
        let walletDoc = walletRef.collection("Wallet").document(wallet.getID)
        
        // Dữ liệu mới của ví
            let walletData: [String: Any] = [
                "Name": wallet.getName,
                "Balance": wallet.Balance,
                "Image":wallet.getImageName,
                "ID": wallet.getID,
            ]

            // Cập nhật dữ liệu ví trên Firestore
            walletDoc.updateData(walletData) { error in
                if let error = error {
                    print("Error updating wallet: \(error)")
                } else {
                    print("Wallet updated successfully!")
                }
            }

    }
}
