//
//  String+Extension.swift
//  Memu
//
//  Created by Akash Arun Jambhulkar (Digital) on 5/1/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import Foundation

extension String {

    /// the length of the string
    var length: Int {
        return self.count
    }

    /// Get string without spaces at the end and at the start.
    ///
    /// - Returns: trimmed string
    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }

    /**
     Checks if string contains given substring

     - parameter substring:     the search string
     - parameter caseSensitive: flag: true - search is case sensitive, false - else

     - returns: true - if the string contains given substring, false - else
     */
    func contains(_ substring: String, caseSensitive: Bool = true) -> Bool {
        if let _ = self.range(of: substring,
                              options: caseSensitive ? NSString.CompareOptions(rawValue: 0) : .caseInsensitive) {
            return true
        }
        return false
    }

    /// Checks if string contains given substring
    ///
    /// - Parameter find: the search string
    /// - Returns: true - if the string contains given substring, false - else
    func contains(_ find: String) -> Bool {
        if let _ = self.range(of: find) {
            return true
        }
        return false
    }

    /// Shortcut method for replacingOccurrences
    ///
    /// - Parameters:
    ///   - target: the string to replace
    ///   - withString: the string to add instead of target
    /// - Returns: a result of the replacement
    public func replace(_ target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString,
                                         options: NSString.CompareOptions.literal, range: nil)
    }

    /// Checks if the string is number
    ///
    /// - Returns: true if the string presents number
    func isNumber() -> Bool {
        let formatter = NumberFormatter()
        if let _ = formatter.number(from: self) {
            return true
        }
        return false
    }

    /// Checks if the string is positive number
    ///
    /// - Returns: true if the string presents positive number
    func isPositiveNumber() -> Bool {
        let formatter = NumberFormatter()
        if let number = formatter.number(from: self) {
            if number.doubleValue > 0 {
                return true
            }
        }
        return false
    }

    /// Get URL encoded string
    ///
    /// - Returns: URL encoded string
    public func urlEncodedString() -> String {
        var set = CharacterSet.urlQueryAllowed
        set.remove(charactersIn: ":?&=@+/'")
        return self.addingPercentEncoding(withAllowedCharacters: set) ?? self
    }

    /// Split string with given character
    ///
    /// - Parameter separator: the separator
    /// - Returns: the array of strings
    func split(_ separator: Character) -> [String] {
        return self.split(separator: separator).map({String($0)})
    }

    /// Get substring, e.g. "ABCDE".substring(index: 2, length: 3) -> "CDE"
    ///
    /// - parameter index:  the start index
    /// - parameter length: the length of the substring
    ///
    /// - returns: the substring
    public func substring(index: Int, length: Int) -> String {
        if self.length <= index {
            return ""
        }
        let leftIndex = self.index(self.startIndex, offsetBy: index)
        if self.length <= index + length {
            return String(self[leftIndex..<self.endIndex])
        }
        let rightIndex = self.index(self.endIndex, offsetBy: -(self.length - index - length))
        return String(self[leftIndex..<rightIndex])
    }

    /// Get email domain
    ///
    /// - Returns: domain of the email (without ending, e.g. `.com`) or nil
    public func getEmailDomain() -> String? {
        let pattern = "^[A-Z0-9a-z._%+-]+@([A-Za-z0-9.-]+)\\.[A-Za-z]{2,4}$"
        var emailDomain: String?
        if let expression = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            let matches = expression.matches(in: self, options: [], range:NSRange(location: 0, length: self.count))
            _ = matches.map { result -> String in
                let domainRange = result.range(at: 1)
                let domain = String(self.substring(index: domainRange.location, length: domainRange.length))
                emailDomain = domain
                return domain
            }
        }
        return emailDomain
    }

    /// Abbreviation
    var abbreviation: String {
        let abbreviationStr = self.split(" ")
        return abbreviationStr.map({String($0.first!)}).joined()
    }
    
    var htmlToAttributedString: NSMutableAttributedString? {
        guard let data = data(using: .utf8) else { return NSMutableAttributedString() }
        do {
            return try NSMutableAttributedString(data: data, options: [.documentType: NSMutableAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSMutableAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyz0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
