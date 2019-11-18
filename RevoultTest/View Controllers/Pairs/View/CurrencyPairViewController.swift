//
//  CurrencyPairViewController.swift
//  RevoultTest
//
//  Created by Ajay Odedra on 12/11/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.
//

import UIKit
import CoreData

class CurrencyPairViewController: UIViewController {

    @IBOutlet var currencyPairTableView: UITableView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var addPairsDefaultView: UIView!
    @IBOutlet var addCurrencyPairHeaderBtn: UIButton!
    @IBOutlet var addCurrencyPairViewBtn: UIButton!
    @IBOutlet var addPairDescriptionLbl: UILabel!
    
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
        //Localization
        addPairDescriptionLbl.text = NSLocalizedString("currency_pair_add_pair_description", comment: "Add Currency pair more inforomaton of title")
        addCurrencyPairHeaderBtn.setTitle(NSLocalizedString("currency_pair_add_currency_pair", comment: "Add Currency pair button title"), for: .normal)
        addCurrencyPairViewBtn.setTitle(NSLocalizedString("currency_pair_add_currency_pair", comment: "Add Currency pair button title"), for: .normal)
        
        
        
        addCurrencyPairHeaderBtn.contentHorizontalAlignment = .left
        // Tableview init
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
            let currentObj = currencyPairViewModel.dataProvider?.currencyPairs() ?? [CurrencyPair]()
            currntCell.currencyRate.text = "\(currentObj[id].currentRates)"
        }
    }
    
    @IBAction func addPairClicked(_ sender: UIButton) {
        // When user select Add Pair, Navigate to Cuurencies View Controller
        guard let currencyDetail = self.storyboard?.instantiateViewController(identifier: "currenciesViewController") as? CurrenciesViewController else {
            DLog("Failed to present  Cuurencies View Controller")
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
    }
}
// MARK: Core Data Insert Delegate
extension CurrencyPairViewController: CoreDataInsertDelegate{
    func insertIntoPairs(with pairToAdd: String) {
        // Insert new pair in List
        if updateRateTiemr.state == .suspended{
            updateRateTiemr.resume()
        }
        currencyPairViewModel.insertPair(with: pairToAdd){_ in }
    }
}
