//
//  CurrenciesPair.swift
//  RevoultTest
//
//  Created by Ajay Odedra on 05/11/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.
//

import Foundation
import CoreData

@objc(CurrencyPair)
public class CurrencyPair: NSManagedObject {
    
    @NSManaged public var toPairId: String?
    @NSManaged public var toPairName: String?
    @NSManaged public var fromPairId: String?
    @NSManaged public var fromPairName: String?
    @NSManaged public var currentRates: String?
    @NSManaged public var currencyPair: String?
    
    static func defaultFetchRequest() -> NSFetchRequest<CurrencyPair> {
        // featch data of Pairs
        let request = NSFetchRequest<CurrencyPair>(entityName: "CurrencyPair")
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(fromPairName), ascending: true)]
        return request
    }
    
    static func insertInto(_ context: NSManagedObjectContext, pair: CurrrencyRatePairs) {
        // insert into Pair
        let pairToAdd = CurrencyPair(context: context)
        pairToAdd.toPairId = pair.toPairId
        pairToAdd.toPairName = pair.toPairName
        pairToAdd.fromPairId = pair.fromPairId
        pairToAdd.fromPairName = pair.fromPairName
        pairToAdd.currentRates = pair.currentRates
    }
}
//struct CurrentPair {
//    var toPairId:String
//    var toPairName:String
//    var fromPairId:String
//    var fromPairName:String
//    var currentRates:String
//}
