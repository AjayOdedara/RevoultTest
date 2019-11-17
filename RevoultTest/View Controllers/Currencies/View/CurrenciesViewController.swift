//
//  CurrenciesViewController.swift
//  RevoultTest
//
//  Created by Ajay Odedra on 05/11/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.
//

import UIKit

protocol CoreDataInsertDelegate: UIViewController {
    // insert data delegate setup
    func insertIntoPairs(with pairToAdd: String)
}

class CurrenciesViewController: UIViewController {

    @IBOutlet var currenciesTableView: UITableView!
    let currencyViewModel: CurrenciesViewModel = CurrenciesViewModel()
    var currencyPair:String?
    weak var delegate: CoreDataInsertDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        currencyViewModel.getCurrencies()
        
    }
    
    func bindViewModel() {
        currenciesTableView.delegate = self
        currenciesTableView.dataSource = currencyViewModel
        currenciesTableView.tableFooterView = UIView()
        currenciesTableView.estimatedRowHeight = 50.0
        currenciesTableView.rowHeight = UITableView.automaticDimension
        print("bindAndFire Start")
        currencyViewModel.currencyCells.bindAndFire() { [weak self] _ in
            print("bindAndFire Compelete")
            DispatchQueue.main.async {
                self?.currenciesTableView.reloadData()
            }
        }
    }
    func insertNewPair(with pairToAdd: String){
        // insert into CurrencyPair using delegate
        delegate?.insertIntoPairs(with: pairToAdd)
    }

}

// MARK: Table View Delegate
extension CurrenciesViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DLog("User clicked on cell")
        // When user select row, push animation with second currency to pick
        guard let cell = tableView.cellForRow(at: indexPath) as? CurrencyTableViewCell, let currencyId = cell.viewModel?.currencyName else {
            DLog("Failed to select pair on currencies")
            return
        }
        
        if currencyPair == nil{
            
            currencyPair = currencyId
            currencyViewModel.currencyCells.value.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .none)
            
            let transition = CATransition()
            transition.type = CATransitionType.push
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.fillMode = CAMediaTimingFillMode.forwards
            transition.duration = 0.5
            transition.subtype = CATransitionSubtype.fromRight
            tableView.layer.add(transition, forKey: "UITableViewReloadDataAnimationKey")
            // Update your data source here
            tableView.reloadData()
            DLog("User selected first pair currency")
            
        }else{
            currencyPair = (currencyPair ?? "")  + currencyId
            dismiss(animated: true) {
                guard let pairs = self.currencyPair else{return}
                self.insertNewPair(with: pairs)
            }
            DLog("User selected second pair currency")
        }
    }
}
