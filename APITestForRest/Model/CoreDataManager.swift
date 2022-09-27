//
//  CoreDataManager.swift
//  APITestForRest
//
//  Created by yeoh on 26/09/2022.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager(modelName: "Model")
    let persistentContainer: NSPersistentContainer
    var context: NSManagedObjectContext {return persistentContainer.viewContext}
    
    init(modelName: String){
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (()->Void)? = nil) {
        persistentContainer.loadPersistentStores { description, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            }
            catch {
                print("Save error: \(error)")
            }
        }
    }
}
//MARK: CoreDataManager的一些使用方法
extension CoreDataManager {
    func addData(maskInfo: MaskInfo){
        let maskInfoTable = MaskInfoTable(context: context)
        maskInfoTable.id = maskInfo.id
        maskInfoTable.name = maskInfo.name
        maskInfoTable.phone = maskInfo.phone
        maskInfoTable.address = maskInfo.address
        maskInfoTable.mask_adult = Int32(maskInfo.mask_adult)
        maskInfoTable.mask_child = Int32(maskInfo.mask_child)
        maskInfoTable.county = maskInfo.county
        maskInfoTable.town = maskInfo.town
        maskInfoTable.cunli = maskInfo.cunli
        save()
    }
    //MARK: 刪除資料
    func deleteData(maskInfoTable: MaskInfoTable) {
        context.delete(maskInfoTable)
        save()
    }
    
    //MARK: 用來生成條件設好的nsFetchResultController WARNING：要注意的是一般viewdidLoad設置及篩選可使用 但如果篩選後要進行動作的話會沒有效果(即 增刪修更) 直接在已有的(NSfetchResultController).fetchRequest.predicate進行修改即可
    func createMaskInfoTableFetchResultController(filter: String? = nil, sorter: String? = nil) -> NSFetchedResultsController<MaskInfoTable> {
        let fetchRequest = NSFetchRequest<MaskInfoTable>(entityName: "MaskInfoTable")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: sorter, ascending: true)]
        
        if let filter = filter {
            let predicate = NSPredicate(format: "town == %@", filter)
            fetchRequest.predicate = predicate
        }
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
}
