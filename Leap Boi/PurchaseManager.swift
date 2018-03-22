//
//  PurchaseManager.swift
//  Leap Boi
//
//  Created by Robert Desjardins on 2018-03-20.
//  Copyright © 2018 Robert Desjardins. All rights reserved.
//


typealias CompletionHandler = (_ success: Bool) -> ()

import Foundation
import StoreKit

class PurchaseManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let instance = PurchaseManager()
    
    let IAP_5000_CREDITS = "desjardins.robert.buy.5000.credits"
    
    var productsRequest: SKProductsRequest!
    var products = [SKProduct]()
    var transactionComplete: CompletionHandler?
    
    func fetchProducts() {
        let productIds = NSSet(object: IAP_5000_CREDITS) as! Set<String>
        productsRequest = SKProductsRequest(productIdentifiers: productIds)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    func purchase5000Credits(onComplete: @escaping CompletionHandler) {
        if SKPaymentQueue.canMakePayments() && products.count > 0 {
            transactionComplete = onComplete
            let credits5000Product = products[0]
            let payment = SKPayment(product: credits5000Product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
        } else {
            onComplete(false)
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count > 0 {
            // Can find price from products
            print("Gets productsRequest")
            print(response.products.debugDescription)
            products = response.products
        } 
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                if transaction.payment.productIdentifier == IAP_5000_CREDITS {
                    GameData.shared.totalCredits = UserDefaults.standard.getUserCredits()
                    GameData.shared.totalCredits = GameData.shared.totalCredits + 5000
                    UserDefaults.standard.setUserCredits(credits: GameData.shared.totalCredits )
                    transactionComplete?(true)
                }
                break
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionComplete?(false)
                break
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionComplete?(true)
                break
            default:
                transactionComplete?(false)
                break
            }
        }
    }
    
}
