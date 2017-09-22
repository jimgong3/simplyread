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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("BookCategoriesViewControler>> start query hot tags")
        queryHotTags(n: NUM_HOT_TAGS, completion: {(tags: [Tag]) -> () in
            print("BookCategoriesViewControler>> callback")
            var count = 0;
            for tag in tags {
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 21))
                label.textAlignment = .left
                label.text = "#" + tag.name
                label.textColor = UIColor.darkGray
                label.font = label.font.withSize(12)
                
                if count<5 {
                    self.tagsView1.addArrangedSubview(label)
                } else {
                    self.tagsView2.addArrangedSubview(label)
                }
                count += 1
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
