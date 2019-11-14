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
    @NSManaged public var pairId: String?
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
        pairToAdd.pairId = pair.id
        pairToAdd.toPairId = pair.toPairId
        pairToAdd.toPairName = pair.toPairName
        pairToAdd.fromPairId = pair.fromPairId
        pairToAdd.fromPairName = pair.fromPairName
        pairToAdd.currentRates = pair.currentRates
    }
    
    static func update(_ moc: NSManagedObjectContext, pair: CurrrencyRatePairs) -> [NSManagedObjectID]{
        // Creates new batch update request for entity `Dog`
        let updateRequest = NSBatchUpdateRequest(entityName: "CurrencyPair")
        
        let predicate = NSPredicate(format: "pairId == %@", pair.id)
        // Assigns the predicate to the batch update
        updateRequest.predicate = predicate
        // Sets the result type as array of object IDs updated
        updateRequest.resultType = .updatedObjectIDsResultType

        // Dictionary with the property names to update as keys and the new values as values
        updateRequest.propertiesToUpdate = ["currentRates": pair.currentRates]
        do {
            // Executes batch
            let result = try moc.execute(updateRequest) as? NSBatchUpdateResult
            // Retrieves the IDs updated
            guard let objectIDs = result?.result as? [NSManagedObjectID] else { return [NSManagedObjectID]() }
            if objectIDs.count == 0{
                 return [NSManagedObjectID]()
            }else{
                return objectIDs
            }
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
