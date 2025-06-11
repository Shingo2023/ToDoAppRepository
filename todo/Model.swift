//
//  Model.swift
//  todo
//
//  Created by 高橋真悟 on 2025/06/09.
//
import UIKit
// データ保存機能
// 構造体TodoItemを作成
// Codable コーダブル 　　変換（エンコードencode）と復元（デコードdecode）できる
struct TodoItem: Codable {
    var title: String
    var completed: Bool
}
// 構造体TodoListに変換と復元機能。先ほど定義した構造体TodoItemを格納。
struct TodoList: Codable {
    var items: [TodoItem]
}

let todoKey = "TodoList"
