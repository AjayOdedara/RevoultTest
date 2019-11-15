//
//  CurrencyPairListCell.swift
//  RevoultTest
//
//  Created by Ajay Odedra on 05/11/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.
//


import UIKit
class CurrencyPairListCell: UITableViewCell {

    @IBOutlet var fromCurrencyName: UILabel!
    @IBOutlet var fromCurrency: UILabel!
    @IBOutlet var currencyRate: UILabel!
    @IBOutlet var toCurrencyName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    static var identifier: String {
        // cell reusable identifier
        return String(describing: self)
    }
    var viewModel: CurrencyPairCellViewModel? {
        didSet {
            bindViewModel()
        }
    }

    private func bindViewModel() {
        print(viewModel?.currentExchangeRate)
        print(viewModel?.fromPairTitle)
        
        fromCurrencyName.text = ( viewModel?.fromPairTitle ?? "" )
        currencyRate.text = viewModel?.currentExchangeRate ?? ""
        toCurrencyName.text = ( viewModel?.toPairTitle ?? "" ) + " " + ( viewModel?.toPair.uppercased() ?? "")
        fromCurrency.text = "1 " + (viewModel?.fromPair ?? "")

        DLog("Displayed contact list table view cell data")
    }
}

