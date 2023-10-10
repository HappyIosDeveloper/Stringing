# Stringing
It's a Swift helper to convert structs to strings and vice versa (mostly to use in URLs and Deep Links)

## The Manual Method

0- Add the Stringing protocol and StringingHelper class to your project.

1- Confirm your Struct to Stringing protocol.

2- Implement the functions like the image below.

3- Now you can convert all parameters to String.

4- Also you can parse all those parameters from Sting URL.



![preview1](https://github.com/HappyIosDeveloper/Stringing/blob/main/Preview1.png?raw=true)

![preview2](https://github.com/HappyIosDeveloper/Stringing/blob/main/Preview2.png?raw=true)



## The Automated Method

Use the bottom code:

```
struct MyObject: Codable {
    var number: Int
    var title: String
    var arrayString: [String]
}
let myObject = MyObject(number: 2, title: "hello", arrayString: ["item 1", "item 2"])
let data = try JSONEncoder().encode(myObject)
let stringData = data.base64EncodedString()
print("stringData:", stringData)
let validURL = URL(string: "https://google.com/" + stringData)
print("validURL:", validURL?.absoluteString ?? "")

if let newStringData = validURL?.path.dropFirst().data(using: .utf8) {
    let newData = Data(base64Encoded: newStringData)!
    do {
        let newObject = try JSONDecoder().decode(MyObject.self, from: newData)
        print("new parsed object:", newObject)
    } catch {
        print("shit!", error)
    }
} else {
    print("Oops")
}
```
