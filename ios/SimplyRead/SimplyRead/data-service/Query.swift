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

// This function is obsolete (due to using URLSession), replaced by login3
/*
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
*/

/*
// This function is obsolete (due to using GET), replaced by login3
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
*/

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
                    let u = User(username: "")  //indicate failed registeration
                    completion(u!)
                }
            }
        }
    }
}

func register(username: String, password: String, fullname: String, email: String, completion: @escaping (_ user: User) -> ()){
    
    var urlStr: String?
    urlStr = "http://" + SERVER_IP + ":" + PORT + "/register"
    let url = URL(string: urlStr!)
    print("Query>> register url: ")
    print(url!)
    
    let password2 = password.sha1
    print("original password: " + password + ", encrypted password: " + password2!)
    let parameters: Parameters = [
        "username": username,
        "password": password2!,
        "fullname": fullname,
        "email": email
    ]
    
    Alamofire.request(url!, method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
        print("Query>> Request: \(String(describing: response.request))")   // original url request
        print("Query>> Response: \(String(describing: response.response))") // http url response
        print("Query>> Result: \(response.result)")                         // response serialization result
        
        if let json = response.result.value {
            print("JSON: \(json)") // serialized json response
            
            if let array = json as? [Any] {
                if array.count>0 {
                    let userJson = array[0] as? [String: Any]
                    let u = User(json: userJson!)
                    completion(u!)
                }
                else{
                    print("Query>> registration fail: username exist")
                    let u = User(username: "")  //indicate failed registeration
                    completion(u!)
                }
            }
        }
    }
}

//func generateBookCopies(books: [Book]) -> [Book] {
//    print("Query>> generate book copies")
//    
//    var books2 = [Book]()
//    var count = books.count
//    for i in 0...count-1 {
//        var book = books[i]
//        for j in 0...book.num_copies!-1 {
//            var b = book
//            b.currentCopy = book.bookCopies?[j]
//            books2.append(b)
//        }
//    }
//    
//    return books2
//}


func loadBooks(bottomBookId: String? = nil, topBookId: String? = nil, owner: String? = nil, hold_by: String? = nil, isIdle: String? = nil,
               completion: @escaping (_ books: [Book]) -> ()){
 
    var parameters: [String] = []
    if bottomBookId != nil {
        parameters.append("ltid="+bottomBookId!)
    }
    if topBookId != nil {
        parameters.append("gtid="+topBookId!)
    }
    if owner != nil {
        parameters.append("owner="+owner!)
    }
	if hold_by != nil {
		parameters.append("hold_by="+hold_by!)
	}
    if isIdle != nil {
        parameters.append("isIdle="+isIdle!)
    }
    
    var urlStr = "http://" + SERVER_IP + ":" + PORT + "/books"
    if parameters.count>0 {
        urlStr += "?"
        urlStr += (parameters[0])
        
        if (parameters.count)>1 {
            for i in 1...(parameters.count)-1 {
                urlStr += "&"
                urlStr += (parameters[i])
            }
        }
    }
    
//    let urlStr = URL(string: urlStr)
    print("Query>> load books url: ")
    print(urlStr)
    
//	var url: URL?   //handle possible special charctor in tag
	if let encoded = urlStr.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let url = URL(string: encoded) {
	
		Alamofire.request(url).responseJSON { response in
	//        print("Request: \(String(describing: response.request))")   // original url request
	//        print("Response: \(String(describing: response.response))") // http url response
	//        print("Result: \(response.result)")                         // response serialization result
			
			if let json = response.result.value {
	//            print("JSON: \(json)") // serialized json response
				
							var books = [Book]()
							if let array = json as? [Any] {
								if array.count>0 {
									for i in 0...array.count-1 {
										let bookJson = array[i] as? [String: Any]
		//                                var title = bookJson?["title"]
					//                    print ("Query>> receive book json:\n " + "\(bookJson)")
					//                    guard let b = Book(title:title as! String) else {
					//                        fatalError("unable to initiate book")
					//                    }
										let b = Book(json: bookJson!)
										books.append(b!)
	//                                    if let count = b?.num_copies {
	//                                        for k in 0...count-1 {
	//                                            let bb = Book(json: bookJson!)
	//                                            bb?.currentCopy = bb?.bookCopies?[k]
	//                                            books.append(bb!)
	//                                        }
	//                                    }
					//                    print ("book loaded:\n " + "\(b?.title)")
									}
								}
								else{
									print("Query>> oops, no book is found")
								}
							}
							//now all books loaded
							print ("Query>> \(books.count)" + " books loaded, callback completion")
	//                        var books2 = generateBookCopies(books: books)
							completion(books)

			}
			
	//        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
	//            print("Data: \(utf8Text)") // original server data as UTF8 string
	//        }
		}
		//end
	}
}

func search(keyword: String? = nil, completion: @escaping (_ books: [Book]) -> ()){
    print("Query>> search start...")
    var parameters: [String] = []
    if keyword != nil {
        parameters.append("q="+keyword!)
    }
    
    var urlStr = "http://" + SERVER_IP + ":" + PORT + "/search"
    if parameters.count>0 {
        urlStr += "?"
        urlStr += (parameters[0])
        
        if (parameters.count)>1 {
            for i in 1...(parameters.count)-1 {
                urlStr += "&"
                urlStr += (parameters[i])
            }
        }
    }
    
//    let url = URL(string: urlStr)
//    var url: URL?   //handle possible special charctor in tag
    if let encoded = urlStr.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let url = URL(string: encoded) {
    
        print("Query>> search url: ")
        print(url)
        
        Alamofire.request(url).responseJSON { response in
            //        print("Request: \(String(describing: response.request))")   // original url request
            //        print("Response: \(String(describing: response.response))") // http url response
            //        print("Result: \(response.result)")                         // response serialization result
            
            if let json = response.result.value {
                //            print("JSON: \(json)") // serialized json response
                
                var books = [Book]()
                if let array = json as? [Any] {
                    if array.count>0 {
                        for i in 0...array.count-1 {
                            let bookJson = array[i] as? [String: Any]
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


// Obsolete, replaced by loadIdleBooksForUser2 and GET /books
//func loadIdleBooksForUser(username: String, completion: @escaping (_ books: [Book]) -> ()){
//    
//    var urlStr: String?
//    urlStr = "http://" + SERVER_IP + ":" + PORT + "/idleBooks?username=" + username
//    
//    if let encoded = urlStr?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let url = URL(string: encoded) {
//        print("Query>> load books by category url: ")
//        print(url)
//        
//        Alamofire.request(url).responseJSON { response in
//            print("Request: \(String(describing: response.request))")   // original url request
//            print("Response: \(String(describing: response.response))") // http url response
//            print("Result: \(response.result)")                         // response serialization result
//            
//            if let json = response.result.value {
//                print("JSON: \(json)") // serialized json response
//                
//                var books = [Book]()
//                if let array = json as? [Any] {
//                    if array.count>0 {
//                        for i in 0...array.count-1 {
//                            let bookJson = array[i] as? [String: Any]
//                            let b = Book(json: bookJson!)
//                            books.append(b!)
//                        }
//                    }
//                    else{
//                        print("Query>> oops, no book is found")
//                    }
//                }
//                //now all books loaded
//                print ("Query>> \(books.count)" + " books loaded, callback completion")
//                completion(books)
//            }
//        }
//    }
//}

/* Obsolete, replaced by loadBooks
func loadIdleBooksForUser2(username: String, completion: @escaping (_ books: [Book]) -> ()){
    
    var urlStr: String?
    urlStr = "http://" + SERVER_IP + ":" + PORT + "/books?hold_by=" + username + "&isIdle"
    
    if let encoded = urlStr?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let url = URL(string: encoded) {
        print("Query>> load idle books for user url: ")
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
                            let bookJson = array[i] as? [String: Any]
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
*/

// This function is obsolete, for testing only.
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

// User when upload books, search book details by isbnr
func searchBook(isbn: String, completion: @escaping (_ book: Book) -> ()){
    
    var urlStr: String?
    urlStr = "http://" + SERVER_IP + ":" + PORT + "/searchBook?isbn=" + isbn
    let url = URL(string: urlStr!)
    print("Query>> url")
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
                    print("Query>> no book found in database or web")
                    let b = Book(title: "")     //meaning book not found
                    completion(b!)
                }
            }
        }
    }
}

// This function is replaced by addNewBook2
//func addNewBook(title: String, author: String, isbn: String, completion: @escaping (_ book: Book) -> ()){
//    
//    print("add new book, title: " + title + ", author: " + author + ", isbn: " + isbn)
//    var urlStr: String?
//    urlStr = "http://" + SERVER_IP + ":" + PORT + "/addNewbook?title=" + title + "&author=" + author + "&isbn=" + isbn
//    let url = URL(string: urlStr!)
//    print("Query>> add new book, url")
//    print(url)
//    
//    Alamofire.request(url!).responseJSON { response in
//        print("Query>> Request: \(String(describing: response.request))")   // original url request
//        print("Query>> Response: \(String(describing: response.response))") // http url response
//        print("Query>> Result: \(response.result)")                         // response serialization result
//        
//        if let json = response.result.value {
//            print("JSON: \(json)") // serialized json response
//            //anything else
//        }
//    }
//}

// Add a new book whose information cannot be found in database or web,
// Book details are manually input by user
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

// Add book by isbn, book details can be found through isbn in database or web
func addBookByIsbn(isbn: String, title: String, category: String, owner: String, price: Int, deposit: Int, completion: @escaping (_ book: Book) -> ()){
    
    print("add new book, isbn: " + isbn + ", title: " + title)
    print("category: " + category + ", owner: " + owner)
    print("price: " + price.description + ", deposit: " + deposit.description)
    
    var urlStr: String?
    urlStr = "http://" + SERVER_IP + ":" + PORT + "/addBook"
    let url = URL(string: urlStr!)
    print("Query>> add new book, url (POST)")
    print(url)
    
    let parameters: Parameters = [
        "isbn": isbn,
        "title": title,
        "category": category,
        "owner": owner,
        "price": price,
        "deposit": deposit
    ]
    
    Alamofire.request(url!, method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
        print("Query>> Request: \(String(describing: response.request))")   // original url request
        print("Query>> Response: \(String(describing: response.response))") // http url response
        print("Query>> Result: \(response.result)")                         // response serialization result
        
        if let json = response.result.value {
            print("JSON: \(json)") // serialized json response
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
                    print("Query>> no book found in database or web")
                    let b = Book(title: "")     //meaning book not found
                    completion(b!)
                }
            }
        }
    }
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


func updateUserProfile(username: String, password: String, fullname: String, email: String, phone: String, settle_f2f_enable: String, settle_f2f_details: String, settle_sf_enable: String, settle_sf_area: String, settle_sf_sfid: String, settle_sf_address: String, completion: @escaping (_ user: User) -> ()){
    
    var urlStr: String?
    urlStr = "http://" + SERVER_IP + ":" + PORT + "/updateUserProfile"
    let url = URL(string: urlStr!)
    print("Query>> url: ")
    print(url)
    
    var password2 = password.sha1
    print("original password: " + password + ", encrypted password: " + password2!)
    let parameters: Parameters = [
        "username": username,
        "password": password2!,
        "fullname": fullname,
        "email": email,
        "phone": phone,
        "settle_f2f_enable": settle_f2f_enable,
        "settle_f2f_details": settle_f2f_details,
        "settle_sf_enable": settle_sf_enable,
        "settle_sf_area": settle_sf_area,
        "settle_sf_sfid": settle_sf_sfid,
        "settle_sf_address": settle_sf_address
    ]
    
    Alamofire.request(url!, method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
        print("Query>> Request: \(String(describing: response.request))")   // original url request
        print("Query>> Response: \(String(describing: response.response))") // http url response
        print("Query>> Result: \(response.result)")                         // response serialization result
        
        if let json = response.result.value {
            print("JSON: \(json)") // serialized json response
            
//            if let array = json as? [Any] {
//                if array.count>0 {
//                    var userJson = array[0] as? [String: Any]
//                    let u = User(json: userJson!)
//                    completion(u!)
//                }
//                else{
//                    print("Query>> oops, no user is found")
//                    let u = User(username: "")  //indicate failed registeration
//                    completion(u!)
//                }
//            }
            let u = User(username: "")  //currently server returns no user json
            completion(u!)
        }
    }
}


func queryCashTxns(username: String, completion: @escaping (_ cashTxns: [CashTxn]) -> ()){
    
    var urlStr: String?
    urlStr = "http://" + SERVER_IP + ":" + PORT + "/cashbook?username=" + username
    let url = URL(string: urlStr!)
    print("Query>> url: ")
    print(url)
    
    Alamofire.request(url!).responseJSON { response in
        print("Request: \(String(describing: response.request))")   // original url request
        print("Response: \(String(describing: response.response))") // http url response
        print("Result: \(response.result)")                         // response serialization result
        
        if let json = response.result.value {
            print("JSON: \(json)") // serialized json response
            
            var cashTxns = [CashTxn]()
            if let array = json as? [Any] {
                if array.count>0 {
                    for i in 0...array.count-1 {
                        var json = array[i] as? [String: Any]
                        let c = CashTxn(json: json!)
                        cashTxns.append(c!)
                    }
                }
                else{
                    print("Query>> oops, no cash txn is found")
                }
            }
            //now everything loaded
            print ("Query>> \(cashTxns.count)" + " cash txn loaded, callback completion")
            completion(cashTxns)
        }
    }
}

func queryBuyOrders(username: String, completion: @escaping (_ orders: [Order]) -> ()){
    
    var urlStr: String?
    urlStr = "http://" + SERVER_IP + ":" + PORT + "/orders?username=" + username
    let url = URL(string: urlStr!)
    print("Query>> url: ")
    print(url)
    
    Alamofire.request(url!).responseJSON { response in
        print("Request: \(String(describing: response.request))")   // original url request
        print("Response: \(String(describing: response.response))") // http url response
        print("Result: \(response.result)")                         // response serialization result
        
        if let json = response.result.value {
            print("JSON: \(json)") // serialized json response
            
            var orders = [Order]()
            if let array = json as? [Any] {
                if array.count>0 {
                    for i in 0...array.count-1 {
                        var json = array[i] as? [String: Any]
                        let o = Order(json: json!)
                        orders.append(o!)
                    }
                }
                else{
                    print("Query>> oops, no order is found")
                }
            }
            //now everything loaded
            print ("Query>> \(orders.count)" + " order loaded, callback completion")
            completion(orders)
        }
    }
}

func queryDeliverOrders(hold_by: String, completion: @escaping (_ orders: [Order]) -> ()){
    
    var urlStr: String?
    urlStr = "http://" + SERVER_IP + ":" + PORT + "/orders?hold_by=" + hold_by
    let url = URL(string: urlStr!)
    print("Query>> url: ")
    print(url)
    
    Alamofire.request(url!).responseJSON { response in
        print("Request: \(String(describing: response.request))")   // original url request
        print("Response: \(String(describing: response.response))") // http url response
        print("Result: \(response.result)")                         // response serialization result
        
        if let json = response.result.value {
            print("JSON: \(json)") // serialized json response
            
            var orders = [Order]()
            if let array = json as? [Any] {
                if array.count>0 {
                    for i in 0...array.count-1 {
                        var json = array[i] as? [String: Any]
                        let o = Order(json: json!)
                        orders.append(o!)
                    }
                }
                else{
                    print("Query>> oops, no order is found")
                }
            }
            //now everything loaded
            print ("Query>> \(orders.count)" + " order loaded, callback completion")
            completion(orders)
        }
    }
}

// Add a new book whose information cannot be found in database or web,
// Book details are manually input by user
func submitOrder(details: String, completion: @escaping (_ result: String) -> ()){
    print("Query>> submit order start...")
    
    var urlStr: String?
    urlStr = "http://" + SERVER_IP + ":" + PORT + "/submitOrder"
    let url = URL(string: urlStr!)
    print("Query>> url: ")
    print(url!)
    
    let parameters: Parameters = [
        "details": details
    ]
    
    Alamofire.request(url!, method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
        print("Query>> Request: \(String(describing: response.request))")   // original url request
        print("Query>> Response: \(String(describing: response.response))") // http url response
        print("Query>> Result: \(response.result)")                         // response serialization result
        
        if let json = response.result.value {
            print("JSON: \(json)") // serialized json response
            
            var result = "result"
            completion(result)
        }
    }
}



func confirmOrderDelivered(orderId: String, completion: @escaping (_ result: String) -> ()){
    print("Query>> confirmOrderDelivered start...")
    
    var urlStr: String?
    urlStr = "http://" + SERVER_IP + ":" + PORT + "/orderDelivered"
    let url = URL(string: urlStr!)
    print("Query>> url: ")
    print(url!)
    
    let parameters: Parameters = [
        "orderId": orderId
    ]
    
    Alamofire.request(url!, method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
        print("Query>> Request: \(String(describing: response.request))")   // original url request
        print("Query>> Response: \(String(describing: response.response))") // http url response
        print("Query>> Result: \(response.result)")                         // response serialization result
        
        if let json = response.result.value {
            print("JSON: \(json)") // serialized json response
            
            var result = "result"
            completion(result)
        }
    }
}

func confirmOrderReceived(orderId: String, completion: @escaping (_ result: String) -> ()){
    print("Query>> confirmOrderReceived start...")
    
    var urlStr: String?
    urlStr = "http://" + SERVER_IP + ":" + PORT + "/orderReceived"
    let url = URL(string: urlStr!)
    print("Query>> url: ")
    print(url!)
    
    let parameters: Parameters = [
        "orderId": orderId
    ]
    
    Alamofire.request(url!, method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
        print("Query>> Request: \(String(describing: response.request))")   // original url request
        print("Query>> Response: \(String(describing: response.response))") // http url response
        print("Query>> Result: \(response.result)")                         // response serialization result
        
        if let json = response.result.value {
            print("JSON: \(json)") // serialized json response
            
            var result = "result"
            completion(result)
        }
    }
}

func confirmOrderClosed(orderId: String, completion: @escaping (_ result: String) -> ()){
    print("Query>> confirmOrderClosed start...")
    
    var urlStr: String?
    urlStr = "http://" + SERVER_IP + ":" + PORT + "/orderClosed"
    let url = URL(string: urlStr!)
    print("Query>> url: ")
    print(url!)
    
    let parameters: Parameters = [
        "orderId": orderId
    ]
    
    Alamofire.request(url!, method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
        print("Query>> Request: \(String(describing: response.request))")   // original url request
        print("Query>> Response: \(String(describing: response.response))") // http url response
        print("Query>> Result: \(response.result)")                         // response serialization result
        
        if let json = response.result.value {
            print("JSON: \(json)") // serialized json response
            
            var result = "result"
            completion(result)
        }
    }
}


