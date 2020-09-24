//
//  SaveManager.swift
//  AutoCatalog
//
//  Created by Uzver on 16.09.2020.
//  Copyright © 2020 Home. All rights reserved.
//

import RealmSwift

let realm = try! Realm()

class SaveManager {
    static func saveObject (_ autoDB: AutoDB) {
        try! realm.write {
            realm.add(autoDB)
        }
    }
    static func deleteObject (_ autoDB: AutoDB) {
        try! realm.write {
            realm.delete(autoDB)
        }
    }
}
