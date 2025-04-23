import Foundation
import FirebaseFirestore

func setupSampleData() {
    let db = Firestore.firestore()

    // MARK: - Category
    let categories = [
        ["ID": "1", "Name": "Ăn uống", "Image": "food_icon", "isIncome": false],
        ["ID": "2", "Name": "Giải trí", "Image": "entertainment_icon", "isIncome": false],
        ["ID": "3", "Name": "Lương", "Image": "salary_icon", "isIncome": true],
        ["ID": "4", "Name": "Mua sắm", "Image": "shopping_icon", "isIncome": false],
        ["ID": "5", "Name": "Đầu tư", "Image": "investment_icon", "isIncome": true]
    ]

    for cat in categories {
        db.collection("Category").document(cat["ID"] as! String).setData(cat)
    }

    // MARK: - User (example)
    let userId = "example_user_01"
    let userProfile = [
        "ID": userId,
        "Name": "Người dùng mẫu",
        "Email": "sample@example.com",
        "Avatar": "default_avatar"
    ]
    db.collection("User").document(userId).setData(userProfile)

    // MARK: - Transaction
    let sampleTransactions = [
        [
            "ID": "txn1",
            "UserID": userId,
            "CategoryID": "1",
            "Amount": 50000,
            "Note": "Cà phê Highland",
            "Date": Timestamp(date: Date()),
            "isIncome": false
        ],
        [
            "ID": "txn2",
            "UserID": userId,
            "CategoryID": "3",
            "Amount": 10000000,
            "Note": "Lương tháng 4",
            "Date": Timestamp(date: Date()),
            "isIncome": true
        ]
    ]

    for txn in sampleTransactions {
        db.collection("Transaction").document(txn["ID"] as! String).setData(txn)
    }

    print("✅ Đã thêm dữ liệu mẫu Category, User, và Transaction.")
}
