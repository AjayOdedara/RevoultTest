//
//  CurrenciesViewModel.swift
//  RevoultTest
//
//  Created by Ajay Odedra on 12/11/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.
//

import Foundation
import UIKit
import CoreData


protocol UpdateRateDataDelegate: UIViewController {
    // insert/update data delegate setup
    func update(data isSucess:Bool)
    func reloadTableCells()
}

class CurrencyPairViewModel:NSObject{
    
    var container: NSPersistentContainer?
    var dataProvider: FetchedResultsDataProvider<CurrencyPair>?
    weak var delegate: UpdateRateDataDelegate?

    // API INIT
    let appServerClient: AppServerClient
    init(appServerClient: AppServerClient = AppServerClient()) {
        self.appServerClient = appServerClient
    }
    
    func getRatesOfCurrentPairs() {
        let currentPairs = self.dataProvider?.currencyPairs().map { $0.pairId } ?? [""]
        appServerClient.getRates(of: currentPairs, completion: { [weak self] result in
            switch result {
            case .success(let pairs):
                self?.updatePairs(data: pairs, { (success) in
                    self?.loadCurrenciesPairs {
                        //DLog("Loaded data")
                    }
                })
            case .failure(let error):
                print(error?.localizedDescription ?? "error to get currency pairs")
                self?.delegate?.update(data: false)
            }
        })
    }
    
    func loadCurrenciesPairs( _ completionBlock : @escaping ()->()) {
        let container = NSPersistentContainer(name: "CurrencyRatePairs")
        container.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                DLog(error?.localizedDescription ?? "Failed to load Persistent Stores")
                return
            }
            
            let context = container.viewContext
            context.automaticallyMergesChangesFromParent = true
            // featching the data from coredata
            DispatchQueue.main.async {
                let fetchRequest = CurrencyPair.defaultFetchRequest()
                let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
                self.dataProvider = FetchedResultsDataProvider(fetchedResultsController: frc)
                self.dataProvider?.currencyPairs().count ?? 0 > 0 ? self.delegate?.update(data: true) : self.delegate?.reloadTableCells()
                completionBlock()
            }
        }
        self.container = container
    }
    
    func insertPair(with newPair:String, _ completionBlock : @escaping (Bool)->()) {
//        self.currentPairs.append(newPair)
        guard let container = container else {
            return
        }
        container.performBackgroundTask{(moc) in
            let index = Double(self.dataProvider?.currencyPairs().count ?? 0) + 1
            print("inserted at = \(index) with pair = \(newPair)")
            CurrencyPair.insertInto(moc, pair: (id: newPair, index: index))
            do {
                try moc.save()
                self.loadCurrenciesPairs { self.delegate?.reloadTableCells() }
                //optional
                completionBlock(true)
            } catch {
                DLog(error.localizedDescription)
                completionBlock(false)
            }
        }
    }
    func updatePairs(data pairToAdd: AppServerClient.PairResults, _ completionBlock : @escaping (Bool)->()){
        guard let container = container else {
            return
        }
        container.performBackgroundTask{(moc) in
            pairToAdd.forEach { (pair) in
                CurrencyPair.update(pair: moc, pair: (id: pair.key, value: (pair.value as? Double ?? 0.0).rounded(toPlaces:4)))
            }
            completionBlock(true)
        }
    }
    func deletePair(objectOf id:String,_ completionBlock : @escaping (Bool)->()) {
        guard let container = container else {
            return
        }
        container.performBackgroundTask{(moc) in
            CurrencyPair.delete(pair: moc, pairId: id)
            do {
                try moc.save()
            } catch {
                completionBlock(false)
                DLog(error.localizedDescription)
            }
            completionBlock(true)
        }
    }
}

// MARK: Table View Data Source
extension CurrencyPairViewModel: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // get number of rows count for each section
        return dataProvider?.numberOfItemsInSection(section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let provider = dataProvider?.object(at: indexPath) else { return UITableViewCell() }
        
        // Configure Cell
        if let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyPairListCell.identifier, for: indexPath) as? CurrencyPairListCell {
            // set cell data
            cell.pair = provider
            return cell
        }
        DLog("Currency list table view failed to return cell")
        return UITableViewCell()
        
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            guard let cell = tableView.cellForRow(at: indexPath) as? CurrencyPairListCell, let provider = dataProvider?.currencyPairs(), provider.count > 0, let id = tableView.indexPath(for: cell)?.row  else {
                print("Failed to delete cell")
                return
            }
            print("\(provider[id].pairId)")
            deletePair(objectOf: provider[id].pairId ){ (isSuccess) in
                
                if isSuccess{
                    DispatchQueue.main.async {
                        tableView.beginUpdates()
                        tableView.deleteRows(at: [indexPath], with: .left)
                        tableView.endUpdates()
                    }
                }
            }
        }
    }
}

