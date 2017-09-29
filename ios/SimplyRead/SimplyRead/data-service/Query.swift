//
//  Query.swift
//  SimplyRead
//
//  Created by jim on 31/8/2017.
//
//

import Foundation
import Alamofire
import Crypto

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
    
//    request.timeoutInterval = 10.0  // this is somehow magic!
    
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


func login2(username: String, password: String, completion: @escaping (_ user: User) -> ()){
    
    var urlStr: String?
    urlStr = "http://" + SERVER_IP + ":" + PORT + "/user?username=" + username + "&password=" + password
    let url = URL(string: urlStr!)
    print("Query>> url: ")
    print(url)
    
    Alamofire.request(url!).responseJSON { response in
        print("Request: \(String(describing: response.request))")   // original url request
        print("Response: \(String(describing: response.response))") // http url response
        print("Result: \(response.result)")                         // response serialization result
        
        if let json = response.result.value {
            print("JSON: \(json)") // serialized json response
            
            if let array = json as? [Any] {
                if array.count>0 {
                    var userJson = array[0] as? [String: Any]
                    let u = User(json: userJson!)
                    completion(u!)
                }
                else{
                    print("Query>> oops, no user is found")
                }
            }
        }
    }
}

func login3(username: String, password: String, completion: @escaping (_ user: User) -> ()){
    
    var urlStr: String?
    urlStr = "http://" + SERVER_IP + ":" + PORT + "/login"
    let url = URL(string: urlStr!)
    print("Query>> url: ")
    print(url)
    
    var password2 = password.sha1
    print("original password: " + password + ", encrypted password: " + password2!)
    let parameters: Parameters = [
        "username": username,
        "password": password2!
    ]
    
    Alamofire.request(url!, method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
        print("Query>> Request: \(String(describing: response.request))")   // original url request
        print("Query>> Response: \(String(describing: response.response))") // http url response
        print("Query>> Result: \(response.result)")                         // response serialization result

        if let json = response.result.value {
            print("JSON: \(json)") // serialized json response
            
            if let array = json as? [Any] {
                if array.count>0 {
                    var userJson = array[0] as? [String: Any]
                    let u = User(json: userJson!)
                    completion(u!)
                }
                else{
                    print("Query>> oops, no user is found")
                }
            }
        }
    }
}


func loadBooks(completion: @escaping (_ books: [Book]) -> ()){
    
    let url = URL(string: "http://" + SERVER_IP + ":" + PORT + "/books")
    print("Query>> load books url: ")
    print(url)
    
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
}

func loadBooksForTag(tag: String, completion: @escaping (_ books: [Book]) -> ()){
    
    var urlStr: String?
    urlStr = "http://" + SERVER_IP + ":" + PORT + "/queryBookByTag?tag=" + tag
    
    var url: URL?   //handle possible special charctor in tag
    if let encoded = urlStr?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let url = URL(string: encoded) {
        print("Query>> load books by tag url: ")
        print(url)
    
        Alamofire.request(url).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
                
                var books = [Book]()
                if let array = json as? [Any] {
                    if array.count>0 {
                        for i in 0...array.count-1 {
                            var bookJson = array[i] as? [String: Any]
                            let b = Book(json: bookJson!)
                            books.append(b!)
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
        }
    }
}

func loadBooksForCategory(category: String, completion: @escaping (_ books: [Book]) -> ()){
    
    var urlStr: String?
    urlStr = "http://" + SERVER_IP + ":" + PORT + "/queryBookByCategory?category=" + category
    
    var url: URL?   //handle possible special charctor in tag
    if let encoded = urlStr?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let url = URL(string: encoded) {
        print("Query>> load books by category url: ")
        print(url)
        
        Alamofire.request(url).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
                
                var books = [Book]()
                if let array = json as? [Any] {
                    if array.count>0 {
                        for i in 0...array.count-1 {
                            var bookJson = array[i] as? [String: Any]
                            let b = Book(json: bookJson!)
                            books.append(b!)
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
        }
    }
}


func searchAddBook(isbn: String, completion: @escaping (_ book: Book) -> ()){
    
    var urlStr: String?
    urlStr = "http://" + SERVER_IP + ":" + PORT + "/searchAddbook?isbn=" + isbn
    let url = URL(string: urlStr!)
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
    
    print("add new book, title: " + title + ", author: " + author + ", isbn: " + isbn)
    var urlStr: String?
    urlStr = "http://" + SERVER_IP + ":" + PORT + "/addNewbook?title=" + title + "&author=" + author + "&isbn=" + isbn
    let url = URL(string: urlStr!)
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

func addNewBook2(title: String, author: String, isbn: String, completion: @escaping (_ book: Book) -> ()){
    
    print("add new book, title: " + title + ", author: " + author + ", isbn: " + isbn)
    var urlStr: String?
    urlStr = "http://" + SERVER_IP + ":" + PORT + "/addNewbook"
    let url = URL(string: urlStr!)
    print("Query>> add new book, url (POST)")
    print(url)
    
    let parameters: Parameters = [
        "title": title,
        "author": author,
        "isbn": isbn
    ]
    
    Alamofire.request(url!, method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
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


func queryHotTags(n: Int, completion: @escaping (_ tags: [Tag]) -> ()){
    
    var urlStr: String?
    urlStr = "http://" + SERVER_IP + ":" + PORT + "/hotTags?n=" + String(n)
    let url = URL(string: urlStr!)
    print("Query>> query hot tag url: ")
    print(url)
    
    Alamofire.request(url!).responseJSON { response in
        print("Request: \(String(describing: response.request))")   // original url request
        print("Response: \(String(describing: response.response))") // http url response
        print("Result: \(response.result)")                         // response serialization result
        
        if let json = response.result.value {
            print("JSON: \(json)") // serialized json response
            
            var tags = [Tag]()
            if let array = json as? [Any] {
                if array.count>0 {
                    for i in 0...array.count-1 {
                        var tagJson = array[i] as? [String: Any]
                        let t = Tag(json: tagJson!)
                        tags.append(t!)
                    }
                }
                else{
                    print("Query>> oops, no tag is found")
                }
            }
            //now all books loaded
            print ("Query>> \(tags.count)" + " tags loaded, callback completion")
            completion(tags)
        }
    }
}

func queryCategories(completion: @escaping (_ categories: [Category]) -> ()){
    
    var urlStr: String?
    urlStr = "http://" + SERVER_IP + ":" + PORT + "/categories"
    let url = URL(string: urlStr!)
    print("Query>> url: ")
    print(url)
    
    Alamofire.request(url!).responseJSON { response in
        print("Request: \(String(describing: response.request))")   // original url request
        print("Response: \(String(describing: response.response))") // http url response
        print("Result: \(response.result)")                         // response serialization result
        
        if let json = response.result.value {
            print("JSON: \(json)") // serialized json response
            
            var categories = [Category]()
            if let array = json as? [Any] {
                if array.count>0 {
                    for i in 0...array.count-1 {
                        var catJson = array[i] as? [String: Any]
                        let c = Category(json: catJson!)
                        categories.append(c!)
                    }
                }
                else{
                    print("Query>> oops, no category is found")
                }
            }
            //now everything loaded
            print ("Query>> \(categories.count)" + " categories loaded, callback completion")
            completion(categories)
        }
    }
}



