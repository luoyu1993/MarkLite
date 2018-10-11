//
//  SettingsViewController.swift
//  MarkLite
//
//  Created by zhubch on 2017/6/23.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import SideMenu
import RxSwift
import EZSwiftExtensions

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = 48
            tableView.setSeparatorColor(.primary)
        }
    }
    
    let themeSwitch = UISwitch(x: 0, y: 9, w: 60, h: 60)
    let assitBarSwitch = UISwitch(x: 0, y: 9, w: 60, h: 60)
    let autoClearSwitch = UISwitch(x: 0, y: 9, w: 60, h: 60)
    
    var items: [(String,[(String,String,Selector)])] {
        var section = [
            ("AssistKeyboard","",#selector(assistBar)),
            ("AutoClear","",#selector(autoClear)),
            ]
        if !Configure.shared.isVip {
            section.insertFirst(("PremiumAccount","",#selector(purchase)))
        }
        return [
            ("功能",section),
            ("外观",[
                ("NightMode","",#selector(night)),
                ("Theme","",#selector(theme)),
                ("Style","",#selector(style)),
                ("CodeStyle","",#selector(codeStyle))
                ]),
            ("支持一下",[
                ("RateIt","",#selector(rate)),
                ("Feedback","",#selector(feedback))
                ])
        ]
    }
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        preferredContentSize = CGSize(width: 320, height: 500)
        self.title = /"Settings"
        navBar?.setBarTintColor(.navBar)
        navBar?.setContentColor(.navBarTint)
        tableView.setBackgroundColor(.tableBackground)

        themeSwitch.setTintColor(.navBarTint)
        assitBarSwitch.setTintColor(.navBarTint)
        autoClearSwitch.setTintColor(.navBarTint)

        themeSwitch.isOn = Configure.shared.theme.value == .black
        assitBarSwitch.isOn = Configure.shared.isAssistBarEnabled.value
        autoClearSwitch.isOn = Configure.shared.isAutoClearEnabled
        
        themeSwitch.addTarget(self, action: #selector(night(_:)), for: .valueChanged)
        assitBarSwitch.addTarget(self, action: #selector(assistBar(_:)), for: .valueChanged)
        autoClearSwitch.addTarget(self, action: #selector(autoClear(_:)), for: .valueChanged)
        
        navigationController?.delegate = navigationController
        navigationController?.delegate = navigationController
        navigationController?.interactivePopGestureRecognizer?.delegate = navigationController
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        themeSwitch.x = view.w - 60
        assitBarSwitch.x = view.w - 60
        autoClearSwitch.x = view.w - 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settings", for: indexPath)
        let item = items[indexPath.section].1[indexPath.row]
        cell.textLabel?.text = /(item.0)
        cell.detailTextLabel?.text = /(item.1)
        cell.textLabel?.setTextColor(.primary)
        cell.detailTextLabel?.setTextColor(.secondary)
        cell.setBackgroundColor(.background)
        
        if item.0 == "AssistKeyboard" {
            cell.addSubview(assitBarSwitch)
            cell.accessoryType = .none
        }
        if item.0 == "NightMode" {
            cell.addSubview(themeSwitch)
            cell.accessoryType = .none
        }
        if item.0 == "AutoClear" {
            cell.addSubview(autoClearSwitch)
            cell.accessoryType = .none
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = items[indexPath.section].1[indexPath.row]
        if item.0 == "AssistKeyboard" || item.0 == "NightMode" || item.0 == "AutoClear" {
            return
        }
        perform(item.2)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
}

extension SettingsViewController {
    
    
    @objc func rate() {
        Configure.shared.hasRate = true
        UIApplication.shared.openURL(URL(string: rateUrl)!)
    }
    
    @objc func feedback() {
        UIApplication.shared.openURL(URL(string: emailUrl)!)
    }
    
    @objc func night(_ sender: UISwitch) {
        Configure.shared.theme.value = sender.isOn ? .black : .white
    }
    
    @objc func assistBar(_ sender: UISwitch) {
        Configure.shared.isAssistBarEnabled.value = sender.isOn
    }
    
    @objc func autoClear(_ sender: UISwitch) {
        Configure.shared.isAutoClearEnabled = sender.isOn
    }
    
    @objc func theme() {
        let items = [Theme.white,.black,.pink,.green,.blue,.purple,.red]
        let index = items.index{ Configure.shared.theme.value == $0 }

        let wraper = OptionsWraper(selectedIndex: index, title: /"Theme", items: items) { (index) in
            Configure.shared.theme.value = items[index]
        }
        let vc = OptionsViewController()
        vc.options = wraper
        pushVC(vc)
    }
    
    @objc func style() {
        let path = stylePath + "/markdown-style/"
        
        guard let subPaths = FileManager.default.subpaths(atPath: path) else { return }
        
        let items = subPaths.map{ $0.replacingOccurrences(of: ".css", with: "")}.filter{!$0.hasPrefix(".")}
        let index = items.index{ Configure.shared.markdownStyle.value == $0 }
        let wraper = OptionsWraper(selectedIndex: index, title: /"Style", items: items) { (index) in
            Configure.shared.markdownStyle.value = items[index]
        }
        let vc = OptionsViewController()
        vc.options = wraper
        pushVC(vc)
    }
    
    @objc func codeStyle() {
        let path = stylePath + "/highlight-style/"
        
        guard let subPaths = FileManager.default.subpaths(atPath: path) else { return }
        
        let items = subPaths.map{ $0.replacingOccurrences(of: ".css", with: "")}.filter{!$0.hasPrefix(".")}
        let index = items.index{ Configure.shared.highlightStyle.value == $0 }

        let wraper = OptionsWraper(selectedIndex: index, title: /"CodeStyle", items: items) { (index) in
            Configure.shared.highlightStyle.value = items[index]
        }
        let vc = OptionsViewController()
        vc.options = wraper
        pushVC(vc)
    }
    
    @objc func purchase() {
        let sb = UIStoryboard(name: "Settings", bundle: Bundle.main)
        guard let vc = sb.instantiateVC(PurchaseViewController.self) else {
            return
        }
        dismiss(animated: false) {
            let nav = UINavigationController(rootViewController: vc)
            ez.topMostVC?.presentVC(nav)
        }
    }

}
