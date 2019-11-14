//
//  CurrencyPairViewController.swift
//  RevoultTest
//
//  Created by Ajay Odedra on 05/11/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.
//

import UIKit
import CoreData

class CurrencyPairViewController: UIViewController {

    @IBOutlet var currencyPairTableView: UITableView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var addPairsDefaultView: UIView!
    
    let currencyPairViewModel: CurrencyPairViewModel = CurrencyPairViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()

        currencyPairViewModel.delegate = self
        // setup container and get data
        currencyPairViewModel.loadCurrenciesPairs { () in
            // Reload table view when receive call back
            self.reloadTableData()
        
        }
        
        // To add data
        /*
         currencyPairViewModel.loadCurrenciesPairs { () in
         let pairs = CurrrencyRatePairs(dictionary: (key: "INRGBP", value: 0))
         pairs.id = "INRGBP"
         pairs.toPairId = "GBP"
         pairs.toPairName = "British Pounds"
         pairs.fromPairId = "INR"
         pairs.fromPairName = "Indian Rupee"
         pairs.currentRates = "0.90"
             
         let pairs2 = CurrrencyRatePairs(dictionary: (key: "GBPUSD", value: 0))
         pairs2.id = "GBPUSD"
         pairs2.toPairId = "USD"
         pairs2.toPairName = "United States"
         pairs2.fromPairId = "GBP"
         pairs2.fromPairName = "British Pounds"
         pairs2.currentRates = "2.12"
         
             self.currencyPairViewModel.preservePairs(data: [pairs2,pairs]) { (success) in
                 print("done")
             }
         }
         */

            
    }
    
    func reloadTableData(){
        // Reload table view
        DispatchQueue.main.async {
            self.currencyPairTableView.reloadData()
            let numberOfObjects = self.currencyPairViewModel.dataProvider?.numberOfItemsInSection(0) ?? 0
            
            // Show and hide empty measssage
            self.addPairsDefaultView.isHidden = numberOfObjects > 0 ? true : false
        }
    }
    
    @IBAction func addPairClicked(_ sender: UIButton) {
        // When user select row, push to the Contact Detail View Controller
        guard let currencyDetail = self.storyboard?.instantiateViewController(identifier: "currenciesViewController") as? CurrenciesViewController else {
            DLog("Failed to present contact detail view controller")
            return
        }
        //        contactDetail.contact = cell.item
        DLog("present view controller")
        currencyDetail.delegate = self
        self.navigationController?.present(currencyDetail, animated: true)
    }
    
    func bindViewModel() {
        currencyPairTableView.tableHeaderView = headerView
        currencyPairTableView.dataSource = currencyPairViewModel
        currencyPairTableView.tableFooterView = UIView()
        currencyPairTableView.estimatedRowHeight = 50.0
        currencyPairTableView.rowHeight = UITableView.automaticDimension
        
    }
}

// MARK: Sync Data Delegate
extension CurrencyPairViewController: UpdateRateDataDelegate{
    func updateData() {
        reloadTableData()
    }
}
// MARK: Core Data Insert Delegate
extension CurrencyPairViewController: CoreDataInsertDelegate{
    func insertIntoPairs(with pairToAdd: String) {
        // Insert new pair in List
        currencyPairViewModel.insertIntoPairs(with: pairToAdd)
//        { (isSuccess) in
//            if isSuccess{
//                // Reload table view when receive call back
//                DispatchQueue.main.async {
//                    self.currencyPairTableView.reloadData()
//                }
//            }else{
//               DLog("Failed to insert into Pair")
//            }
//        }
    }
}
