//
//  ChildViewController.swift
//  TabBarDemo
//
//  Created by Ahmed M. Hassan on 1/28/20.
//  Copyright © 2020 Ahmed M. Hassan. All rights reserved.
//

import UIKit

class ChildViewController: UITableViewController {

    private var list = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        for i in 0..<25 {
            list.append("Hello \(i)")
        }
        
        tableView.reloadData()
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! UITableViewCell
        cell.textLabel?.text = list[indexPath.row]
        return cell
    }
}
