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
    @IBOutlet var addCurrencyPair: UIButton!
    
    private let currencyPairViewModel: CurrencyPairViewModel = CurrencyPairViewModel()
    private let updateRateTiemr = RepeatingTimer(timeInterval: 1)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNetworkCheck()
        initTableView()
        bindViewModel()
        
    }
    private func bindViewModel() {
        print("bindAndFire Start")
        updateRateTiemr.eventHandler = {
            self.currencyPairViewModel.getRatesOfCurrentPairs()
        }
        
        currencyPairViewModel.loadCurrenciesPairs {
            DispatchQueue.main.async {
                self.currencyPairTableView.reloadData()
            }
            self.setUpView()
            self.updateRateTiemr.resume()
        }
    }
    
    private func initTableView(){
        addCurrencyPair.contentHorizontalAlignment = .left
        currencyPairViewModel.delegate = self
        currencyPairTableView.dataSource = currencyPairViewModel
        currencyPairTableView.tableFooterView = UIView()
        currencyPairTableView.estimatedRowHeight = 95
        currencyPairTableView.rowHeight = UITableView.automaticDimension
    }
    private func setUpView(){
        let numberOfPairs = self.currencyPairViewModel.dataProvider?.currencyPairs().count ?? 0
        DispatchQueue.main.async {
            // Show and hide empty measssage
            if numberOfPairs > 0{
                self.addPairsDefaultView.isHidden = true
                self.currencyPairTableView.tableHeaderView = self.headerView
            }else{
                self.addPairsDefaultView.isHidden = false
                self.currencyPairTableView.tableHeaderView = UIView()
            }
        }
    }
    @objc func updateApiTimer() {
        switch Network.reachability.status {
        case .unreachable:
            updateRateTiemr.suspend()
        case .wwan, .wifi:
            updateRateTiemr.resume()
        }
    }
    private func initNetworkCheck(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateApiTimer), name: .flagsChanged, object: nil)
        do {
            try Network.reachability = NetworkManager(hostname: "www.google.com")
        }
        catch {
          print("Failed to check network conntion and init the Reachability")
        }
    }
    private func updateRate(){

        let cells = currencyPairTableView.visibleCells
        for cell in cells{
            guard let currntCell = cell as? CurrencyPairListCell,let id = currencyPairTableView.indexPath(for: currntCell)?.row else{
                return
            }
//            let id = currntCell.currencyRate.tag // TODO: we have to reload table after row deletion
            let currentObj = currencyPairViewModel.dataProvider?.currencyPairs() ?? [CurrencyPair]()
            currntCell.currencyRate.text = "\(currentObj[id].currentRates)"
        }
    }
    
    @IBAction func addPairClicked(_ sender: UIButton) {
        // When user select row, push to the Contact Detail View Controller
        guard let currencyDetail = self.storyboard?.instantiateViewController(identifier: "currenciesViewController") as? CurrenciesViewController else {
            DLog("Failed to present contact detail view controller")
            return
        }
        DLog("present view controller")
        currencyDetail.delegate = self
        self.navigationController?.present(currencyDetail, animated: true)
    }
    
    
}

// MARK: Sync Data Delegate
extension CurrencyPairViewController: UpdateRateDataDelegate{
    func update(data isSucess: Bool) {
        if isSucess{
            updateRate()
        }else{
            updateRateTiemr.suspend()
            setUpView()
        }
    }
    func reloadTableCells() {
        DispatchQueue.main.async {
            self.currencyPairTableView.reloadData()
        }
        setUpView()
        //TODO: Refactore it
//        DispatchQueue.main.async {
//            self.currencyPairTableView.beginUpdates()
//            self.currencyPairTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
//            self.currencyPairTableView.endUpdates()
//        }
    }
}
// MARK: Core Data Insert Delegate
extension CurrencyPairViewController: CoreDataInsertDelegate{
    func insertIntoPairs(with pairToAdd: String) {
        // Insert new pair in List
        if updateRateTiemr.state == .suspended{
            updateRateTiemr.resume()
        }
        currencyPairViewModel.insertPair(with: pairToAdd)
    }
}
