//
//  CurrencyTableviewCell.swift
//  HomeWork
//
//  Created by Ajay Odedra on 27/10/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.
//

import UIKit

class CurrencyTableViewCell: UITableViewCell {

    @IBOutlet var currencyImage: UIImageView!
    @IBOutlet var currencyName: UILabel!
    @IBOutlet var currencyId: UILabel!
    
    static var identifier: String {
        // cell reusable identifier
        return String(describing: self)
    }
    var viewModel: CurrencyCellViewModel? {
        didSet {
            bindViewModel()
        }
    }

    func bindViewModel() {
        guard let model = viewModel else {
            return
        }
        currencyName.text = model.currencyName.flag() + "  "  + model.currencyName.uppercased()
        currencyId.text = viewModel?.currencyName.countryBy()
        DLog("Displayed Currency list table view cell data")
    }
}
