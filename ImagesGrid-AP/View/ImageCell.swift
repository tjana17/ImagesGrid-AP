//
//  ImageCell.swift
//  ImagesGrid-AP
//
//  Created by Janarthanan Kannan on 17/04/24.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    var representedIdentifier: String = ""
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
