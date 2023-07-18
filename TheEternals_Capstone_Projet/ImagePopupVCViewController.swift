//
//  ImagePopupVCViewController.swift
//  TheEternals_Capstone_Projet
//
//  Created by Sai Snehitha Bhatta on 27/03/22.
//

import UIKit

class ImagePopupVCViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    var img: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        if (img != nil) {
            image.image = img
        }
    }
    
    @IBAction func tappedOutside(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
