//
//  TodayAlarmCell.swift
//  TheEternals_Capstone_Projet
//
//  Created by Ashish reddy mula on 15/03/22.
//

import UIKit

protocol todayCellDelegate {
    func didChangeSwitch(with id: String, enabled: Bool)
}

class TodayAlarmCell: UITableViewCell {
    
    var delegate: todayCellDelegate?
    var alarmid: String!

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var medimage: UIImageView!
    
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var afterFood: UILabel!
    
    @IBOutlet weak var medicines: UILabel!
    
    @IBOutlet weak var enabled: UISwitch!
    
    @IBAction func alarmSwitchTapped(_ sender: UISwitch) {
        delegate?.didChangeSwitch(with: alarmid, enabled: sender.isOn)
    }
    
    
    func setCell(picture: UIImage, timeValue: String, afterFoodValue: String, medicinesValue: String, enabledValue: Bool, alarmid: String){
        self.alarmid = alarmid
        medimage.image = picture
        time.text = timeValue
        afterFood.text = afterFoodValue
        medicines.text = medicinesValue
        enabled.setOn(enabledValue, animated: true)
        
        cardView.layer.shadowColor = UIColor.gray.cgColor
        cardView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        cardView.layer.cornerRadius = 14
        cardView.layer.shadowOpacity = 1.0
        cardView.layer.masksToBounds = false
    }

}
