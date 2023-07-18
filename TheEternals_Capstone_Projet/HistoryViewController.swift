//
//  HistoryViewController.swift
//  TheEternals_Capstone_Projet
//
//  Created by Keerthi Pavan Valluri on 2022-03-26.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController {

    //TableViews
    @IBOutlet weak var historyTV: UITableView!
    
    //Buttons
    @IBOutlet weak var sortbyBTN: UIButton!
    
    var alarmhistory = [History]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemGray3.cgColor]

        view.layer.insertSublayer(gradientLayer, at: 0)
        
        setPopupButton()
        gethistoryData()
    }
    
    func setPopupButton(){
        let optionsClosure = {(action: UIAction) in
            if(action.title == "Last 2 days"){
                
            } else if(action.title == "Last 5 days"){
                
            }else {
                
            }
        }
        sortbyBTN.menu = UIMenu(children: [UIAction(title: "Last 2 days", state: .on, handler: optionsClosure),
            UIAction(title: "Last 5 days",handler: optionsClosure),
            UIAction(title: "Last 7 days",handler: optionsClosure)])
        sortbyBTN.showsMenuAsPrimaryAction = true
        sortbyBTN.changesSelectionAsPrimaryAction = true
        
    }
    
    func gethistoryData(){
        let request:NSFetchRequest<History> = History.fetchRequest()
        do {
            self.alarmhistory = try context.fetch(request)
        } catch {
            print("Error load items ... \(error.localizedDescription)")
        }
        
        DispatchQueue.main.async{
            self.historyTV.reloadData()
        }
    }

}


extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (alarmhistory.count == 0){
            self.historyTV.setEmptyMessage("")
        } else {
            historyTV.restore()
        }
        return alarmhistory.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historycell", for: indexPath) as! AlarmHistoryCell
        if(alarmhistory[indexPath.row].taken){
            cell.statusIndicator.image = UIImage(systemName: "checkmark.circle.fill")
        }
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MMM d, h:mm a"
        cell.medicineName.text = alarmhistory[indexPath.row].medicinename
        cell.alarmtime.text = dateFormater.string(from: alarmhistory[indexPath.row].time!)
        // add border and color
        cell.backgroundColor = UIColor.white
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        return cell
    }
}
