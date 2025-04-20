//
//  TransactionTableViewController.swift
//  ios-money-management
//
//  Created by AnNguyen on 27/04/2024.
//

import UIKit

class TransactionTableViewController: UITableViewController {
//MARK: Properties
    var transactions = [Transaction]()
//    MARK: Load lần đầu
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Vào TransactionTableViewController")
        


    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return transactions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "TransactionTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier:
        cellIdentifier, for: indexPath) as? Transaction_TEMP_TableViewCell else {
        fatalError("Can not create the Cell!")
        }
        
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        let currentDate = Date()
        let formattedDate = dateFormatter.string(from: currentDate)
        cell.transaction_time.text = formattedDate
        

        return cell
    }
  
}
