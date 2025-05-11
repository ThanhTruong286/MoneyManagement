import UIKit

class TransactionTableViewCell: UITableViewCell {

    @IBOutlet weak var transaction_balance: UILabel!
    @IBOutlet weak var transaction_name: UILabel!
    @IBOutlet weak var transaction_time: UILabel!
    @IBOutlet weak var transaction_description: UILabel!
    @IBOutlet weak var transaction_img: UIImageView!
    
    static let identifier = "TransactionTableViewCell"
    static func nib() -> UINib{
        return UINib(nibName: "TransactionTableViewCell", bundle: nil)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
