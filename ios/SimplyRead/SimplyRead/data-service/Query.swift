//
//  Query.swift
//  SimplyRead
//
//  Created by jim on 31/8/2017.
//
//

//let SERVER_IP = "localhost"       //local
let SERVER_IP = "52.221.212.21"     //AWS
let PORT = "3001"

import Foundation
import Alamofire

func login(username: String, password: String, completion: @escaping (_ user: User) -> ()){
    print("Query>> login username: " + username + ", password: " + password)
    let queryStr = "?username="+username+"&password="+password
    print("Query>> query string: " + queryStr)
    
    let url = URL(string: "http://" + SERVER_IP + ":" + PORT + "/user" + queryStr)
    print("Query>> url:")
    print(url)
    
    var request = URLRequest(url: url!)
    request.httpMethod = "GET"
    request.httpBody = queryStr.data(using: .utf8)
    
    request.timeoutInterval = 10.0  // this is somehow magic!
    
    let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
        print("Query>> login response:")
//        print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
        
        //parse data
        if let data = data,
        let json = try? JSONSerialization.jsonObject(with: data, options: [])  {
            if let array = json as? [Any] {
                if array.count>0 {
                    var userJson = array[0] as? [String: Any]
//                    print("Query>> userJson: ")
//                    print(userJson)
                    let u = User(json: userJson!)
                    completion(u!)
                }
                else{
                    print("Query>> no user found")
                }
            }
        }
    }
    task.resume()
}


func loadBooks(completion: @escaping (_ books: [Book]) -> ()){
    
    let url = URL(string: "http://" + SERVER_IP + ":" + PORT + "/books")

//    print("Query>> login username: " + "jim" + ", password: " + "123456")
//    let queryStr = "?username="+"jim"+"&password="+"123456"
//    print("Query>> query string: " + queryStr)
//    let url = URL(string: "http://" + SERVER_IP + ":" + PORT + "/books" + queryStr)

    print("Query:>> url: ")
    print(url)
    
//    var request = URLRequest(url: url!)
//    request.httpMethod = "GET"
//    request.httpBody = queryStr.data(using: .utf8)

//    request.timeoutInterval = 200.0  // this is somehow magic!
    
    //test Alamofire
    Alamofire.request(url!).responseJSON { response in
//        print("Request: \(String(describing: response.request))")   // original url request
//        print("Response: \(String(describing: response.response))") // http url response
//        print("Result: \(response.result)")                         // response serialization result
        
        if let json = response.result.value {
//            print("JSON: \(json)") // serialized json response
            
                        var books = [Book]()
                        if let array = json as? [Any] {
                            if array.count>0 {
                                for i in 0...array.count-1 {
                                    var bookJson = array[i] as? [String: Any]
    //                                var title = bookJson?["title"]
                //                    print ("Query>> receive book json:\n " + "\(bookJson)")
                //                    guard let b = Book(title:title as! String) else {
                //                        fatalError("unable to initiate book")
                //                    }
                                    let b = Book(json: bookJson!)
                                    books.append(b!)
                //                    print ("book loaded:\n " + "\(b?.title)")
                                }
                            }
                            else{
                                print("Query>> oops, no book is found")
                            }
                        }
                        //now all books loaded
                        print ("Query>> \(books.count)" + " books loaded, callback completion")
                        completion(books)

        }
        
//        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
//            print("Data: \(utf8Text)") // original server data as UTF8 string
//        }
    }
    //end

//    let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
//        print("Query>> response from loadBooks")
////      print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
//        //parse data
//        if let data = data,
//            let json = try? JSONSerialization.jsonObject(with: data, options: [])  {
//            var books = [Book]()
//            if let array = json as? [Any] {
//                for i in 0...array.count-1 {
//                    var bookJson = array[i] as? [String: Any]
//                    var title = bookJson?["title"]
////                    print ("Query>> receive book json:\n " + "\(bookJson)")
////                    guard let b = Book(title:title as! String) else {
////                        fatalError("unable to initiate book")
////                    }
//                    let b = Book(json: bookJson!)
//                    books.append(b!)
////                    print ("book loaded:\n " + "\(b?.title)")
//                }
//            }
//            //now all books loaded
//            print ("Query>> \(books.count)" + " books loaded, callback completion")
//            completion(books)
//        }
//    }
//    task.resume()
}


func searchAddBook(isbn: String, completion: @escaping (_ book: Book) -> ()){
    
    let url = URL(string: "http://" + SERVER_IP + ":" + PORT + "/searchAddbook?isbn=" + isbn)
    print("Query>> load book, url")
    print(url)
    
    Alamofire.request(url!).responseJSON { response in
                print("Query>> Request: \(String(describing: response.request))")   // original url request
                print("Query>> Response: \(String(describing: response.response))") // http url response
                print("Query>> Result: \(response.result)")                         // response serialization result
        
        if let json = response.result.value {
//            print("JSON: \(json)") // serialized json response
            
            var books = [Book]()
            if let array = json as? [Any] {
                if array.count>0 {
                    print("Query>> book found in database, return book details")
                    var bookJson = array[0] as? [String: Any]
//                    print("Query>> bookJson: ")
//                    print(bookJson)
                    let b = Book(json: bookJson!)
                    completion(b!)
                }
                else{
                    print("Query>> no book found in database, add new book via Douban request")
                    let b = Book(title: "")     //meaning book not found
                    completion(b!)
                }
            }
        }
    }
}

func addNewBook(title: String, author: String, isbn: String, completion: @escaping (_ book: Book) -> ()){
    
    let url = URL(string: "http://" + SERVER_IP + ":" + PORT + "/addNewbook?title=" + title + "&author=" + author + "&isbn=" + isbn)
    print("Query>> add new book, url")
    print(url)
    
    Alamofire.request(url!).responseJSON { response in
        print("Query>> Request: \(String(describing: response.request))")   // original url request
        print("Query>> Response: \(String(describing: response.response))") // http url response
        print("Query>> Result: \(response.result)")                         // response serialization result
        
        if let json = response.result.value {
            print("JSON: \(json)") // serialized json response
            //anything else
        }
    }
}

func addNewBookImage(isbn: String, image: UIImage, completion: @escaping (_ book: Book) -> ()){
    
    let url = URL(string: "http://" + SERVER_IP + ":" + PORT + "/upload")
    print("Query>> add new book image, url")
    print(url)
    
    let imageData = UIImageJPEGRepresentation(image, 0.8)
    let fileName = isbn + ".jpeg"
    
    Alamofire.upload(
        multipartFormData: { multipartFormData in
            multipartFormData.append(imageData!, withName: "image", fileName: fileName, mimeType: "image/jpeg")},
        to: url!,
        encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    debugPrint(response)
                }
            case .failure(let encodingError):
                print(encodingError)
            }
    }
    )
}


func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
//    print ("Query>> get data from url: " + "\(url)")
    URLSession.shared.dataTask(with: url) {
        (data, response, error) in
        completion(data, response, error)
        }.resume()
}


