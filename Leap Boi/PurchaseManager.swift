//
//  PurchaseManager.swift
//  Leap Boi
//
//  Created by Robert Desjardins on 2018-03-20.
//  Copyright © 2018 Robert Desjardins. All rights reserved.
//

import Foundation
import StoreKit

class PurchaseManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let instance = PurchaseManager()
    
    let IAP_5000_CREDITS = "desjardins.robert.buy.5000.credits"
    
    var productsRequest: SKProductsRequest!
    var products = [SKProduct]()
    
    func fetchProducts() {
        let productIds = NSSet(object: IAP_5000_CREDITS) as! Set<String>
        productsRequest = SKProductsRequest(productIdentifiers: productIds)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count > 0 {
            // Can find price from products
            print("Gets productsRequest")
            print(response.products.debugDescription)
            products = response.products
        } else {
            print("no :(")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
}
