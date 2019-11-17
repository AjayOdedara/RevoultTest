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
    @NSManaged public var indexId: Double

    static func defaultFetchRequest() -> NSFetchRequest<CurrencyPair> {
        // featch data of Pairs
        let request = NSFetchRequest<CurrencyPair>(entityName: "CurrencyPair")
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(indexId), ascending: false)]
        return request
    }
    
    static func insertInto(_ context: NSManagedObjectContext, pair: (id:String, index:Double)) {
        // insert into Pair
        
        let indexFirstCurrency = pair.id.index(pair.id.startIndex, offsetBy: 3)
        let toPairId = pair.id.suffix(3)
        let fromId = pair.id[..<indexFirstCurrency]
        
        let pairToAdd = CurrencyPair(context: context)
        pairToAdd.indexId = pair.index
        pairToAdd.pairId = pair.id
        pairToAdd.toPairId = String(toPairId)
        pairToAdd.toPairName = String(toPairId).countryBy() ?? String(toPairId) // TODO: Refactor
        pairToAdd.fromPairId = String(fromId)
        pairToAdd.fromPairName = String(fromId).countryBy() ?? String(fromId) // TODO: Refactor
        pairToAdd.currentRates = 0
    }
    
    static func update(pair  moc: NSManagedObjectContext, pair: (id:String, value:Double)){
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
    static func delete(pair  moc: NSManagedObjectContext, pairId:String){
        // Creates new batch update request for entity `Dog`
        let request = NSFetchRequest<CurrencyPair>(entityName: "CurrencyPair")
        request.predicate = NSPredicate(format: "pairId == %@", pairId)
        
        do {
            let results = try moc.fetch(request)
            guard let object = results.first else{
                return
            }
            moc.delete(object)
        }catch {
            
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
