//
//  CurrenciesViewModel.swift
//  RevoultTest
//
//  Created by Ajay Odedra on 09/11/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.
//

import Foundation
import UIKit

class CurrenciesViewModel:NSObject{

    enum CurrenciesTableViewCellType {
        case normal(cellViewModel: CurrencyCellViewModel)
        case error(message: String)
        case empty
    }
    let currencyCells = Bindable([CurrenciesTableViewCellType]())
    
    // API INIT
    let appServerClient: AppServerClient
    init(appServerClient: AppServerClient = AppServerClient()) {
        self.appServerClient = appServerClient
    }
    
    func getCurrencies() {
        appServerClient.getCurrency(completion: { [weak self] result in
            switch result {
            case .success(let currencies):
                
                guard currencies.count > 0 else {
                    self?.currencyCells.value = [.empty]
                    return
                }
                self?.currencyCells.value = currencies.compactMap {
                    .normal(cellViewModel: $0 as CurrencyCellViewModel)
                }
            case .failure(let error):
                self?.currencyCells.value = [.error(message: error?.localizedDescription ?? "Error occurred")]
            }
        })
    }
}

// MARK: Table View Data Source
extension CurrenciesViewModel: UITableViewDataSource {
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return currencyCells.value.count
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
       switch currencyCells.value[indexPath.row] {
       case .normal(let viewModel):
           
           guard let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyTableViewCell.identifier) as? CurrencyTableViewCell else {
               return UITableViewCell()
           }
           
           cell.viewModel = viewModel
           return cell
       case .error(let message):
           let cell = UITableViewCell()
           cell.isUserInteractionEnabled = false
           cell.textLabel?.text = message
           return cell
       case .empty:
           let cell = UITableViewCell()
           cell.isUserInteractionEnabled = false
           cell.textLabel?.text = "No currencies available for exchange"
           return cell
       }
   }
}
