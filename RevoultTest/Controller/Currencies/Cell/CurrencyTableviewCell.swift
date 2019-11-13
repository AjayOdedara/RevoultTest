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
    
    static var identifier: String {
        // cell reusable identifier
        return String(describing: self)
    }
    var viewModel: CurrencyCellViewModel? {
        didSet {
            bindViewModel()
        }
    }

    private func bindViewModel() {
        currencyName.text = viewModel?.currencyName.uppercased()
        DLog("Displayed contact list table view cell data")
    }
}
