//
//  CellDebugViewController.swift
//  todo
//
//  Created by 高橋真悟 on 2025/06/23.
//

import UIKit

class CellDebugViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    // ダミーデータ（3 件だけ）
    private let sample: [TodoItem] = [
        .init(category: "緊急&重要", title: "タイトル A", message: "メッセージ A", completed: false),
        .init(category: "重要",         title: "タイトル B タイトル B", message: "メッセージ B\n改行もテスト", completed: false),
        .init(category: "不要",        title: "長めのタイトル C C C C", message: "短", completed: false)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // ⬇️ ① TodoItemCell を Storyboard プロトタイプで作った場合
        //tableView.register(UINib(nibName: "TodoItemCell", bundle: nil),
        //                   forCellReuseIdentifier: "TodoItemCell")

        // ⬇️ ② Main.storyboard の Prototype Cell をそのまま使う場合は登録不要
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.dataSource = self
        tableView.delegate   = self
    }
}

extension CellDebugViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int { sample.count }
    func tableView(_ tv: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "TodoItemCell",
                                          for: indexPath) as! TodoItemCell
        let item = sample[indexPath.row]
        cell.titleLabel.text   = item.title
        cell.messageLabel.text = item.message
        return cell
    }
}

