//
//  PomodoroTimerSettingVM.swift
//  OnlySwitch
//
//  Created by Jacklandrin on 2021/12/26.
//

import Foundation

let AllowNotificationAlertKey = "AllowNotificationAlertKey"
let WorkDurationKey = "WorkDurationKey"
let RestDurationKey = "RestDurationKey"
let WorkAlertKey = "WorkAlertKey"
let RestAlertKey = "RestAlertKey"
let PTimerCycleCountKey = "PTimerLoopCountKey"
let ChangePTDurationNotification = NSNotification.Name(rawValue:"ChangePTDurationNotification")

class PomodoroTimerSettingVM:ObservableObject {
    @Published private var model = PomodoroTimerSettingModel()
    
    var workDurationList:[Int] {
        model.workDurationList
    }
    
    var restDurationList:[Int] {
        model.restDurationList
    }
    
    var cycleCountList:[Int] {
        model.cycleCountList
    }
    
    var alertSounds:[EffectSound] {
        model.alertSounds
    }
    
    @UserDefaultValue(key: WorkDurationKey, defaultValue: 25 * 60)
    var workDuration:Int {
        didSet {
            objectWillChange.send()
            NotificationCenter.default.post(name: ChangePTDurationNotification, object: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                NotificationCenter.default.post(name: changeSettingNotification, object: nil)
            }
        }
    }
    
    @UserDefaultValue(key: RestDurationKey, defaultValue: 5 * 60)
    var restDuration:Int {
        didSet {
            objectWillChange.send()
            NotificationCenter.default.post(name: ChangePTDurationNotification, object: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                NotificationCenter.default.post(name: changeSettingNotification, object: nil)
            }
        }
    }
    
    @UserDefaultValue(key: RestAlertKey, defaultValue: "mixkit-alert-bells-echo-765")
    var restAlert:String {
        didSet {
            objectWillChange.send()
        }
    }
    
    @UserDefaultValue(key: WorkAlertKey, defaultValue: "mixkit-bell-notification-933")
    var workAlert:String {
        didSet {
            objectWillChange.send()
        }
    }
    
    @UserDefaultValue(key: AllowNotificationAlertKey, defaultValue: true)
    var allowNotificationAlert:Bool {
        didSet {
            objectWillChange.send()
        }
    }
    
    @UserDefaultValue(key: PTimerCycleCountKey, defaultValue: 1)
    var cycleCount:Int {
        didSet {
            objectWillChange.send()
        }
    }
}
