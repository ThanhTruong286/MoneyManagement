//
//  TestViewController.swift
//  ios-money-management
//
//  Created by nguyenthanhnhan on 17/02/1403 AP.
//

import UIKit
import PhotosUI
class ViewCell: UICollectionViewCell {
    @IBOutlet weak var imgView: UIImageView!
}
class TestViewController: UIViewController, PHPickerViewControllerDelegate, UICollectionViewDataSource {
    @IBOutlet weak var cImages: UICollectionView! 
    var selectedImages:[UIImage] = []
    
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    


}
