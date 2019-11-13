//
//  CurrenciesPair.swift
//  RevoultTest
//
//  Created by Ajay Odedra on 05/11/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.
//

import Foundation

class CurrrencyRatePairs: NSObject {
    
    var toPairId:String
    var toPairName:String
    var fromPairId:String
    var fromPairName:String
    var currentRates:String
    
    init(dictionary: (key:String, value:Any)) {
        print(dictionary)
        print(dictionary.key)
        let indexFirstCurrency = dictionary.key.index(dictionary.key.startIndex, offsetBy: 3)
        let second = dictionary.key.suffix(3)
        let mySubstring = dictionary.key[..<indexFirstCurrency] // Hello
        self.toPairId = String(second)
        self.toPairName = dictionary.key
        self.fromPairId = String(mySubstring)
        self.fromPairName = dictionary.key
        self.currentRates = "\(dictionary.value as? Double ?? 0.0)"
    }
    
}
