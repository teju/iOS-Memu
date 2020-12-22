//
//  CustomView.swift
//  Memu
//
//  Created by Akash Arun Jambhulkar (Digital) on 4/28/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation
import SwiftyJSON

// Subdirectory name for saved files
let contentDirectory = "content"

/**
 * Utility for accessing local files (save/load)
 *
 * - author: TCCODER
 * - version: 1.0
 */
class FileUtil {

    /**
     Saves content file with given id and data. Returns url to local file or nil if error occur

     - parameter fileName: the file name
     - parameter data:     the data

     - returns: the URL of the file
     */
    class func saveContentFile(_ fileName: String, data: Data) -> URL? {
        if saveDataToDocumentsDirectory(data, path: fileName, subdirectory: contentDirectory) {
            return FileUtil.getLocalFileURL(fileName)
        }
        return nil
    }

    /**
     Remove given file

     - parameter fileName: the file name
     */
    class func removeFile(_ fileName: String) {
        let path = fileName
        let subdirectory = contentDirectory

        // Create generic beginning to file save path
        var savePath = self.applicationDocumentsDirectory().path+"/"

        // Subdirectory
        savePath += subdirectory
        savePath += "/"

        // Add requested save path
        savePath += path

        if FileManager.default.fileExists(atPath: savePath as String, isDirectory:nil) {

            // Remove file
            do {
                try FileManager.default.removeItem(atPath: savePath)
            } catch let error {
                print(error)
            }
        }
    }

    /**
     Saves data on the given path in subdirectory in Documents

     - parameter fileData:     the data
     - parameter path:         the main path
     - parameter subdirectory: the subdirectory name

     - returns: true - if successfully saved, false - else
     */
    class func saveDataToDocumentsDirectory(_ fileData: Data, path: String, subdirectory: String?) -> Bool {

        // Create generic beginning to file save path
        var savePath = self.applicationDocumentsDirectory().path + "/"

        // Subdirectory
        if let dir = subdirectory {
            savePath += dir
            _ = self.createSubDirectory(savePath)
            savePath += "/"
        }

        // Add requested save path
        savePath += path

        // Save the file and see if it was successful
        let boolVal: Bool = FileManager.default.createFile(atPath: savePath, contents:fileData, attributes:nil)

        // Return status of file save
        return boolVal
    }
    
    class func isExist(_ fileName: String) -> Bool {
        
        // Create generic beginning to file save path
        var savePath = self.applicationDocumentsDirectory().path + "/" + contentDirectory + "/"
        
        // Subdirectory
        savePath += fileName
    
        if FileManager.default.fileExists(atPath: savePath as String, isDirectory:nil) {
            return true
        }
        return false
    }

    /**
     Returns url to local file by fileNames

     - parameter fileName: the file name

     - returns: the URL
     */
    class func getLocalFileURL(_ fileName: String) -> URL {
        return URL(fileURLWithPath: "\(self.applicationDocumentsDirectory().path)/\(contentDirectory)/\(fileName)")
    }
    
    class func getLocalFile(_ fileName: String) -> String {
        return "\(self.applicationDocumentsDirectory().path)/\(contentDirectory)/\(fileName)"
    }

    /**
     Returns url to Documents directory of the current app

     - returns: the URL
     */
    class func applicationDocumentsDirectory() -> URL {
        return URL(string: applicationDocumentsDirectory()!)!
    }

    /**
     Returns url to Documents directory of the current app as a string

     - returns: the URL
     */
    class func applicationDocumentsDirectory() -> String? {
        let paths: [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                                  FileManager.SearchPathDomainMask.userDomainMask, true)
        return paths.first
    }

    /**
     Creates directory is not exists

     - parameter subdirectoryPath: the subdirectoty name

     - returns: true - if created successfully or exists, false - else
     */
    class func createSubDirectory(_ subdirectoryPath: String) -> Bool {
        var isDir: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: subdirectoryPath as String, isDirectory:&isDir)
        if exists {
            // a file of the same name exists, we don't care about this so won't do anything
            if isDir.boolValue {
                // subdirectory already exists, don't create it again
                return true
            }
        }
        do {
            try FileManager.default.createDirectory(atPath: subdirectoryPath,
                                                    withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            print("ERROR: \(error)")
        }
        return false
    }

    /**
     Get data from given file

     - parameter fileName: the file name

     - returns: data
     */
    static func contentOfFile(url: URL) -> Data? {
        if FileManager.default.fileExists(atPath: url.path) {
            return try? Data(contentsOf: Foundation.URL(fileURLWithPath: url.path))
        }
        return nil
    }
}
