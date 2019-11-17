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
    var pair: CurrencyPair? {
        // set cell data
        didSet {
            guard let pair = pair else {
                return
            }
            fromCurrencyName.text = pair.fromPairName
            currencyRate.text = pair.currentRates > 0 ? "\(pair.currentRates)" : "."
            toCurrencyName.text = (pair.toPairName) + " " + ( pair.toPairId.uppercased())
            fromCurrency.text = "1 " + (pair.fromPairId)

            DLog("Displayed list table view cell data")
        }
    }
}

