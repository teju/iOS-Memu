import Foundation

// MARK: - date formatting
extension Date {
    
    /// default date formatter
    static let DefaultFormatter: DateFormatter = {
        let dateForamt = DateFormatter()
        dateForamt.dateFormat = "MM/dd/yyyy"
        return dateForamt
    }()
    
    /// medium date formatter
    static let MediumFormatter: DateFormatter = {
        let dateForamt = DateFormatter()
        dateForamt.dateFormat = "dd MMM yyyy"
        return dateForamt
    }()
    
    /// full date formatter
    static let FullFormatter: DateFormatter = {
        let dateForamt = DateFormatter()
        dateForamt.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateForamt.timeZone = TimeZone(secondsFromGMT: 0)
        return dateForamt
    }()
    
    /// default formatted string
    var defaultFormat: String {
        return Date.DefaultFormatter.string(from: self)
    }
    
    /// medium formatted string
    var mediumFormat: String {
        return Date.MediumFormatter.string(from: self)
    }
    
    /// full formatted string
    var fullFormat: String {
        return Date.FullFormatter.string(from: self)
    }
    
}
