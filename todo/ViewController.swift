//
//  ViewController.swift
//  todo
//
//  Created by 高橋真悟 on 2025/03/31.
//

import UIKit

struct TodoItem: Codable {
    var title: String
    var completed: Bool
}

struct TodoList: Codable {
    var items: [TodoItem]
}
//中核のクラス。
class TodoListController {
    
    var todoList: TodoList
    
    init() {
        let defaults = UserDefaults.standard
        if let saveData = defaults.data(forKey: "TodoList"), let savedList = try?
            JSONDecoder().decode(TodoList.self, from: saveData) {
            todoList = savedList
        } else {
            todoList = TodoList(items: [])
        }
    }
    var todoItems: [TodoItem] {
        return todoList.items
    }
    // todoを追加する
    func addItem(title : String) {
        let newItem = TodoItem(title: title, completed: false)
        todoList.items.append(newItem)
        save()
    }
    
    // todoを削除する
    func removeItem(at index: Int) {
        todoList.items.remove(at: index)
        save()
    }
    
    // todoを達成flagを反転する
    func toggleCompleted(at index: Int) {
        todoList.items[index].completed.toggle()
        save()
    }
    
    // todoリストがアプリを消してもデータを保持する
    func save() {
        let defaults = UserDefaults.standard
        if let encodelist = try? JSONEncoder().encode(todoList) {
            defaults.setValue(encodelist, forKey: "TodoList")
        }
    }
}


class TodoListViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var todoListController = TodoListController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // +ボタンの選択時の処理
    @IBAction func addTodoItem(_ sender: Any) {
        guard let title = textField.text, !title.isEmpty else { return }
        todoListController.addItem(title: title)
        tableView.reloadData()
        textField.text = ""
    }
    
}

extension TodoListViewController: UITableViewDataSource {
    //セルの個数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoListController.todoItems.count
    }
    //セルの生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let todoItem = todoListController.todoItems[indexPath.row]
        cell.textLabel?.text = todoItem.title
        cell.accessoryType = todoItem.completed ? .checkmark : .none
        return cell
    }
    //セルをスワイプで削除する
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            todoListController.removeItem(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)

        }
        
    }
}

extension TodoListViewController: UITableViewDelegate {
    //選択時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        todoListController.toggleCompleted(at: indexPath.row)
        tableView.reloadData()
    }
    
}
