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
        version += 1
    }
    
    public var description:String {
        return "id:\( id ), created:\( dateCreated ), updated:\( lastUpdated ), version: \( version )"
    }
    
    // convenience func for creating standard 32 character id's
    public static func createModelId() -> String {
        let uuid = NSUUID().uuidString.lowercased() as NSString
		let mid = uuid.replacingOccurrences(of: "-", with: "")
        
        return mid
    }
}

class TestDataset {
    let jnparser = JNParser()

    func createDocumentIdentifierMap() -> [String:AnyObject] {
        let uuid = NSUUID().uuidString.lowercased() as NSString
		let mid = uuid.replacingOccurrences(of: "-", with: "")

        let map = [
            "id":mid as AnyObject,
            "dateCreated":NSDate(),
            "lastUpdated":NSDate(),
            "version":"1.0" as AnyObject
        ] as [String : AnyObject]

        return map
    }

    func createComplexJSONMap() -> [String:AnyObject] {
        let name = "farley"
        let age = 42
        let height = 4.3
        let created = jnparser.dateFromString( "2015-06-18T09:47:49.427Z" )!

        var model = createDocumentIdentifierMap()
		model[ "names" ] = ["jon","jane","joe"] as AnyObject
        model[ "jobs" ] = [
            "job1":"my job 1",
            "job2":"my second job",
            "job 3":"my third job",
            "color":UIColor(red: 100.0/255, green:110.0/255, blue:120.0/255, alpha: 1.0),
            "rect":JNRect( rect:CGRect(x: -44, y: 23, width: 400, height: 200) )
        ] as AnyObject

        let obj:[String:AnyObject] = [
            "name": name as AnyObject,
            "age": age as AnyObject,
            "height": height as AnyObject,
            "created": created as AnyObject,
            "hasHair": false as AnyObject,
            "newcolor": UIColor.blue,
            "nullvalue":NSNull(),
            "model":model as AnyObject
        ]
        
        return obj
    }

    var fixturePath:String {
		var parts = #file.components(separatedBy: "/")

        parts.removeLast()

        return "/" + parts.joined(separator: "/")
    }

    func readFixtureFile(filename:String) -> String? {
        let path = fixturePath + "/" + filename

        do {
            let text = try String(contentsOfFile: path, encoding: String.Encoding.utf8)

            return text
        } catch let error as NSError {
            NSLog("error reading \( path ) : \(error)")
            return nil
        }
    }
}
