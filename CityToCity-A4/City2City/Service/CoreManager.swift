//
//  CoreManager.swift
//  City2City
//
//  Created by mac on 5/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import CoreData


let coreManager = CoreManager.sharedInstance

final class CoreManager {
    
    static let sharedInstance = CoreManager()
    private init() {}
    private var count = 0
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: Constants.Keys.City2City.rawValue)
        
        container.loadPersistentStores(completionHandler: { (persistentStore, err) in
            if let error = err {
                fatalError("Ya messed up")
            }
        })
        
        return container
    }()
    
    
    //MARK: Helpers
    
    func getCoreCities() -> [CoreCity] {
        
        //fetch request
        let fetchRequest = NSFetchRequest<CoreCity>(entityName: Constants.Keys.CoreCity.rawValue)
        
        //container
        var coreCities = [CoreCity]()
        
        do {
            
            coreCities = try context.fetch(fetchRequest)
            count = coreCities.count
            print("CoreCity Count: \(coreCities.count)")
            return coreCities
            
        } catch {
            
            return []
        }
    }
    
    //MARK: Delete
    func delete(with city: CoreCity) {
        
        context.delete(city)
        
        print("Deleted From Core: \(city.name!)")
        print("Added date: ", city.date!)
        saveContext()
        
        count -= 1
    }
    
    
     //MARK: Save
    func save(with city: City) {
        
        // make sure the max number of saved cities is not greater than 10
        if count < 10 {
            print("Count = \(count), save right way")
            // save right way
            checkThenSave(with: city)
        } else {
            print("Hit the max count, will remove the oldest record before save")
            // delete the oldest data, and save
            var cityToDelete = getCoreCities()[0]
            var oldestDate = getCoreCities()[0].date
            for ci in getCoreCities() {
                if ci.date! < oldestDate! {
                    oldestDate = ci.date
                    cityToDelete = ci
                }
            }
            delete(with: cityToDelete)
            checkThenSave(with: city)
        }
     
    }
    
    func saveContext() {
        do {
           try context.save()
        } catch {
            fatalError("Couldn't save the context")
        }
    }
    
    
    // helping function - to check if the city is already saved
    private func checkExistence(with city: City) -> Bool {
        
        /*
         duplication check way 1
         */
        // set a NSFetchRequest
//        let checkRequest = NSFetchRequest<CoreCity>(entityName: Constants.Keys.CoreCity.rawValue)
//        checkRequest.predicate = NSPredicate(format: "name = %@", city.name)
//
//        do {
//            let cities = try persistentContainer.viewContext.fetch(checkRequest)
//
//            // 0 if none, 1 if existed
//            if cities.count == 0 {
//                return false
//            } else {
//                return true
//            }
//        } catch {
//            print("Error: \(error.localizedDescription)")
//            return false
//        }
        
        /*
            duplication check way 2
        */
        for coreCity in getCoreCities() {
            if City(with: coreCity) == city {
                return true
            }
        }
        return false
    }
    
    private func checkThenSave(with city: City) {
        //entity description
        let entity = NSEntityDescription.entity(forEntityName: Constants.Keys.CoreCity.rawValue, in: context)!
        // check before save
        if !checkExistence(with: city) {
            // save
            //core entity
            let coreCity = NSManagedObject(entity: entity, insertInto: context)
            
            coreCity.setValue(city.name, forKey: Constants.Core.name.rawValue)
            coreCity.setValue(city.state, forKey: Constants.Core.state.rawValue)
            coreCity.setValue(city.population, forKey: Constants.Core.population.rawValue)
            coreCity.setValue(city.coordinates.latitude, forKey: Constants.Core.latitude.rawValue)
            coreCity.setValue(city.coordinates.longitude, forKey: Constants.Core.longitude.rawValue)
            coreCity.setValue(city.rank, forKey: Constants.Core.rank.rawValue)
            coreCity.setValue(city.date, forKey: Constants.Core.date.rawValue)
            
            //save context
            saveContext()
            print("Saved City To Core: \(city.name), \(city.state)")
            count += 1
        }
    }
}
