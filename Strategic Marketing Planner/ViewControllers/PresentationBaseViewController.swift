//
//  PresentationBaseViewController.swift
//  Strategic Marketing Planner
//
//  Created by Christopher Thiebaut on 3/26/18.
//  Copyright © 2018 Christopher Thiebaut. All rights reserved.
//

import UIKit

class PresentationBaseViewController: UIViewController, NavigationTableViewControllerDelegate {

    @IBOutlet weak var mainContentView: UIView!
    var destinations: [(destinationName: String, destinationViewController: UIViewController)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        if segue.identifier == "toEmbeddedNavigationVC" {
            guard let navigationTVC = segue.destination as? NavigationTableViewController else {return}
            navigationTVC.delegate = self
            var destinationNames: [String] = []
            for destination in destinations {
                destinationNames.append(destination.destinationName)
            }
            navigationTVC.destinations = destinationNames
        }
    }
    
    func selectedDestinationAtIndex(_ index: Int) {
        let destination = destinations[index].destinationViewController
        addChildViewController(destination)
        for subview in mainContentView.subviews {
            subview.removeFromSuperview()
        }
        mainContentView.addSubview(destination.view)
        destination.view.frame = mainContentView.bounds
        destination.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

}
