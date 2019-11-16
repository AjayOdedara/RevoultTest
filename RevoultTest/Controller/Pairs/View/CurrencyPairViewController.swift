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
    
    private let currencyPairViewModel: CurrencyPairViewModel = CurrencyPairViewModel()
    private let updateRateTiemr = RepeatingTimer(timeInterval: 1)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableView()
        bindViewModel()
        
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
    private func bindViewModel() {
        print("bindAndFire Start")
//        currencyPairViewModel.currencyPairCells.bindAndFire() { [weak self] _ in
//            DispatchQueue.main.async {
//                print("bindAndFire Compelete")
//                self?.reloadTableData()
//            }
//        }
        updateRateTiemr.eventHandler = {
            print("Timer Fired")
            self.currencyPairViewModel.getRatesOfCurrentPairs()
        }
        
        currencyPairViewModel.loadCurrenciesPairs {
            self.reloadTableData()
            self.updateRateTiemr.resume()
        }
        
    }
    
    private func initTableView(){
        currencyPairTableView.tableHeaderView = headerView
        currencyPairViewModel.delegate = self
        currencyPairTableView.dataSource = currencyPairViewModel
        currencyPairTableView.tableFooterView = UIView()
        currencyPairTableView.estimatedRowHeight = 95
        currencyPairTableView.rowHeight = UITableView.automaticDimension
    }
    private func reloadTableData(){
        // Reload table view
        DispatchQueue.main.async {
            self.currencyPairTableView.reloadData()
            let numberOfPairs = self.currencyPairViewModel.dataProvider?.currencyPairs().count ?? 0
            // Show and hide empty measssage
            self.addPairsDefaultView.isHidden = numberOfPairs > 0 ? true : false
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
    
    
}

// MARK: Sync Data Delegate
extension CurrencyPairViewController: UpdateRateDataDelegate{
    func updateData() {
        let cells = currencyPairTableView.visibleCells
        for cell in cells{
            let currntCell = cell as? CurrencyPairListCell
            let cellIndex = Int(currntCell?.pair?.indexId ?? "1" ) ?? 1
            let currentObj = currencyPairViewModel.dataProvider?.currencyPairs() ?? [CurrencyPair]()
            currntCell?.currencyRate.text = "\(currentObj[cellIndex - 1].currentRates)"
        }
        //let
        //reloadTableData()
    }
}
// MARK: Core Data Insert Delegate
extension CurrencyPairViewController: CoreDataInsertDelegate{
    func insertIntoPairs(with pairToAdd: String) {
        // Insert new pair in List
        currencyPairViewModel.insertPair(with: pairToAdd)
    }
}
