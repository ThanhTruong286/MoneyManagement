import UIKit

class WalletTableViewCell: UITableViewCell {

    @IBOutlet weak var Wallet_balace: UILabel!
    @IBOutlet weak var Wallet_name: UILabel!
    @IBOutlet weak var Wallet_img: UIImageView!
    static let identifier = "WalletTableViewCell"
    static func nib() -> UINib{
        return UINib(nibName: "WalletTableViewCell", bundle: nil)

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
