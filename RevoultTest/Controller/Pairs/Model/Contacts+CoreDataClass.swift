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
    @NSManaged public var pairId: String
    @NSManaged public var toPairId: String
    @NSManaged public var toPairName: String
    @NSManaged public var fromPairId: String
    @NSManaged public var fromPairName: String
    @NSManaged public var currentRates: Double
    @NSManaged public var currencyPair: String
    @NSManaged public var indexId: String
    
//    public init(dictionary: (key:String, value:Any)) {
//
//        print(dictionary)
//        let indexFirstCurrency = dictionary.key.index(dictionary.key.startIndex, offsetBy: 3)
//        let second = dictionary.key.suffix(3)
//        let mySubstring = dictionary.key[..<indexFirstCurrency] // Hello
//
//        self.id = dictionary.key
//        self.toPairId = String(second)
//        self.toPairName = dictionary.key
//        self.fromPairId = String(mySubstring)
//        self.fromPairName = dictionary.key
//        self.currentRates = "\(dictionary.value as? Double ?? 0.0)"
//    }
    
    static func defaultFetchRequest() -> NSFetchRequest<CurrencyPair> {
        // featch data of Pairs
        let request = NSFetchRequest<CurrencyPair>(entityName: "CurrencyPair")
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(indexId), ascending: true)]
        return request
    }
    
    static func insertInto(_ context: NSManagedObjectContext, pair: (id:String, index:String)) {
        // insert into Pair
        
        let indexFirstCurrency = pair.id.index(pair.id.startIndex, offsetBy: 3)
        let toPairId = pair.id.suffix(3)
        let fromId = pair.id[..<indexFirstCurrency] // Hello
        
        let pairToAdd = CurrencyPair(context: context)
        pairToAdd.indexId = pair.index
        pairToAdd.pairId = pair.id
        pairToAdd.toPairId = String(toPairId)
        pairToAdd.toPairName = pair.id
        pairToAdd.fromPairId = String(fromId)
        pairToAdd.fromPairName = pair.id
        pairToAdd.currentRates = 0
    }
    
    static func update(_ moc: NSManagedObjectContext, pair: (id:String, value:Double)){
        // Creates new batch update request for entity `Dog`
        let updateRequest = NSBatchUpdateRequest(entityName: "CurrencyPair")
        let predicate = NSPredicate(format: "pairId == %@", pair.id)
        // Assigns the predicate to the batch update
        updateRequest.predicate = predicate
        // Sets the result type as array of object IDs updated
        updateRequest.resultType = .updatedObjectIDsResultType
        // Dictionary with the property names to update as keys and the new values as values
        updateRequest.propertiesToUpdate = ["currentRates": pair.value]

        do {
            // Executes batch
            let result = try moc.execute(updateRequest) as? NSBatchUpdateResult
            // Retrieves the IDs updated
            guard let objectIDs = result?.result as? [NSManagedObjectID] else { return }
            let changes = [NSUpdatedObjectsKey: objectIDs]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [moc])
        } catch {
            fatalError("Failed to execute request: \(error)")
        }
    }
}
//struct CurrentPair {
//    var toPairId:String
//    var toPairName:String
//    var fromPairId:String
//    var fromPairName:String
//    var currentRates:String
//}
