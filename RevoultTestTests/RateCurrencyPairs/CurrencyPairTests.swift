//
//  CurrencyPairTests.swift
//  RevoultTestTests
//
//  Created by Ajay Odedra on 18/11/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.
//

import XCTest
import CoreData
@testable import RevoultTest

class CurrencyPairTests: XCTestCase {

    var currencyPairViewModel:CurrencyPairViewModel?
      
    // MARK: - get Currency Pairs
    func testCurrenciesPairTests() {
        
        let appServerClient = MockAppServerClient()
        let currencyExpectation = expectation(description: "Currency")
        var currencyResponse: [String:Any]?
        
        appServerClient.getRates(of: ["GBPINR"]) { result in
            switch result {
            case .success(let pairs):
                currencyResponse = pairs
                currencyExpectation.fulfill()
            case .failure( _):
                XCTFail()
                return
            }
            
        }
         waitForExpectations(timeout: 2) { (error) in
           XCTAssertNotNil(currencyResponse)
         }
    }

    func testCoreDataInsertandLoadTests(){
        currencyPairViewModel = CurrencyPairViewModel()
        
        let coreDataExpectation = expectation(description: "CurrencyAdd")
        var isSaved = false
        
        currencyPairViewModel?.loadCurrenciesPairs {
            guard let container = self.currencyPairViewModel?.container else {
                XCTFail()
                return
            }
            
            let context = container.viewContext
            context.automaticallyMergesChangesFromParent = true
            CurrencyPair.insertInto(context, pair: (id: "GBPUSD", index: 1))
            do {
                try context.save()
                isSaved = true
                coreDataExpectation.fulfill()
            } catch {
                XCTFail()
            }
        }
        waitForExpectations(timeout: 5) { (error) in
          XCTAssertTrue(isSaved)
        }
    }
}

private final class MockAppServerClient: AppServerClient {
    var getCurrencyPair: AppServerClient.GetRateResult?
    
}
