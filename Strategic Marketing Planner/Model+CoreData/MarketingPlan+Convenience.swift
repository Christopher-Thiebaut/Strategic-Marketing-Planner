//
//  MarketingPlan+Convenience.swift
//  Strategic Marketing Planner
//
//  Created by Christopher Thiebaut on 4/1/18.
//  Copyright © 2018 Christopher Thiebaut. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

extension MarketingPlan {
    
    enum OptionCategory: String {
        case foundation
        case `internal`
        case external
        case suburban
        case startup
        case businessToBusiness
    }
    
    var cost: Decimal {
        var currentCost: Decimal = 0
        if let options = options {
            for option in options {
                if let marketingOption = option as? MarketingOption, marketingOption.isActive {
                    currentCost += marketingOption.price?.decimalValue ?? 0
                }
            }
        }
        return currentCost
    }
    
    convenience init(practiceType: Client.PracticeType, targetContext context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        options = NSOrderedSet()
        switch practiceType {
        case .general:
            setupGeneralPracticeMarketingOptions()
        case .specialty:
            setupSpecialtyMarketingOptions()
        case .startup:
            setupStartupMarketingOptions()
        }
        lastModificationTimestamp = Date().timeIntervalSince1970
    }
    
    private func setupGeneralPracticeMarketingOptions()  {
        let options = NSMutableOrderedSet()
        for productInfo in ProductsInfo.foundationProduct {
            let descriptionIndex = ProductController.shared.products.index { (product) -> Bool in
                return product.title == productInfo.name
            }
            let marketingOption = MarketingOption(name: productInfo.name, price: productInfo.price, category: .foundation, description: nil, isActive: false, extendedDescriptionIndex: descriptionIndex)
            options.add(marketingOption)
        }
        for productInfo in ProductsInfo.internalMarketingProduct {
            let descriptionIndex = ProductController.shared.products.index { (product) -> Bool in
                return product.title == productInfo.name
            }
            let marketingOption = MarketingOption(name: productInfo.name, price: productInfo.price, category: .internal, description: nil, isActive: false, extendedDescriptionIndex: descriptionIndex)
            options.add(marketingOption)
        }
        let externalMarketingOption = MarketingOption(name: "no option selected", price: 0, category: .external, description: nil, isActive: true, extendedDescriptionIndex: nil)
        addToOptions(externalMarketingOption)
        addToOptions(options)
    }
    
    private func setupStartupMarketingOptions() {
        let startupOption = MarketingOption(name: "Startup Marketing Package", price: 0, category: .startup, isActive: false)
        addToOptions(startupOption)
    }
    
    private func setupSpecialtyMarketingOptions() {
        let options = NSMutableOrderedSet()
        for productInfo in ProductsInfo.foundationProduct {
            let descriptionIndex = ProductController.shared.products.index { (product) -> Bool in
                return product.title == productInfo.name
            }
            let marketingOption = MarketingOption(name: productInfo.name, price: productInfo.price, category: .foundation, description: nil, isActive: false, extendedDescriptionIndex: descriptionIndex)
            options.add(marketingOption)
        }
        let b2bMarketingOption = MarketingOption(name: "none", price: 0, category: .businessToBusiness, isActive: false)
        let externalMarketingOption = MarketingOption(name: "no option selected", price: 0, category: .external, description: nil, isActive: true, extendedDescriptionIndex: nil)
        addToOptions(b2bMarketingOption)
        addToOptions(options)
        addToOptions(externalMarketingOption)
    }
    
    func getOptionsForCategory(_ category: OptionCategory?, includeOnlyActive: Bool = false) -> [MarketingOption]{
        guard let category = category else { return [] }
        var selectedOptions: [MarketingOption] = []
        guard let options = self.options else {
            NSLog("No options found for category because the marketing plan's options have not been initialized.  This most likely represents an invalid state.")
            return []
        }
        for option in options {
            guard let marketingOption = option as? MarketingOption, let optionCategory = marketingOption.category else { continue }
            if optionCategory == category.rawValue {
                if includeOnlyActive && marketingOption.isActive || includeOnlyActive == false {
                    selectedOptions.append(marketingOption)
                }
            }
        }
        return selectedOptions
    }
    
    enum ExternalMarketingFocus: String {
        case digital
        case traditional
        case digitalTraditionalMix
    }
    
    enum BusinessToBusinessMarketing: String {
        case doctors
        case patients
        case both
    }
    
}

extension MarketingPlan: CloudKitSynchable {
    
    struct Relationships {
        static let client = "Client"
        //Relationship to marketinging option not needed, as it is the job of the marketing option to have a reference to its parent.
    }
    
    func addCKReferencesToCKRecord(_ record: CKRecord) {
        guard let client = client, let clientRecord = client.asCKRecord else { return }
        let reference = CKReference(record: clientRecord, action: .deleteSelf)
        record[Relationships.client] = reference
    }
    
    static func initializeRelationshipsFromReferences(_ record: CKRecord, model: MarketingPlan) -> Bool {
        guard let clientReference = record[Relationships.client] as? CKReference else { return false }
        let clientRecordName = clientReference.recordID.recordName
        guard let client = ClientController.shared.clients.first(where: {$0.recordName == clientRecordName}) else { return false }
        ClientController.shared.setMarketingPlan(model, forClient: client)
        return true
    }

}
