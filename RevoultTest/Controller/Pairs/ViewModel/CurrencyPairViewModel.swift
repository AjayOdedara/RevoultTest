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
    
    enum CurrencyPairTableViewCellType {
        case normal(cellViewModel: CurrencyPairCellViewModel)
        case error(message: String)
        case empty
    }
    let currencyPairCells = Bindable([CurrencyPairTableViewCellType]())
    
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
                guard pairs.count > 0 else {
                    self?.currencyPairCells.value = [.empty]
                    return
                }
                self?.currencyPairCells.value = pairs.compactMap {
                    .normal(cellViewModel: $0 as CurrencyPairCellViewModel)
                }
//                self?.updateData(data: pairs){ (isSuccess) in
//                    self?.loadCurrenciesPairs { () in
//                        self?.delegate?.updateData()
//                    }
//                }
            case .failure(let error):
                self?.currencyPairCells.value = [.error(message: error?.localizedDescription ?? "Error occurred")]
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
    
    func insertIntoPairs(with newPair:String) {
        self.currentPairs.append(newPair)
        getRatesOfCurrentPairs()
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
        return currencyPairCells.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch currencyPairCells.value[indexPath.row] {
        case .normal(let viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyPairListCell.identifier) as? CurrencyPairListCell else {
                return UITableViewCell()
            }
            cell.viewModel = viewModel
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
        }
    }
}

