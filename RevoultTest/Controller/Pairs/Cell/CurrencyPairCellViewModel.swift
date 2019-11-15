//
//  RateCellViewModel.swift
//  HomeWork
//
//  Created by Ajay Odedra on 27/10/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.
//

import Foundation
protocol CurrencyPairCellViewModel {
    
    var toPair: String { get }
    var toPairTitle: String { get }
    var fromPair: String { get }
    var fromPairTitle: String { get }
    var currentExchangeRate: String { get }
}

extension CurrrencyRatePairs: CurrencyPairCellViewModel {
    var toPair: String {
        return toPairId
    }
    var toPairTitle: String {
        return toPairName
    }
    var fromPair: String {
        return fromPairId
    }
    var fromPairTitle: String {
        return fromPairName
    }
    var currentExchangeRate: String {
        return currentRates
    }
}

