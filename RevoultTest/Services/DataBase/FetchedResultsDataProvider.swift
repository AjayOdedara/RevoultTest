//
//  FetchedResultsDataProvider.swift
//  RevoultTest
//
//  Created by Ajay Odedra on 05/11/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.
//


import CoreData
import UIKit


class FetchedResultsDataProvider<T>: NSObject, NSFetchedResultsControllerDelegate, DataProvider where T: NSFetchRequestResult {
    
    private let fetchedResultsController: NSFetchedResultsController<T>

    init(fetchedResultsController: NSFetchedResultsController<T>) {
        self.fetchedResultsController = fetchedResultsController
        super.init()
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch  {
            DLog(error.localizedDescription)
        }
    }
    func currencyPairs() -> [T] {
        return fetchedResultsController.fetchedObjects ?? [T]()
    }
    func object(at indexPath: IndexPath) -> T {
        return fetchedResultsController.object(at: indexPath)
    }

    func numberOfItemsInSection(_ section: Int) -> Int {
        return fetchedResultsController.sections?.first?.numberOfObjects ?? 0
    }
    
   //TODO DELETE
    override func didChange(_ changeKind: NSKeyValueChange, valuesAt indexes: IndexSet, forKey key: String) {
        switch changeKind {
        case .insertion:
            print("Inserted")
        case .removal:
            print("removed")
        default:
            print("def")
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
}

