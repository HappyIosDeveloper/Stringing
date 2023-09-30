import Foundation


let test = Test(name: "some string", time: 4, array: ["blah blah 1", "blah blah 2"])
let url = URL(string: test.string.description)!
let params = url.getParams()
print("parsed response", params)
print(test.getType(for: "time", in: params))
print(test.getInt(for: "time", in: params) ?? "?")

struct Test: Codable, Stringing {
    
    var name: String
    var time: Int
    var array: [String]
    
    var queryItems: [URLQueryItem] {
        return queryItems(params: ["name": name, "time": time.description, "array": array.joined(separator: ",")])
    }
    
    var string: String {
        return string(components: queryItems)
    }
}

extension URL {
    
    func getParams()-> [String: String] {
        var dic: [String: String] = [:]
        if let urlComponents = components {
            let params = (urlComponents.queryItems ?? [])
            for item in params {
                if let val = item.value {
                    dic[item.name] = val
                }
            }
        }
        return dic
    }
    
    var components: URLComponents? {
        return URLComponents(url: self, resolvingAgainstBaseURL: false)
    }
}

extension Stringing {
    
    func string(components: [URLQueryItem]?)-> String {
        var comp = URLComponents()
        comp.scheme = "https"
        comp.queryItems = components
        return comp.url?.absoluteString ?? "?"
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
            print("shit", value.components(separatedBy: ","))
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
}

/// MARK: This protocol is a dependency inversion for using stringing functionalities
enum VariableType { case int, double, bool, string, stringArray }
protocol Stringing {
    var queryItems: [URLQueryItem] { get }
    var string: String { get }
}
