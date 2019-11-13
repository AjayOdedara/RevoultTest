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
//            let pairs = CurrentPair(toPairId: "GBP", toPairName: "British Pounds", fromPairId: "INR", fromPairName: "Indian Rupee", currentRates: "0.98")
//            self.currencyPairViewModel.preservePairs(data: pairs) { (success) in
//                print("done")
//            }
//            let pairs2 = CurrentPair(toPairId: "INR", toPairName: "Indian Rupee", fromPairId: "GBP", fromPairName: "British Pounds", currentRates: "90.12")
//            self.currencyPairViewModel.preservePairs(data: pairs2) { (success) in
//                print("done")
//            }
        }
        

            
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
