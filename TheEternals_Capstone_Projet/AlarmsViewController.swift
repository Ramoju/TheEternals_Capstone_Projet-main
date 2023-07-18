//
//  AlarmsViewController.swift
//  TheEternals_Capstone_Projet
//
//  Created by Sravan Sriramoju on 2022-03-20.
//

import UIKit
import CoreData

class AlarmsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, alarmCellDelegate {
    func didChangeSwitch(with id: String, enabled: Bool) {
        var curralarm: Alarm!
        for alarm in allalarms{
            if(alarm.alarmid == id){
                curralarm = alarm
                alarm.enabled = enabled
            }
        }
        do {
            try context.save()
        } catch{
            print("error updating alarm")
        }
        if (!enabled){
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        } else {
            CreateReminder(alarm: curralarm)
        }
    }
    

    @IBOutlet weak var searchBar: UISearchBar!
    

    @IBOutlet weak var allAlarmsTV: UITableView!
    var cellimage:UIImage!
    
    private var allalarms = [Alarm]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemGray3.cgColor]

        view.layer.insertSublayer(gradientLayer, at: 0)
        getAlarms()
        allAlarmsTV.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(allalarms.count == 0){
            self.allAlarmsTV.setEmptyMessage("No alarms created")
        } else {
            allAlarmsTV.restore()
        }
        return allalarms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellimage:UIImage!
        var celltime:String = ""
        let cell = tableView.dequeueReusableCell(withIdentifier: "alarmcell", for: indexPath) as! AlarmCellTableViewCell
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm"
        if let v = allalarms[indexPath.row].time {
            celltime = timeFormatter.string(from: v)
        }
        let pics = allalarms[indexPath.row].pictures?.allObjects as! [Images]
        if (pics.count > 0){
        if let imageData = pics[0].image{
            cellimage = UIImage(data:imageData,scale:0.1)
        }
        }
        cell.delegate = self
        cell.setCell(picture: cellimage ?? UIImage(), timeValue: celltime, afterFoodValue: allalarms[indexPath.row].whentotake ?? "", medicinesValue: allalarms[indexPath.row].title ?? "", enabledValue: allalarms[indexPath.row].enabled, alarmid: allalarms[indexPath.row].alarmid ?? "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete"){(action, view, completionHandler) in
            let alarmtoRemove = self.allalarms[indexPath.row]
            self.context.delete(alarmtoRemove)
            do {
                try self.context.save()
            }catch{
                print("Error deleting record")
            }
            self.getAlarms()
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "add") as? NewAlarmViewController else {
            return
        }
        vc.completion = { createdalarm in
            self.navigationController?.popToRootViewController(animated: true)
            self.allAlarmsTV.reloadData()
        }
        vc.alarmToEdit = allalarms[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func getAlarms(){
        let request:NSFetchRequest<Alarm> = Alarm.fetchRequest()
        do {
            self.allalarms = try context.fetch(request)
        } catch {
            print("Error load items ... \(error.localizedDescription)")
        }
        DispatchQueue.main.async{
            self.allAlarmsTV.reloadData()
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.allAlarmsTV.reloadData()
        }
    }
    
    func CreateReminder(alarm: Alarm) {
        var notificationimage: UIImage!
        var alarmimages = [Images]()
        DispatchQueue.main.async {
        let content = UNMutableNotificationContent()
        content.title = "MedAlarm Reminder"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(alarm.audio ?? ""))
        content.body = "Time to have \(alarm.title ?? "")"
        alarmimages = alarm.pictures?.allObjects as! [Images]
        if (!alarmimages.isEmpty){
            notificationimage = self.resizeImage(image: UIImage(data: alarmimages[0].image!)!, targetSize: CGSize(width: 800, height: 800))
        }
        if let notifpic = notificationimage {
            if let attachment = UNNotificationAttachment.create(identifier: alarm.title ?? "", image: notifpic, options: nil) {
            content.attachments = [attachment]
        }
        }
            let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: alarm.time!), repeats: false)
            if let id = alarm.alarmid {
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
            if(error != nil){
                print(error?.localizedDescription ?? "")
            }
        })
        }
    }
}
    
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x:0, y:0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }

}

// Extensions

extension UITableView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}

extension AlarmsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            getAlarms()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }else{
            searchAlarms(searchText: searchText)
        }
    }
    
    func searchAlarms( searchText: String){
        
        let request:NSFetchRequest<Alarm> = Alarm.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
        print(searchText)
        request.predicate = predicate
        do {
            self.allalarms = try context.fetch(request)
        } catch
        let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        allAlarmsTV.reloadData()
    }
    
}
