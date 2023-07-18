//
//  ImageCollectionViewCell.swift
//  TheEternals_Capstone_Projet
//
//  Created by Sai Snehitha Bhatta on 27/03/22.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    public func setData(image: UIImage?) {
        self.imageView.image = image
    }
    
}
