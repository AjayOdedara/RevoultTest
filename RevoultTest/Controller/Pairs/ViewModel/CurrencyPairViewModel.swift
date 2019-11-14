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
    
    weak var delegate: UpdateRateDataDelegate?
    var currentPairs = [String]()
    
    var onShowError: ((_ alert: SingleButtonAlert) -> Void)?
    
    // API INIT
    let appServerClient: AppServerClient
    init(appServerClient: AppServerClient = AppServerClient()) {
        self.appServerClient = appServerClient
    }
    
    
    /*
     Add currency from list
     Make API call with currency + Plus if old added then add to it in URL
     Save Data
     Display it
     
     */
    func prepareURL() -> String{
        var url = ""
        for currencyId in self.currentPairs{
            url = url + "pairs=" + currencyId + "&"
        }
        return String(url.dropLast())
    }
    func getRatesOfCurrentPairs() {
        //pairs=GBPEUR&pairs=GBPUSD
        appServerClient.getRates(of: prepareURL(), completion: { [weak self] result in
            switch result {
            case .success(let pairs):
                print(pairs)
                self?.updateData(data: pairs){ (isSuccess) in
                    self?.loadCurrenciesPairs { () in
                        self?.delegate?.updateData()
                    }
                }
            case .failure(let error):
                print(error?.localizedDescription)
                self?.loadCurrenciesPairs { () in
                    self?.delegate?.updateData()
                }
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
                
                print(self.dataProvider?.numberOfItemsInSection(0))
                guard ( self.dataProvider?.numberOfItemsInSection(0) ?? 0 ) > 0  else {
                    completionBlock()
                    return
                }
                self.currentPairs.removeAll()
                for item in 0...( self.dataProvider?.numberOfItemsInSection(0) ?? 0 ) - 1{
                    let provider = self.dataProvider?.object(at: IndexPath(item: item, section: 0))
                    print(provider?.pairId)
                    print(provider?.currentRates)
                    let pair = ( provider?.fromPairId ?? "" ) + ( provider?.toPairId ?? "" )
                    self.currentPairs.append(pair)
                }
//                self.getRatesOfCurrentPairs()
                completionBlock()
            }
        }
        self.container = container
    }
    
    func insertIntoPairs(with newPair:String) {
        self.currentPairs.append(newPair)
        getRatesOfCurrentPairs()
//        completionBlock(false)
    }
    
    func preservePairs(data pairToAdd: [CurrrencyRatePairs], _ completionBlock : @escaping (Bool)->()) {
        // insert into coredata
        guard let container = container else {
            return
        }
        container.performBackgroundTask { (managedObjectContext) in
            for pair in pairToAdd{
                CurrencyPair.insertInto(managedObjectContext, pair: pair)
            }
            do {
                try managedObjectContext.save()
                completionBlock(true)
            } catch {
                completionBlock(false)
                DLog(error.localizedDescription)
            }
        }
    }
    func updateData(data pairToAdd: [CurrrencyRatePairs], _ completionBlock : @escaping (Bool)->()){
        guard let container = container else {
            return
        }
        container.performBackgroundTask{(moc) in
            for pair in pairToAdd{
                
                let mocIds = CurrencyPair.update(moc, pair: pair)
                if mocIds.count == 0{
                    CurrencyPair.insertInto(moc, pair: pair)
                    do {
                        try moc.save()
                    } catch {
                        DLog(error.localizedDescription)
                    }
                }else{
                    let changes = [NSUpdatedObjectsKey: mocIds]
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [moc])
                }
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
        // Get managed object
        guard let provider = dataProvider?.object(at: indexPath) else { return UITableViewCell() }
        
        // Configure Cell
        if let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyPairListCell.identifier, for: indexPath) as? CurrencyPairListCell {
            // set cell data
            cell.item = provider
            return cell
        }
        DLog("Pairs list table view failed to return cell")
        return UITableViewCell()
    }
}

