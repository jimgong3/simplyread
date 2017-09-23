//
//  BookCategoriesViewController.swift
//  SimplyRead
//
//  Created by jim on 22/9/2017.
//
//

import UIKit

class BookCategoriesViewController: UIViewController {

    @IBOutlet weak var tagsView1: UIStackView!
    @IBOutlet weak var tagsView2: UIStackView!
    
    var tagClicked: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("BookCategoriesViewControler>> start query hot tags")
        queryHotTags(n: NUM_HOT_TAGS, completion: {(tags: [Tag]) -> () in
            print("BookCategoriesViewControler>> callback")
            var count = 0;
            for tag in tags {
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 21))
                button.setTitle("#" + tag.name, for: .normal)
                button.setTitleColor(.blue, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize:13)
                button.addTarget(self, action: #selector(self.clickTag), for: .touchUpInside)

//                label.addTarget(self, action: #selector(BookCategoriesViewController.pressed(_:)), forControlEvents: .TouchUpInside)
                
                if count<5 {
                    self.tagsView1.addArrangedSubview(button)
                } else {
                    self.tagsView2.addArrangedSubview(button)
                }
                count += 1
            }
        })
    }
    
    func clickTag(sender: UIButton!) {
        print("BookCategoriesViewController>> tag tapped")
        var tag = sender.titleLabel?.text
        tag?.remove(at: (tag?.startIndex)!)
        print("tag: \(tag)")
        
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
    }
    

}
