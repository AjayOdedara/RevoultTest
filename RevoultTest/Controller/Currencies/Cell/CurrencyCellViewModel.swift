//
//  CurrencyCellViewModel.swift
//  HomeWork
//
//  Created by Ajay Odedra on 27/10/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.


import Foundation
protocol CurrencyCellViewModel {
    var currencyName: String { get }
}

extension Currencies: CurrencyCellViewModel {
    var currencyName: String {
        return name
    }
}
