//
//  CurrenciesList.swift
//  RevoultTestTests
//
//  Created by Ajay Odedra on 18/11/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.
//

import XCTest
@testable import RevoultTest

class CurrenciesListTests: XCTestCase {

    var currenciesViewModel:CurrenciesViewModel?
    
    // MARK: - get Currencies
    func testJSONCurrencyCells() {
        
        let appServerClient = MockAppServerClient()
        appServerClient.getCurrencies = .success(payload: Currencies.get())
        
        let currencyExpectation = expectation(description: "Currencies Loaded")
        var currencyResponse: [Currencies]?
        
        appServerClient.getCurrency { (result) in
            switch result {
            case .success(let currencies):
                currencyResponse = currencies
                currencyExpectation.fulfill()
            case .failure( _):
                XCTFail()
                return
            }
        }
        waitForExpectations(timeout: 3) { (error) in
            XCTAssertNotNil(currencyResponse)
        }
    }
    func testNormalCurrencyMockDataCells() {
        
        let appServerClient = MockAppServerClient()
        appServerClient.getCurrencies = .success(payload: Currencies.get())
        
        let viewModel = CurrenciesViewModel(appServerClient: appServerClient)
        viewModel.getCurrencies()
        
        guard case .some(.normal(_)) = viewModel.currencyCells.value.first else {
            XCTFail()
            return
        }
    }
    func testEmptyCurrencyCells() {
        let appServerClient = MockAppServerClient()
        appServerClient.getCurrencies = .success(payload: [])
        
        let viewModel = CurrenciesViewModel(appServerClient: appServerClient)
        viewModel.getCurrencies()
        
        guard case .some(.empty) = viewModel.currencyCells.value.first else {
            XCTFail()
            return
        }
    }
    func testErrorCurrencyCells() {
        let appServerClient = MockAppServerClient()
        appServerClient.getCurrencies = .failure(AppServerClient.GetFailureReason.notFound)
        
        let viewModel = CurrenciesViewModel(appServerClient: appServerClient)
        viewModel.getCurrencies()
        
        guard case .some(.error(_)) = viewModel.currencyCells.value.first else {
            XCTFail()
            return
        }
    }

}

private final class MockAppServerClient: AppServerClient {
    var getCurrencies: AppServerClient.GetCurrencyResult?
    
    override func getCurrency(completion: @escaping AppServerClient.GetCurrencyCompletion) {
        completion(getCurrencies!)
    }
}
