//
//  CategoryTaskListViewController.swift
//  todo
//
//  Created by 高橋真悟 on 2025/06/20.
//
import UIKit

class CategoryTaskListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var selectedCategory: String = ""
    var filteredItems: [TodoItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadFilteredData()
    }

    func loadFilteredData() {
        let defaults = UserDefaults.standard
        if let savedData = defaults.data(forKey: "TodoList"),
           let savedList = try? JSONDecoder().decode(TodoList.self, from: savedData) {
            self.filteredItems = savedList.items.filter { $0.category == selectedCategory }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let item = filteredItems[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.message
        return cell
    }
}
