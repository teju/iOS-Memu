import UIKit
import RxCocoa
import RxSwift
import NSObject_Rx

// MARK: - reactive extension for NSObject
extension Reactive where Base: NSObject {
    
    /// shorthand
    var bag: DisposeBag {
        return disposeBag
    }

}

// MARK: - flatten
extension Observable where Element: Optionable {
    
    /// flattens sequence
    ///
    /// - Returns: flattened observable
    func flatten() -> Observable<Element.Wrapped> {
        return self
            .filter { valueE in
                switch valueE.value {
                case .some( _ ):
                    return true
                default:
                    return false
                }
            }
            .map { $0.value! }
        
    }
    
}
/// Optionable protocol exposes the subset of functionality required for flatten definition
protocol Optionable {
    associatedtype Wrapped
    var value: Wrapped? { get }
}

/// extension for Optional provides the implementations for Optional enum
extension Optional : Optionable {
    var value: Wrapped? { get { return self } }
}


// MARK: - shorcuts
extension Observable {
    
    /// shows loading from NOW until error/completion/<optionally> next item; assumes observing on main scheduler
    ///
    /// - Parameter view: view to insert loader into
    /// - Parameter showAlertOnError: set to false to disable showing error alert
    /// - Returns: same observable
    func showLoading(on view: UIView, showAlertOnError: Bool = true, stopOnNext: Bool = false, customErrorHandler: ((Error) -> (Bool))? = nil) -> Observable<Element> {
        let loader = LoadingView(parentView: view).show()
        return self.do(onNext: { _ in
            if stopOnNext {
                DispatchQueue.main.async {
                    loader.terminate()
                }
            }
        }, onError: { (error) in
            DispatchQueue.main.async {
                if let handler = customErrorHandler {
                    if handler(error) {
                        loader.terminate()
                        return
                    }
                }
                if showAlertOnError {
                    showAlert(NSLocalizedString("Error", comment: "Error"), message: error as? String ?? error.localizedDescription)
                }
                loader.terminate()
            }
        }, onCompleted: {
            DispatchQueue.main.async {
                loader.terminate()
            }
        })
    }
    
}

// MARK: - UIViewController extension
extension UIViewController {
    
    /// chains textfields to proceed between them one by one
    ///
    /// - Parameters:
    ///   - textFields: array of textFields
    ///   - lastReturnKey: last return key type
    ///   - lastHandler: handler for last return
    func chain(textFields: [UITextField], lastReturnKey: UIReturnKeyType = .send, lastHandler: (()->())? = nil) {
        let valueN = textFields.count
        for (valueI, valueTf) in textFields.enumerated() {
            if valueI < valueN-1 {
                valueTf.returnKeyType = .next
                valueTf.rx.controlEvent(.editingDidEndOnExit)
                    .subscribe(onNext: { _ in
                        textFields[valueI+1].becomeFirstResponder()
                    }).disposed(by: rx.bag)
            } else {
                valueTf.returnKeyType = lastReturnKey
                valueTf.rx.controlEvent(.editingDidEndOnExit)
                    .subscribe(onNext: { _ in
                        lastHandler?()
                    }).disposed(by: rx.bag)
            }
            
        }
    }
    
}

/// allow throwing strings
extension String: Error {}

class Regex {
    let internalExpression: NSRegularExpression
    let pattern: String

    init(_ pattern: String) {
        self.pattern = pattern
        self.internalExpression = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    }

    func test(_ input: String) -> Bool {
        let matches = self.internalExpression.matches(in: input, options: [],
                                                      range:NSRange(location: 0, length: input.count))
        return !matches.isEmpty
    }
}
precedencegroup RegexPrecedence {
    lowerThan: AdditionPrecedence
}

// Define operator for simplisity of Regex class
infix operator ≈: RegexPrecedence
public func ≈(input: String, pattern: String) -> Bool {
    return Regex(pattern).test(input)
}

/**
 Shows an alert with the title and message.

 - parameter title:      the title
 - parameter message:    the message
 - parameter completion: the completion callback
 */
func showAlert(_ title: String, message: String, completion: (()->())? = nil) {
    UIViewController.getCurrentViewController()?.showAlert(title, message, completion: completion)
}

/**
 Show alert with given error message

 - parameter errorMessage: the error message
 - parameter completion:   the completion callback
 */
func showError(errorMessage: String, completion: (()->())? = nil) {
    showAlert(NSLocalizedString("Error", comment: "Error alert title"), message: errorMessage, completion: completion)
}

// Stub message
let errorStub = "This feature will be implemented in future"

/// Show alert message about stub functionalify
func showStub() {
    showAlert("Stub", message: errorStub)
}

/// Delays given callback invocation
///
/// - Parameters:
///   - delay: the delay in seconds
///   - callback: the callback to invoke after 'delay' seconds
public func delay(_ delay: TimeInterval, callback: @escaping ()->()) {
    let delay = delay * Double(NSEC_PER_SEC)
    let popTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: popTime, execute: {
        callback()
    })
}

extension DispatchQueue {
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
}
