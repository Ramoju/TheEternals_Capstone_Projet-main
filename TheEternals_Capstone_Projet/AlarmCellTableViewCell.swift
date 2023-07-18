//
//  AlarmCellTableViewCell.swift
//  TheEternals_Capstone_Projet
//
//  Created by Keerthi Pavan Valluri on 2022-03-21.
//

import UIKit

protocol alarmCellDelegate {
    func didChangeSwitch(with id: String, enabled: Bool)
}

class AlarmCellTableViewCell: UITableViewCell {
    
    var delegate: alarmCellDelegate?
    var alarmid: String!

    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var afterFood: UILabel!
    @IBOutlet weak var enabled: UISwitch!
    @IBOutlet weak var medicines: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var medimage: UIImageView!
    
    
    
    @IBAction func alarmSwitchChanged(_ sender: UISwitch) {
        delegate?.didChangeSwitch(with: alarmid, enabled: sender.isOn)
    }
    
    
    func setCell(picture: UIImage, timeValue: String, afterFoodValue: String, medicinesValue: String, enabledValue: Bool,  alarmid: String){
        self.alarmid = alarmid
        medimage.image = picture
        time.text = timeValue
        afterFood.text = afterFoodValue
        medicines.text = medicinesValue
        enabled.setOn(enabledValue, animated: true)
        
        cardView.layer.shadowColor = UIColor.clear.cgColor
        cardView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        cardView.layer.cornerRadius = 14
        cardView.layer.shadowOpacity = 1.0
        cardView.layer.masksToBounds = false
    }
    
}
