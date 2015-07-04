//
//  TestDataset.swift
//  SaguaroJSON
//
//  Created by darryl west on 7/4/15.
//  Copyright © 2015 darryl west. All rights reserved.
//

import Foundation
import SaguaroJSON

public struct DocumentIdentifier: CustomStringConvertible {
    public let id:String
    public let dateCreated:NSDate
    public private(set) var lastUpdated:NSDate
    public private(set) var version:Int
    
    // initializer used for new documents
    public init() {
        id = DocumentIdentifier.createModelId()
        dateCreated = NSDate()
        lastUpdated = NSDate()
        version = 0
    }
    
    // initializer for documents that currently exist
    public init(id:String, dateCreated:NSDate, lastUpdated:NSDate, version:Int) {
        self.id = id
        self.dateCreated = dateCreated
        self.lastUpdated = lastUpdated
        self.version = version
    }
    
    // invoke this to bump the last updated and version values
    mutating func updateVersion() {
        lastUpdated = NSDate()
        ++version
    }
    
    public var description:String {
        return "id:\( id ), created:\( dateCreated ), updated:\( lastUpdated ), version: \( version )"
    }
    
    // convenience func for creating standard 32 character id's
    public static func createModelId() -> String {
        let uuid = NSUUID().UUIDString.lowercaseString
        let mid = uuid.stringByReplacingOccurrencesOfString("-", withString:"")
        
        return mid
    }
}

struct TestDataset {
    let jnparser = JNParser()
    
    func createDocumentIdentifierMap() -> [String:AnyObject] {
        let doi = DocumentIdentifier()
        
        let map:[String:AnyObject] = [
            "id": doi.id,
            "dateCreated": doi.dateCreated,
            "lastUpdated": doi.lastUpdated,
            "version": doi.version
        ]
        
        return map
    }
    
    func createComplexJSONMap() -> [String:AnyObject] {
        let name = "farley"
        let age = 42
        let height = 4.3
        let created = jnparser.dateFromString( "2015-06-18T09:47:49.427+0000" )!
        
        var model = createDocumentIdentifierMap()
        model[ "names" ] = ["jon","jane","joe"]
        model[ "jobs" ] = [
            "job1":"my job 1",
            "job2":"my second job",
            "job 3":"my third job"
        ]
        
        let obj:[String:AnyObject] = [
            "name": name,
            "age": age,
            "height": height,
            "created": created,
            "hasHair": false,
            "nullvalue":NSNull(),
            "model":model
        ]
        
        return obj
    }
}