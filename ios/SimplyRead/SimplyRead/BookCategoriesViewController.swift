//
//  BookCategoriesViewController.swift
//  SimplyRead
//
//  Created by jim on 22/9/2017.
//
//

import UIKit

class BookCategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tagsView1: UIStackView!
    @IBOutlet weak var tagsView2: UIStackView!
    
    var tagClicked: String?
    
    var categories = [Category]()
    @IBOutlet var tableView: UITableView!
    let cellReuseIdentifier = "cell"
    let cellIdentifier = "CategoryTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("BookCategoriesViewControler>> start query hot tags")
        queryHotTags(n: NUM_HOT_TAGS, completion: {(tags: [Tag]) -> () in
            print("BookCategoriesViewControler>> callback from tags")
            var count = 0;
            for tag in tags {
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 21))
                button.setTitle("#" + tag.name, for: .normal)
                button.setTitleColor(.orange, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize:13)
                button.addTarget(self, action: #selector(self.clickTag), for: .touchUpInside)
                
                if count<5 {
                    self.tagsView1.addArrangedSubview(button)
                } else {
                    self.tagsView2.addArrangedSubview(button)
                }
                count += 1
            }
        })
        
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self

        print("BookCategoriesViewControler>> start query categories")
        queryCategories(completion: {(categories: [Category]) -> () in
            print("BookCategoriesViewControler>> callback from categories")
            self.categories = categories
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        })

    }
    
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CategoryTableViewCell else {
            fatalError("the dequeued cell is not an instance of CategoryTableViewCell")
        }
        
        let category = categories[indexPath.row]
        
        // set name
        var textStr = String()
        textStr = category.name + " (" + (category.num_books?.description)! + ")"
        cell.nameLabel.text = textStr
        
        return cell
    }
    
    func clickTag(sender: UIButton!) {
        print("BookCategoriesViewController>> tag tapped")
        var tag = sender.titleLabel?.text
        tag?.remove(at: (tag?.startIndex)!)
        print("tag: \(String(describing: tag))")
        
        self.tagClicked = tag
        self.performSegue(withIdentifier: "booksForTag", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let booksForTagViewController = segue.destination as? BooksForTagViewController {
            print("BookCategoriesVC>> dest: books for tag")
            booksForTagViewController.tag = tagClicked
        }

        if let booksForCategoryViewController = segue.destination as? BooksForCategoryViewController {
            print("BookCategoriesVC>> dest: books for category")
            let selectedCategoryCell = sender as? CategoryTableViewCell
            let indexPath = tableView.indexPath(for: selectedCategoryCell!)
            let selectedCategory = categories[(indexPath?.row)!]
            booksForCategoryViewController.category = selectedCategory.name
        }
    }
    

}
