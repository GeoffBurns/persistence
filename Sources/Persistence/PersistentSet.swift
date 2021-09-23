//
//  PersistentSet.swift 
//
//  Created by Geoff Burns on 23/9/21.
//

import Foundation
import CoreData
import Utilities

open class PersistentSet<T : NSManagedObject,TKey>: ObservableObject {
   
   var container: NSPersistentContainer
   public var entityName : String
    
   @Published public var values: [T] = []
   
    public init(containerName: String, entityName: String) {
        container = NSPersistentContainer(name: containerName)
        self.entityName = entityName
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("ERROR LOADING CORE DATA. \(error)")
            }
        }
        load()
   }
   public func load() {
       let request = NSFetchRequest<T>(entityName: entityName)
       
       do {
           values = try container.viewContext.fetch(request)
       } catch let error {
           print("Error fetching. \(error)")
       }
   }
    open func assign(_ entity: T, key: TKey)
    {
        fatalError("assign not overriden")
    }
    open func make( key: TKey) -> T
    {
        let newValue = T(context: container.viewContext)
        assign(newValue,key: key)
        return newValue
    }
   public func add(_ key: TKey) {
       _ = make(key: key)
       saveData()
   }
   public func remove(_ entity: T) {
       container.viewContext.delete(entity)
       saveData()
   }
   func saveData() {
       do {
           try container.viewContext.save()
           load()
       } catch let error {
           print("CoreData Error saving. \(error)")
       }
   }
   open func has(_ entity: T, key: TKey) -> Bool
    {
        return undefined("has not overriden")
    }
   public func get(_ key: TKey) -> T?
   {
    return values.first { has($0,key: key) }
  
   }
   public func contains(_ key: TKey) -> Bool
   {
      return get(key) != nil
   }
   public func toggle(_ key: TKey)
   {
       if let entity = get(key)
       {
        remove(entity)
       }
       else
       {
           add(key)
       }
   }
}

