//
//  JSON+Extension.swift
//  Memu
//
//  Created by Akash Arun Jambhulkar (Digital) on 5/1/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

extension JSON {

    /**
     Save JSON object into given file

     - parameter fileName: the file name

     - returns: the URL of the saved file
     */
    func saveFile(_ fileName: String) -> Foundation.URL? {
        do {
            let data = try self.rawData()
            return FileUtil.saveContentFile(fileName, data: data)
        } catch {
            return nil
        }
    }

    /**
     Get JSON object from given file

     - parameter fileName: the file name

     - returns: JSONObject
     */
    static func contentOfFile(_ fileName: String) -> JSON? {
        let url = FileUtil.getLocalFileURL(fileName)
        if FileManager.default.fileExists(atPath: url.path) {
            if let data = try? Data(contentsOf: Foundation.URL(fileURLWithPath: url.path)) {
                return try? JSON(data: data)
            }
        }
        return nil
    }

    /// Shortcur method for getting non-nil JSON
    ///
    /// - Parameter name: the resource name
    /// - Returns: JSON
    static func res(named name: String) -> JSON {
        return JSON.resource(named: name) ?? JSON.null
    }

    /**
     Get JSON from resource file

     - parameter name:    resource name
     */
    static func resource(named name: String) -> JSON? {
        guard let resourceUrl = Bundle.main.url(forResource: name, withExtension: "json") else {
            fatalError("Could not find resource \(name)")
        }

        // create data from the resource content
        var data: Data
        do {
            data = try Data(contentsOf: resourceUrl, options: Data.ReadingOptions.dataReadingMapped) as Data
        } catch let error {
            print("ERROR: \(error)")
            return nil
        }
        // reading the json
        return try? JSON(data: data)
    }
}
