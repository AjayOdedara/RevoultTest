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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    static var identifier: String {
        // cell reusable identifier
        return String(describing: self)
    }
    
    var item: CurrencyPair? {
        // set cell data
        didSet {
            
            print(item?.currentRates)
            print(item?.fromPairName)
            
            fromCurrencyName.text = ( item?.fromPairName ?? "" )
            currencyRate.text = item?.currentRates ?? ""
            toCurrencyName.text = ( item?.toPairName ?? "" ) + " " + ( item?.toPairId?.uppercased() ?? "")
            fromCurrency.text = "1 " + (item?.fromPairId ?? "")

            DLog("Displayed contact list table view cell data")
        }
    }
}

