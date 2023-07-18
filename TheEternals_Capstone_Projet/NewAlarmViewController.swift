//
//  NewAlarmViewController.swift
//  TheEternals_Capstone_Projet
//
//  Created by Sai Snehitha Bhatta on 20/03/22.
//

import UIKit
import CoreData
import AVFoundation

class NewAlarmViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate  {
    
    //StackViews
    @IBOutlet weak var datesVStackview: UIStackView!
    @IBOutlet weak var weekdaysStackView: UIStackView!
    @IBOutlet weak var alarmToneHStackView: UIStackView!
    @IBOutlet weak var picturesHStackView: UIStackView!
    @IBOutlet weak var repeatStackView: UIStackView!
    
    //collectionsView
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    //Constraints
    @IBOutlet weak var weekdaysSVConstraint: NSLayoutConstraint!
    @IBOutlet weak var alarmToneHSHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var picturesHSHeightConstraint: NSLayoutConstraint!
    
    //TextFields
    @IBOutlet weak var alarmTitle: UITextField!
    
    //Switches
    @IBOutlet weak var snoozeSwitch: UISwitch!
    @IBOutlet weak var repeatFlag: UISwitch!
    
    //Buttons
    @IBOutlet weak var sundayButton: UIButton!
    @IBOutlet weak var mondayButton: UIButton!
    @IBOutlet weak var TuesdayButton: UIButton!
    @IBOutlet weak var wednesdayButton: UIButton!
    @IBOutlet weak var thursdayButton: UIButton!
    @IBOutlet weak var fridayButton: UIButton!
    @IBOutlet weak var saturdayButton: UIButton!
    @IBOutlet weak var recordBtnLB: UIButton!
    @IBOutlet weak var playBtnLB: UIButton!
    @IBOutlet weak var showAudioOptionsBTN: UIButton!
    @IBOutlet weak var showPicturesOptionsBTN: UIButton!
    @IBOutlet weak var whentoTake: UIButton!
    
    //DatePickers
    @IBOutlet weak var alarmTime: UIDatePicker!
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var endDate: UIDatePicker!
    
    var imagePicker = UIImagePickerController()
    var defaultWeekdaysSVheight = 0.0
    var defaultAudioOptionsSVheight = 0.0
    var defaultPicturesOptionsSVheight = 0.0
    var alarmToEdit: Alarm!
    private var recordingSession: AVAudioSession!
    private var recorder: AVAudioRecorder!
    private var player =  AVAudioPlayer()
    private var audioFileName = ""
    private var notificationimage: UIImage!
    private var alarmimages = [Images]()
    private var repeatdays = [Repeatdays]()
    private var newAlarm: Alarm!
    private var notificationpermissiongranted: Bool = false
    public var completion: ((Alarm) -> Void)?

    var alarms = [Alarm]()

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let notificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemGray3.cgColor]
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        notificationCenter.requestAuthorization(options: [.sound, .alert, .badge], completionHandler: {success, error in
            if(success){
                self.notificationpermissiongranted = true
            }else if error != nil{
                print("error occured")
            }
        })
        
        setPopupButton()
        
        defaultWeekdaysSVheight = weekdaysSVConstraint.constant
        defaultAudioOptionsSVheight = alarmToneHSHeightConstraint.constant
        defaultPicturesOptionsSVheight = picturesHSHeightConstraint.constant
        
        sundayButton.layer.cornerRadius = sundayButton.frame.width/2
        mondayButton.layer.cornerRadius = mondayButton.frame.width/2
        TuesdayButton.layer.cornerRadius = TuesdayButton.frame.width/2
        wednesdayButton.layer.cornerRadius = wednesdayButton.frame.width/2
        thursdayButton.layer.cornerRadius = thursdayButton.frame.width/2
        fridayButton.layer.cornerRadius = fridayButton.frame.width/2
        saturdayButton.layer.cornerRadius = thursdayButton.frame.width/2
        
        weekdaysSVConstraint.constant = 0.0
        alarmToneHSHeightConstraint.constant = 0.0
        picturesHSHeightConstraint.constant = 0.0
        
        if(alarmToEdit == nil){
        sundayButton.backgroundColor = .clear
        mondayButton.backgroundColor = .clear
        TuesdayButton.backgroundColor = .clear
        wednesdayButton.backgroundColor = .clear
        thursdayButton.backgroundColor = .clear
        fridayButton.backgroundColor = .clear
        saturdayButton.backgroundColor = .clear
        }

        
        if (alarmToEdit == nil){
        newAlarm = Alarm(context: self.context)
        }
        startDate.minimumDate = Date()
        endDate.minimumDate = Date()
        datesVStackview.layer.cornerRadius = 8
        recordingSession = AVAudioSession.sharedInstance()
        if(alarmToEdit != nil){
            self.title = "Edit Reminder"
            populateFields()
        }
    }
    
    
    @IBAction func repeatFlagIsON(_ sender: UISwitch) {
        if(alarmToEdit != nil){
            alarmToEdit.repeatflag = repeatFlag.isOn
        } else {
        newAlarm.repeatflag = repeatFlag.isOn
        }
        if (repeatFlag.isOn){
            let bIsHidden = weekdaysStackView.isHidden

            if bIsHidden {
                weekdaysStackView.isHidden = false
            }

            UIView.animate(withDuration: 0.3, animations: {
                self.weekdaysSVConstraint.constant = self.weekdaysSVConstraint.constant > 0 ? 0 : self.defaultWeekdaysSVheight
                self.view.layoutIfNeeded()
            })
        } else {
            repeatdays.removeAll()
            let bIsHidden = weekdaysStackView.isHidden
            
            if !bIsHidden {
                weekdaysStackView.isHidden = true
            }

            UIView.animate(withDuration: 0.3, animations: {
                self.weekdaysSVConstraint.constant = 0.0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    
    @IBAction func snoozeSwitchTapped(_ sender: UISwitch) {
        if(alarmToEdit != nil){
            alarmToEdit.snoozeflag = snoozeSwitch.isOn
        } else {
            newAlarm.snoozeflag = snoozeSwitch.isOn
        }
      }
    
    
    
    @IBAction func recordBtnClicked(_ sender: UIButton) {
        if(alarmToEdit != nil){
        if let file = alarmToEdit.audio, !file.isEmpty{
            if (recordBtnLB.titleLabel?.text == "Record"){
            let alert = UIAlertController(title: "Alert", message: "A recorded tone already exists for this alarm, Do you want to change it?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { [self]action in
                do {
                    try self.recordingSession.setCategory(.playAndRecord, mode: .default)
                    try self.recordingSession.setActive(true)
                    self.recordingSession.requestRecordPermission() { [unowned self] allowed in
                        DispatchQueue.main.async {
                            if allowed {
                                self.startRec()
                            } else {
                                self.showAlert(message: "Microphone permission denied")
                            }
                        }
                    }
                } catch {
                    showAlert(message: "Recording failed")
                }
                
            }))
            alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
            else {
                recorder?.stop()
                recorder = nil
                recordBtnLB.setTitle("Record", for: .normal)
                recordBtnLB.setImage(UIImage(systemName: "mic.fill"), for: .normal)
            }
        }
        } else {
        if (recordBtnLB.titleLabel?.text == "Record"){
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.startRec()
                    } else {
                        self.showAlert(message: "Microphone permission denied")
                    }
                }
            }
        } catch {
            showAlert(message: "Recording failed")
        }
        }
        else {
            recorder?.stop()
            recorder = nil
            recordBtnLB.setTitle("Record", for: .normal)
            recordBtnLB.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        }
        }
    }
    
    
    @IBAction func playBtnClicked(_ sender: UIButton) {
        if playBtnLB.titleLabel?.text == "Play" {
            playBtnLB.setTitle("Stop", for: .normal)
            playBtnLB.setImage(UIImage(systemName: "stop.fill"), for: .normal)
            setupPlayer()
            player.play()
        } else {
            player.stop()
            playBtnLB.setTitle("Play", for: .normal)
            playBtnLB.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    
    @IBAction func cameraBtnClicked(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        }
        else {
            showAlert(message: "Camera not available")
        }
    }
    
    
    @IBAction func galleryBtnClicked(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    
    @IBAction func didTapSave() {
        guard let name = alarmTitle.text, !name.isEmpty else{
            showAlert(message: "Title for Alarm is required")
            return
        }
        
        if (alarmToEdit == nil) {
        newAlarm.alarmid = UUID().uuidString
        newAlarm.title = alarmTitle.text
        newAlarm.startdate = startDate.date
        newAlarm.enddate = endDate.date
        newAlarm.snoozeflag = snoozeSwitch.isOn
        newAlarm.repeatflag = repeatFlag.isOn
        newAlarm.time = alarmTime.date
        newAlarm.audio = audioFileName
        newAlarm.enabled = true
        newAlarm.pictures = Set(alarmimages) as NSSet
        newAlarm.repeatdays = Set(repeatdays) as NSSet
            if(repeatFlag.isOn){
                if(sundayButton.backgroundColor != .clear){
                    let day  = Repeatdays(context: self.context)
                    day.day = "Sunday"
                    day.parentalarm = newAlarm
                    repeatdays.append(day)
                }
                if(mondayButton.backgroundColor != .clear){
                    let day  = Repeatdays(context: self.context)
                    day.day = "Monday"
                    day.parentalarm = newAlarm
                    repeatdays.append(day)
                }
                if(TuesdayButton.backgroundColor != .clear){
                    let day  = Repeatdays(context: self.context)
                    day.day = "Tuesday"
                    day.parentalarm = newAlarm
                    repeatdays.append(day)
                }
                if(wednesdayButton.backgroundColor != .clear){
                    let day  = Repeatdays(context: self.context)
                    day.day = "Wednesday"
                    day.parentalarm = newAlarm
                    repeatdays.append(day)
                }
                if(thursdayButton.backgroundColor != .clear){
                    let day  = Repeatdays(context: self.context)
                    day.day = "Thursday"
                    day.parentalarm = newAlarm
                    repeatdays.append(day)
                }
                if(fridayButton.backgroundColor != .clear){
                    let day  = Repeatdays(context: self.context)
                    day.day = "Friday"
                    day.parentalarm = newAlarm
                    repeatdays.append(day)
                }
                if(saturdayButton.backgroundColor != .clear){
                    let day  = Repeatdays(context: self.context)
                    day.day = "Saturday"
                    day.parentalarm = newAlarm
                    repeatdays.append(day)
                }
                newAlarm.repeatdays = Set(repeatdays) as NSSet
            }
        self.saveData()
        completion?(newAlarm)
        } else {
            alarmToEdit.time = alarmTime.date
            alarmToEdit.title = alarmTitle.text
            alarmToEdit.startdate = startDate.date
            alarmToEdit.enddate = endDate.date
            alarmToEdit.snoozeflag = snoozeSwitch.isOn
            alarmToEdit.repeatflag = repeatFlag.isOn
            alarmToEdit.pictures = Set(alarmimages) as NSSet
            alarmToEdit.repeatdays = Set(repeatdays) as NSSet
            if(alarmToEdit.repeatflag){
                if(sundayButton.backgroundColor != .clear){
                    let day  = Repeatdays(context: self.context)
                    day.day = "Sunday"
                    day.parentalarm = newAlarm
                    repeatdays.append(day)
                }
                if(mondayButton.backgroundColor != .clear){
                    let day  = Repeatdays(context: self.context)
                    day.day = "Monday"
                    day.parentalarm = newAlarm
                    repeatdays.append(day)
                }
                if(TuesdayButton.backgroundColor != .clear){
                    let day  = Repeatdays(context: self.context)
                    day.day = "Tuesday"
                    day.parentalarm = newAlarm
                    repeatdays.append(day)
                }
                if(wednesdayButton.backgroundColor != .clear){
                    let day  = Repeatdays(context: self.context)
                    day.day = "Wednesday"
                    day.parentalarm = newAlarm
                    repeatdays.append(day)
                }
                if(thursdayButton.backgroundColor != .clear){
                    let day  = Repeatdays(context: self.context)
                    day.day = "Thursday"
                    day.parentalarm = newAlarm
                    repeatdays.append(day)
                }
                if(fridayButton.backgroundColor != .clear){
                    let day  = Repeatdays(context: self.context)
                    day.day = "Friday"
                    day.parentalarm = newAlarm
                    repeatdays.append(day)
                }
                if(saturdayButton.backgroundColor != .clear){
                    let day  = Repeatdays(context: self.context)
                    day.day = "Saturday"
                    day.parentalarm = newAlarm
                    repeatdays.append(day)
                }
                alarmToEdit.repeatdays = Set(repeatdays) as NSSet
            }
            self.saveData()
            completion?(alarmToEdit)
        }
    }
    
    
    @IBAction func didTapCancel() {
        if(alarmToEdit == nil) {
        self.context.delete(newAlarm)
        do {
            try self.context.save()
            print("Deleted empty row")
        }catch{
            print("Error deleting record")
        }
    }
        navigationController?.popToRootViewController(animated: true)
        //self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func didTapShowAudioOptions(_ sender: UIButton) {
        if (alarmToneHSHeightConstraint.constant == 0.0){
            sender.setImage(UIImage(systemName: "chevron.up.circle"), for: .normal)
            let hiddenflag = alarmToneHStackView.isHidden
            alarmToneHStackView.isHidden = !hiddenflag

        UIStackView.animate(withDuration: 0.3, animations: {
            self.alarmToneHSHeightConstraint.constant = self.alarmToneHSHeightConstraint.constant > 0 ? 0 : self.defaultAudioOptionsSVheight
            self.view.layoutIfNeeded()
        })
        } else if (alarmToneHSHeightConstraint.constant > 0.0){
            sender.setImage(UIImage(systemName: "chevron.down.circle"), for: .normal)
            let bIsHidden = alarmToneHStackView.isHidden
            
            if !bIsHidden {
                alarmToneHStackView.isHidden = true
            }

            UIView.animate(withDuration: 0.3, animations: {
                self.alarmToneHSHeightConstraint.constant = 0.0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    
    @IBAction func didTapShowPicturesOptions(_ sender: UIButton) {
        if (picturesHSHeightConstraint.constant == 0.0){
            sender.setImage(UIImage(systemName: "chevron.up.circle"), for: .normal)
            let hiddenflag = picturesHStackView.isHidden
            picturesHStackView.isHidden = !hiddenflag
            let picturesshown = imagesCollectionView.isHidden
            imagesCollectionView.isHidden = !picturesshown

        UIStackView.animate(withDuration: 0.3, animations: {
            self.picturesHSHeightConstraint.constant = self.picturesHSHeightConstraint.constant > 0 ? 0 : self.defaultPicturesOptionsSVheight
            self.view.layoutIfNeeded()
        })
        } else if (picturesHSHeightConstraint.constant > 0.0){
            sender.setImage(UIImage(systemName: "chevron.down.circle"), for: .normal)
            let bIsHidden = picturesHStackView.isHidden

            if !bIsHidden {
                picturesHStackView.isHidden = true
                imagesCollectionView.isHidden = true
            }

            UIView.animate(withDuration: 0.3, animations: {
                self.picturesHSHeightConstraint.constant = 0.0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func SundayClicked(_ sender: UIButton) {
        if(sender.backgroundColor != .clear){
            sender.backgroundColor = .clear
        } else {
            sender.backgroundColor = UIColor.systemGray
        }
    }
    
    @IBAction func MondayClicked(_ sender: UIButton) {
        if(sender.backgroundColor != .clear){
            sender.backgroundColor = .clear
        } else {
            sender.backgroundColor = UIColor.systemGray
        }
    }
    @IBAction func TuesdayClicked(_ sender: UIButton) {
        if(sender.backgroundColor != .clear){
            sender.backgroundColor = .clear
        } else {
            sender.backgroundColor = UIColor.systemGray
        }
    }
    @IBAction func WednesdayClicked(_ sender: UIButton) {
        if(sender.backgroundColor != .clear){
            sender.backgroundColor = .clear
        } else {
            sender.backgroundColor = UIColor.systemGray
        }
    }
    @IBAction func ThursdayClicked(_ sender: UIButton) {
        if(sender.backgroundColor != .clear){
            sender.backgroundColor = .clear
        } else {
            sender.backgroundColor = UIColor.systemGray
        }
    }
    @IBAction func FridayClicked(_ sender: UIButton) {
        if(sender.backgroundColor != .clear){
            sender.backgroundColor = .clear
        } else {
            sender.backgroundColor = UIColor.systemGray
        }
    }
    @IBAction func SaturdayClicked(_ sender: UIButton) {
        if(sender.backgroundColor != .clear){
            sender.backgroundColor = .clear
        } else {
            sender.backgroundColor = UIColor.systemGray
        }
    }
    
    func populateFields(){
        alarmTitle.text = alarmToEdit.title
        alarmTime.date = alarmToEdit.time!
        startDate.date = alarmToEdit.startdate!
        endDate.date = alarmToEdit.enddate!
        repeatFlag.setOn(alarmToEdit.repeatflag, animated: true)
        snoozeSwitch.setOn(alarmToEdit.snoozeflag, animated: true)
        alarmimages = alarmToEdit.pictures?.allObjects as! [Images]
        if(alarmToEdit.repeatflag){
            let bIsHidden = weekdaysStackView.isHidden

            if bIsHidden {
                weekdaysStackView.isHidden = false
            }

            UIView.animate(withDuration: 0.3, animations: {
                self.weekdaysSVConstraint.constant = self.weekdaysSVConstraint.constant > 0 ? 0 : self.defaultWeekdaysSVheight
                self.view.layoutIfNeeded()
            })
        }
        if let alarmtoeditrepeatdays = alarmToEdit.repeatdays?.allObjects as? [Repeatdays], alarmtoeditrepeatdays.count>0{
            for weekday in alarmtoeditrepeatdays{
                if(weekday.day == "Sunday"){
                    sundayButton.backgroundColor = UIColor.systemGray
                }
                if(weekday.day == "Monday"){
                    mondayButton.backgroundColor = UIColor.systemGray
                }
                if(weekday.day == "Tuesday"){
                    TuesdayButton.backgroundColor = UIColor.systemGray
                }
                if(weekday.day == "Wednesday"){
                    wednesdayButton.backgroundColor = UIColor.systemGray
                }
                if(weekday.day == "Thursday"){
                    thursdayButton.backgroundColor = UIColor.systemGray
                }
                if(weekday.day == "Friday"){
                    fridayButton.backgroundColor = UIColor.systemGray
                }
                if(weekday.day == "Saturday"){
                    saturdayButton.backgroundColor = UIColor.systemGray
                }
            }
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        let soundspath = paths.appendingPathComponent("Sounds")
        do {try FileManager.default.createDirectory(atPath: soundspath.path, withIntermediateDirectories: true, attributes: nil)}
        catch{
            print(error.localizedDescription)
        }
        return soundspath
    }
    
    private func getRecordingURL(_ fileName : String) -> URL {
        return getDocumentsDirectory().appendingPathComponent(fileName)
    }
    
    private func startRec() {
        audioFileName = "recording" + UUID().uuidString + ".caf"
        let audioURL = getRecordingURL(audioFileName)
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            recorder = try AVAudioRecorder(url: audioURL, settings: settings)
            recorder.delegate = self
            recorder.record(forDuration: 30.0)
            recordBtnLB.setImage(UIImage(systemName: "mic.slash.fill"), for: .normal)
            recordBtnLB.setTitle("Stop", for: .normal)
            print("start recording")
        } catch {
            print("Error in recording \(error.localizedDescription)")
        }
        if(alarmToEdit != nil){
            alarmToEdit.audio = audioFileName
        }
    }
    
    
    func setupPlayer() {
        if alarmToEdit != nil {
        if let file = alarmToEdit.audio, !file.isEmpty{
            let filename = getDocumentsDirectory().appendingPathComponent(alarmToEdit.audio ?? "")
            do {
                player = try AVAudioPlayer(contentsOf: filename)
                player.delegate = self
                player.prepareToPlay()
                player.volume = 1.0
            } catch {
                print(error)
            }
        }
        } else {
        let filename = getDocumentsDirectory().appendingPathComponent(audioFileName)
        do {
            player = try AVAudioPlayer(contentsOf: filename)
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
        } catch {
            print(error)
        }
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        recordBtnLB.setTitle("Record", for:.normal)
        recordBtnLB.setImage(UIImage(systemName: "mic.fill"), for: .normal)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playBtnLB.setTitle("Play", for: .normal)
        playBtnLB.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    private func saveData () {
        do {
            try context.save()
            if (!alarmimages.isEmpty){
                notificationimage = resizeImage(image: UIImage(data: alarmimages[0].image!)!, targetSize: CGSize(width: 800, height: 800))
            }
            if(alarmToEdit == nil){
            CreateReminder(alarm: newAlarm)
            } else {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alarmToEdit.alarmid ?? ""])
                CreateReminder(alarm: alarmToEdit)
            }
        } catch {
            print("Error saving data.. \(error.localizedDescription)")
        }
    }
    
    //to show alerts
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func CreateReminder(alarm: Alarm) {
        DispatchQueue.main.async {
            let content = UNMutableNotificationContent()
            content.title = "MedAlarm Reminder"
            if let tone = alarm.audio {
                content.sound = UNNotificationSound(named: UNNotificationSoundName(tone))
            }
            content.body = "Time to have \(alarm.title ?? "")"
            if let notifpic = self.notificationimage {
                if let attachment = UNNotificationAttachment.create(identifier: alarm.title ?? "", image: notifpic, options: nil) {
                    content.attachments = [attachment]
                    }
            }
            content.categoryIdentifier = "MED_TAKEN_OR_NOT"
            let snoozeaction = UNNotificationAction(identifier: "SHOW", title: "Show", options: [.foreground])
            let takenaction = UNNotificationAction(identifier: "TAKEN", title: "Taken", options: [.foreground])
            let medreminderCategory = UNNotificationCategory(identifier: content.categoryIdentifier,
                                               actions: [snoozeaction, takenaction],
                                               intentIdentifiers: [],
                                               options: [])
            self.notificationCenter.setNotificationCategories([medreminderCategory])
            let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self.alarmTime.date), repeats: self.repeatFlag.isOn)
            if let id = alarm.alarmid {
                if(alarm.snoozeflag){
                    let trigger1 = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self.alarmTime.date.addingTimeInterval(300)), repeats: self.repeatFlag.isOn)
                    let request1 = UNNotificationRequest(identifier: id + "snooze1", content: content, trigger: trigger1)
                        self.notificationCenter.add(request1, withCompletionHandler: {error in
                        if(error != nil){
                            print(error?.localizedDescription ?? "")
                        }
                    })
                    let trigger2 = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self.alarmTime.date.addingTimeInterval(600)), repeats: self.repeatFlag.isOn)
                    let request2 = UNNotificationRequest(identifier: id + "snooze2", content: content, trigger: trigger2)
                        self.notificationCenter.add(request2, withCompletionHandler: {error in
                        if(error != nil){
                            print(error?.localizedDescription ?? "")
                        }
                    })
                    let trigger3 = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self.alarmTime.date.addingTimeInterval(900)), repeats: self.repeatFlag.isOn)
                    let request3 = UNNotificationRequest(identifier: id + "snooze3", content: content, trigger: trigger3)
                        self.notificationCenter.add(request3, withCompletionHandler: {error in
                        if(error != nil){
                            print(error?.localizedDescription ?? "")
                        }
                    })
                    let trigger4 = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self.alarmTime.date.addingTimeInterval(1200)), repeats: self.repeatFlag.isOn)
                    let request4 = UNNotificationRequest(identifier: id + "snooze4", content: content, trigger: trigger4)
                        self.notificationCenter.add(request4, withCompletionHandler: {error in
                        if(error != nil){
                            print(error?.localizedDescription ?? "")
                        }
                    })
                }
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                    self.notificationCenter.add(request, withCompletionHandler: {error in
                    if(error != nil){
                        print(error?.localizedDescription ?? "")
                    }
                })
            }
        }
    }
    func setPopupButton(){
        if(alarmToEdit != nil) {
            let editOptionsClosure = {(action: UIAction) in
                self.alarmToEdit.whentotake = action.title
                self.whentoTake.backgroundColor = UIColor.systemGreen
            }
            if(alarmToEdit.whentotake == "After Food") {
            whentoTake.menu = UIMenu(children: [UIAction(title: "After Food", state: .on, handler: editOptionsClosure),
                UIAction(title: "Before Food",handler: editOptionsClosure)])
                self.whentoTake.backgroundColor = UIColor.systemGreen
            } else if(alarmToEdit.whentotake == "Before Food"){
                whentoTake.menu = UIMenu(children: [UIAction(title: "Before Food", state: .on, handler: editOptionsClosure),
                    UIAction(title: "After Food",handler: editOptionsClosure)])
                self.whentoTake.backgroundColor = UIColor.systemGreen
            } else {
                whentoTake.menu = UIMenu(children: [UIAction(title: "After Food", state: .on, handler: editOptionsClosure),
                    UIAction(title: "Before Food",handler: editOptionsClosure)])
            }
            whentoTake.showsMenuAsPrimaryAction = true
            whentoTake.changesSelectionAsPrimaryAction = true
        } else {
        let optionsClosure = {(action: UIAction) in
            self.newAlarm.whentotake = action.title
            self.whentoTake.backgroundColor = UIColor.systemGreen
        }
        whentoTake.menu = UIMenu(children: [UIAction(title: "After Food", state: .on, handler: optionsClosure),
            UIAction(title: "Before Food",handler: optionsClosure)])
        whentoTake.showsMenuAsPrimaryAction = true
        whentoTake.changesSelectionAsPrimaryAction = true
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

//Extensions

extension NewAlarmViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            let newImage  = Images(context: self.context)
            if let jpegdata = image.jpegData(compressionQuality: 0.5) {
                newImage.image = jpegdata
            }
            newImage.alarm = newAlarm
            alarmimages.append(newImage)
            imagesCollectionView.reloadData()
        }
        picker.dismiss(animated: true, completion: nil)
        }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension NewAlarmViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return alarmimages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imagecell",
                                                         for: indexPath) as? ImageCollectionViewCell {
            let image = alarmimages[indexPath.row]
            if let imageData = image.image {
                cell.imageView.image = UIImage(data:imageData,scale:0.1)
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = alarmimages[indexPath.row]
        if  let popupViewController = self.storyboard?.instantiateViewController(withIdentifier: "imagepopup") as? ImagePopupVCViewController {
            if let imageData = image.image {
                popupViewController.img = UIImage(data:imageData,scale:0.1)
            }
            popupViewController.modalPresentationStyle = .popover
            present(popupViewController, animated: true, completion:nil)
        }

    }
}

extension UNNotificationAttachment {

    static func create(identifier: String, image: UIImage, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let imageFileIdentifier = identifier+".png"
            let fileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)
            let imageData = UIImage.pngData(image)
            try imageData()?.write(to: fileURL)
            let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL, options: options)
            return imageAttachment
        } catch {
            print("error " + error.localizedDescription)
        }
        return nil
    }
}
