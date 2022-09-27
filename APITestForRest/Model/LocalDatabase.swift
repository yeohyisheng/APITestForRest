////
////  LocalDatabase.swift
////  APITestForRest
////
////  Created by yeoh on 15/09/2022.
////
//
//import Foundation
//import RealmSwift
//
//// MARK: 管理資料庫的物件 用於新增刪除修改查詢
//class LocalDatabase:NSObject {
//    static let shared = LocalDatabase()
//
//    func add(maskInfo: MaskInfo){
//        let realm = try! Realm()
//        do {
//            try! realm.write{
//                
//                let maskInfoDB = MaskInfoDB()
//                maskInfoDB.name = maskInfo.name
//                maskInfoDB.phone = maskInfo.phone
//                maskInfoDB.address = maskInfo.address
//                maskInfoDB.mask_adult = maskInfo.mask_adult
//                maskInfoDB.mask_child = maskInfo.mask_child
//                maskInfoDB.county = maskInfo.county
//                maskInfoDB.town = maskInfo.town
//                maskInfoDB.cunli = maskInfo.cunli
//
//                realm.add(maskInfoDB)
//
//            }
//
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
//}
//
//// MARK: 資料表
//class MaskInfoDB: Object {
//    @Persisted(primaryKey: true) var _id: ObjectId
//    @Persisted var name: String = ""
//    @Persisted var phone: String = ""
//    @Persisted var address: String = ""
//    @Persisted var mask_adult: Int = 0
//    @Persisted var mask_child: Int = 0
//    @Persisted var county: String = ""
//    @Persisted var town: String = ""
//    @Persisted var cunli: String = ""
//}
