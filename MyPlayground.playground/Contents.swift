import Foundation

let test = Test(name: "some string", time: 4, array: ["blah blah 1", "blah blah 2"])
print("Initial Struct", test)
let url = URL(string: test.string.description)!
let params = url.getParams()
print("parsed response:", params)
print("parsed time type:", test.getType(for: "time", in: params))
print("parsed time:", test.getInt(for: "time", in: params) ?? "?")

struct Test: Stringing {
    
    var name: String
    var time: Int
    var array: [String]

    var queryItems: [URLQueryItem] {
        return allVariablesToQueryItems(model: self)
    }
    
    var string: String {
        return string(components: queryItems)
    }
}

/// MARK: This protocol is a dependency inversion for using stringing functionalities
enum VariableType { case int, double, bool, string, stringArray }
protocol Stringing {
    var queryItems: [URLQueryItem] { get }
    var string: String { get }
    func allVariablesToQueryItems(model: Any)-> [URLQueryItem]
}

extension Stringing {
    
    func string(components: [URLQueryItem]?)-> String {
        var comp = URLComponents()
        comp.scheme = "https"
        comp.queryItems = components
        return (comp.url?.absoluteString ?? "?")
    }
    
    func queryItems(params: [String: String])-> [URLQueryItem] {
        var items = [URLQueryItem]()
        for (key, value) in params {
            items.append(URLQueryItem(name: key, value: value))
        }
        return items
    }
    
    func getType(for key: String, in params: [String : String])-> VariableType {
        guard let value = params[key] else { return .string }
        if let _ = Int(value) {
            return .int
        } else if let _ = Double(value) {
            return .double
        } else if let _ = Bool(value) {
            return .bool
        } else if !value.components(separatedBy: ",").isEmpty {
            return .stringArray
        } else {
            return .string
        }
    }
    
    func getInt(for value: String, in params: [String : String])-> Int? {
        if let val = params[value], let num = Int(val) {
            return num
        }
        return nil
    }
    
    func allVariablesToQueryItems(model: Any)-> [URLQueryItem] {
        var items: [URLQueryItem] = []
        let mirror = Mirror(reflecting: model)
        for child in mirror.children {
            items.append(URLQueryItem(name: child.label ?? "?", value: childConvertor(for: child)))
        }
        return items
    }
    
    /// MARK: If you need a dictionary output
    func convertToDic(model: Any)-> [String: String] {
        var items: [String: String] = [:]
        let mirror = Mirror(reflecting: model)
        for child in mirror.children {
            items[(child.label ?? "unknown")] = childConvertor(for: child)
        }
        return items
    }
    
    /// MARK: Add any new type you want to handle here
    private func childConvertor(for child: Mirror.Child)-> String {
        /// First checks if child is an object itself
        if let childObject = child.value as? Stringing {
            return childObject.string.replacingOccurrences(of: "https:?", with: "")
        } else {
            return child.value as? String ??
            (child.value as? Int)?.description ??
            (child.value as? [String])?.joined(separator: ",") ??
            "??"
        }
    }
}

extension URL {
    
    func getParams()-> [String: String] {
        var dic: [String: String] = [:]
        if let urlComponents = components {
            let params = (urlComponents.queryItems ?? [])
            for item in params {
                if let val = item.value {
                    if val.filter({$0 == "="}).count > 1 { // value is an object
                        dic[item.name] = val.replacingOccurrences(of: "&", with: ",")
                    } else {
                        dic[item.name] = val
                    }
                }
            }
        }
        return dic
    }
    
    var components: URLComponents? {
        return URLComponents(url: self, resolvingAgainstBaseURL: false)
    }
}
