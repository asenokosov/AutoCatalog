//
//  AutoDB.swift
//  AutoCatalog
//
//  Created by Uzver on 16.09.2020.
//  Copyright © 2020 Home. All rights reserved.
//

import RealmSwift

class AutoDB: Object {
    @objc dynamic var nameAuto = ""
    @objc dynamic var yearAuto: String?
    @objc dynamic var imageAuto: Data?
    @objc dynamic var carcaseAuto: String?
    @objc dynamic var manufacturerAuto: String?
    
    convenience init(nameAuto: String, yearAuto: String?, imageAuto: Data?, carcaseAuto: String?, manufacturerAuto: String?) {
    self.init()
        self.nameAuto = nameAuto
        self.yearAuto = yearAuto
        self.imageAuto = imageAuto
        self.carcaseAuto = carcaseAuto
        self.manufacturerAuto = manufacturerAuto
    }
}
