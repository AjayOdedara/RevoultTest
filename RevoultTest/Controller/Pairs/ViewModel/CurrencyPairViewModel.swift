//
//  CurrenciesViewModel.swift
//  RevoultTest
//
//  Created by Ajay Odedra on 05/11/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.
//

import Foundation
import UIKit
import CoreData


protocol UpdateRateDataDelegate: UIViewController {
    // insert data delegate setup
    func updateData()
}

class CurrencyPairViewModel:NSObject{
    
    var container: NSPersistentContainer?
    var dataProvider: FetchedResultsDataProvider<CurrencyPair>?
    
//    enum CurrencyPairTableViewCellType {
//        case normal(cellViewModel: CurrencyPair)
//        case error(message: String)
//        case empty
//    }
//    let currencyPairCells = Bindable([CurrencyPairTableViewCellType]())
    //https://stackoverflow.com/a/28258374
    weak var delegate: UpdateRateDataDelegate?
    var currentPairs = [String]()
    
    var onShowError: ((_ alert: SingleButtonAlert) -> Void)?
    
    // API INIT
    let appServerClient: AppServerClient
    init(appServerClient: AppServerClient = AppServerClient()) {
        self.appServerClient = appServerClient
    }
    
    func getRatesOfCurrentPairs() {
        
        appServerClient.getRates(of: self.currentPairs, completion: { [weak self] result in
            switch result {
            case .success(let pairs):
                print(pairs)
                self?.updatePairs(data: pairs, { (success) in
                    self?.loadCurrenciesPairs {
                        self?.delegate?.updateData()
                    }
                })
            case .failure(let error):
                print(error?.localizedDescription)
//                self?.currencyPairCells.value = [.error(message: error?.localizedDescription ?? "Error occurred")]
            }
        })
    }
    
    func loadCurrenciesPairs( _ completionBlock : @escaping ()->()) {
        let container = NSPersistentContainer(name: "CurrencyPair")
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
                let data = self.dataProvider?.currencyPairs().map { $0.pairId ?? "" }
                self.currentPairs = data ?? [""]
                completionBlock()
            }
        }
        self.container = container
    }
    
    func insertPair(with newPair:String) {
        self.currentPairs.append(newPair)
        guard let container = container else {
            return
        }
        container.performBackgroundTask{(moc) in
            let index = "\((self.dataProvider?.currencyPairs().count ?? 0) + 1)"
            CurrencyPair.insertInto(moc, pair: (id: newPair, index: index))
            do {
                try moc.save()
            } catch {
                DLog(error.localizedDescription)
            }
        }
    }
    func updatePairs(data pairToAdd: AppServerClient.PairResults, _ completionBlock : @escaping (Bool)->()){
        guard let container = container else {
            return
        }
        container.performBackgroundTask{(moc) in
            pairToAdd.forEach { (pair) in
                CurrencyPair.update(moc, pair: (id: pair.key, value: (pair.value as? Double ?? 0.0).rounded(toPlaces:4)))
            }
            completionBlock(true)
        }
    }
    func deletePair(objectOf id:String) {
        print("Before Pair \(currentPairs)")
        currentPairs = currentPairs.filter { $0 != id }
        print("After Pair \(currentPairs)")
        
        
        guard let container = container else {
            return
        }
        container.performBackgroundTask{(moc) in
            let context = container.viewContext
            context.automaticallyMergesChangesFromParent = true
            
            let objectToDelete = self.dataProvider?.currencyPairs().filter{$0.pairId == id}
            guard let delete = objectToDelete?.first else {
                print("No object found")
                return
            }
            context.delete(delete)
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
        DLog("Contact list table view failed to return cell")
        return UITableViewCell()
        /*switch currencyPairCells.value[indexPath.row] {
        case .normal(let pair):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyPairListCell.identifier) as? CurrencyPairListCell else {
                return UITableViewCell()
            }
            cell.pair = pair
            return cell
            
        case .error(let message):
            let cell = UITableViewCell()
            cell.isUserInteractionEnabled = false
            cell.textLabel?.text = message
            return cell
            
        case .empty:
            let cell = UITableViewCell()
            cell.isUserInteractionEnabled = false
            cell.textLabel?.text = "No currencies available"
            return cell
        }*/
        
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            guard let cell = tableView.cellForRow(at: indexPath) as? CurrencyPairListCell, let pair = cell.pair else {
                print("Failed to delete cell")
                return
            }
            deletePair(objectOf: pair.pairId ?? "")
            tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
}

