//
//  PurchaseViewController.swift
//  MarkLite
//
//  Created by 朱炳程 on 2018/10/10.
//  Copyright © 2018 zhubch. All rights reserved.
//

import UIKit
import EZSwiftExtensions
class PurchaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func restoreVIP(_ sender: UIButton) {
        sender.startLoadingAnimation()
        
        IAP.restorePurchases { (identifiers, error) in
            if let err = error {
                print(err.localizedDescription)
                self.showAlert(title: /"RestoreFailed")
                sender.stopLoadingAnimation()
                return
            }
            Configure.shared.checkVipAvailable({ (availabel) in
                if availabel {
                    self.navigationController?.dismiss(animated: true, completion: {
//                        self.showAlert(title: /"RestoreSuccess")
                    })
                } else {
                    self.showAlert(title: /"RestoreFailed")
                }
                sender.stopLoadingAnimation()
            })
            print(identifiers)
        }
    }
    
    @IBAction func purchaseProduct(_ sender: UIButton) {
        sender.startLoadingAnimation()
        IAP.requestProducts([premiumProductID]) { (response, error) in
            guard let product = response?.products.first else {
                sender.stopLoadingAnimation()
                return
            }
            IAP.purchaseProduct(product.productIdentifier, handler: { (identifier, error) in
                if error != nil {
                    sender.stopLoadingAnimation()
                    print(error?.localizedDescription ?? "")
                    return
                }
                Configure.shared.checkVipAvailable({ (availabel) in
                    if availabel {
                        self.navigationController?.dismiss(animated: true, completion: {
//                            self.showAlert(title: /"SubscribedSuccess")
                        })
                    } else {
                        self.showAlert(title: /"SubscribeFailed")
                    }
                    sender.stopLoadingAnimation()
                })
            })
        }
    }
    
    @IBAction func close(_ sender: UIButton) {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func terms(_ sender: UIButton) {
        let webVc = InfoViewController()
        webVc.url = "https://zhubinchen.github.io/Page/terms.html"
        webVc.title = /"Terms"
        pushVC(webVc)
    }

    @IBAction func privacy(_ sender: UIButton) {
        let webVc = InfoViewController()
        webVc.url = "https://zhubinchen.github.io/Page/privacy.html"
        webVc.title = /"PrivacyPolicy"
        pushVC(webVc)
    }

}
