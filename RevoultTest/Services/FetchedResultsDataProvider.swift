//
//  FetchedResultsDataProvider.swift
//  RevoultTest
//
//  Created by Ajay Odedra on 05/11/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.
//


import CoreData

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

    func object(at indexPath: IndexPath) -> T {
        return fetchedResultsController.object(at: indexPath)
    }

    func numberOfItemsInSection(_ section: Int) -> Int {
        return fetchedResultsController.sections?.first?.numberOfObjects ?? 0
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
}

