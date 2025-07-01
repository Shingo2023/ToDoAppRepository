//
//  TodoListViewController.swift
//  todo
//
//  Created by 高橋真悟 on 2025/03/31.
//

//import UIKit すると、Foundation に含まれるクラスも自動で使えるようになります
import UIKit

class TodoListViewController: UIViewController {
    
    @IBOutlet weak var redCategoryView: UIView!
    @IBOutlet weak var redCategoryTaskCount: UILabel!
    
    @IBOutlet weak var greenCategoryView: UIView!
    @IBOutlet weak var greenCategoryTaskCount: UILabel!
    
    @IBOutlet weak var blueCategoryView: UIView!
    @IBOutlet weak var blueCategoryTaskCount: UILabel!
    
    @IBOutlet weak var orangeCategoryView: UIView!
    @IBOutlet weak var orangeCategoryTaskCount: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addTaskButton: UIButton!
    
    var todoList: TodoList = TodoList(items: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        redCategoryTaskCount.layer.cornerRadius = 8
        redCategoryTaskCount.clipsToBounds = true
        
        greenCategoryTaskCount.layer.cornerRadius = 8
        greenCategoryTaskCount.clipsToBounds = true
        
        blueCategoryTaskCount.layer.cornerRadius = 8
        blueCategoryTaskCount.clipsToBounds = true
        
        orangeCategoryTaskCount.layer.cornerRadius = 8
        orangeCategoryTaskCount.clipsToBounds = true
        
        let borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
        tableView.layer.borderWidth = 1.0
        tableView.layer.borderColor = borderColor
        tableView.layer.cornerRadius = 5.0
        tableView.clipsToBounds = true
        
        addTaskButton.layer.cornerRadius = addTaskButton.frame.height / 2
        addTaskButton.clipsToBounds = true
        
        
        setupCategoryTapGesture(for: redCategoryView, selector: #selector(handleRedCategoryTap))
        setupCategoryTapGesture(for: greenCategoryView, selector: #selector(handleGreenCategoryTap))
        setupCategoryTapGesture(for: blueCategoryView, selector: #selector(handleBlueCategoryTap))
        setupCategoryTapGesture(for: orangeCategoryView, selector: #selector(handleOrangeCategoryTap))
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(handleTaskAdded), name: Notification.Name("TaskAdded"), object: nil)
        
        loadSavedData()
        updateCategoryCountLabels()
        
    }

    
    @IBAction func showAddTask(_ sender: UIButton) {
        // 定数ストーリーボードの型は　UIStoryboard（型）　Storyboard型とは画面を生成する、画面の中から特定のViewControllerを取り出すなど”Storyboardファイルを操作するクラス”である
        // UIStoryboard(name:bundle:) 呼びだすストーリーボードを指定　指定イニシャライザ（初期化メソッド）なので決められた形式で記述。引数は省略できず、明示する必要がある
        // bundle バンドル　アプリの画像・音声・Storyboard・設定ファイルなどを一つにまとめた“まとまり”　nilが入っていると、メインバンドルから指定の "AddTask.storyboard" を探して使って　となる
        let storyboard: UIStoryboard = UIStoryboard(name: "AddTask", bundle: nil)
        // 定数addTaskViewController に右辺を代入 インスタンス化したUIStoryboardクラスの　instantiateViewController　インスタンシエイトビューコントローラー　メソッドを使用
        // instantiateViewController 実体化したいViewをstoryboardファイルから生成（インスタンス化）するメソッド　＊戻り値にUIViewController型を持っているメソッドである（Apple公式定義）
        // withIdentifier: 実体化したいStoryboard上の識別子（StoryboardID）を指定
        // as! AddTaskViewController: (戻り値である)UIViewController型から遷移先のAddTaskViewController型(storyboardのカスタムクラス欄と同じものを記載。)に強制キャスト
        let addTaskViewController = storyboard.instantiateViewController(withIdentifier: "AddTaskViewController") as! AddTaskViewController
        // self 自分が今いるところ（AddTaskViewController や HomeViewController）
        // navigationController 経由で present を呼ぶことで、ナビゲーション全体の上から表示する形になる
        // present(遷移先のstoryboardID, animated: true)　指定した画面をモーダルで表示する
        self.present(addTaskViewController, animated: true)
        print("新規タスク追加ボタンを押しました")
    }
    // deinit は「この画面（ViewController）がメモリから消えるとき」に自動で呼ばれる特別なメソッドです。
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("TaskAdded"), object: nil)
    }
    
    var todoItems: [TodoItem] {
        return todoList.items
    }
    
    func addItem(title: String, message: String, category: String) {
        let newItem = TodoItem(category: category, title: title, message: message, completed: false)
        todoList.items.append(newItem)
        save()
    }
    
    func removeItem(at index: Int) {
        todoList.items.remove(at: index)
        save()
    }
    
    @objc func handleTaskAdded() {
        loadSavedData()
        tableView.reloadData()
        updateCategoryCountLabels()
    }
    
    func save() {
        let defaults = UserDefaults.standard
        if let encodedList = try? JSONEncoder().encode(todoList) {
            defaults.setValue(encodedList, forKey: "TodoList")
        }
    }
    func loadSavedData() {
        let defaults = UserDefaults.standard
        
        if let savedData = defaults.data(forKey: "TodoList") {
            print("✅ 保存データあり")
            if let savedList = try? JSONDecoder().decode(TodoList.self, from: savedData) {
                print("✅ デコード成功: \(savedList.items.count) 件")
                todoList = savedList
            } else {
                print("❌ デコード失敗（形式不一致の可能性）")
                todoList = TodoList(items: [])
            }
        } else {
            print("ℹ️ 保存データなし（初回起動など）")
            todoList = TodoList(items: [])
        }
        
    }
    
    func updateCategoryCountLabels() {
        let redCount = todoItems.filter { $0.category == "緊急&重要" }.count
        let greenCount = todoItems.filter { $0.category == "重要" }.count
        let blueCount = todoItems.filter { $0.category == "不要" }.count
        let orangeCount = todoItems.filter { $0.category == "緊急" }.count
        
        redCategoryTaskCount.text = "\(redCount)件"
        greenCategoryTaskCount.text = "\(greenCount)件"
        blueCategoryTaskCount.text = "\(blueCount)件"
        orangeCategoryTaskCount.text = "\(orangeCount)件"
    }
    
    func setupCategoryTapGesture(for view: UIView, selector: Selector) {
        let tapGesture = UITapGestureRecognizer(target: self, action: selector)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
    }

    @objc func handleRedCategoryTap() {
        showCategoryTaskList(for: "緊急&重要")
    }

    @objc func handleGreenCategoryTap() {
        showCategoryTaskList(for: "重要")
    }

    @objc func handleBlueCategoryTap() {
        showCategoryTaskList(for: "不要")
    }

    @objc func handleOrangeCategoryTap() {
        showCategoryTaskList(for: "緊急")
    }
    
    func showCategoryTaskList(for category: String) {
        let storyboard = UIStoryboard(name: "CategoryTaskListViewController", bundle: nil)  // ← 分けた.storyboard名に変更
        if let vc = storyboard.instantiateViewController(withIdentifier: "CategoryTaskList") as? CategoryTaskListViewController {
            vc.selectedCategory = category
            self.present(vc, animated: true)
        }
    }

}
// 拡張トゥドゥリストビューコントローラー　ユーアイテーブルビューデータソース
// TodoListViewController クラスを UITableViewDataSource プロトコル（UIKitに属する）に準拠させるための宣言
// これは、「TodoListViewControllerクラスに、UITableView にデータを提供する責任を持たせます」という約束（契約）を意味します。
//「私はUITableViewにデータを提供できます」「その代わり、ルール（プロトコル）に沿ってメソッドを必ず実装します」という宣言と約束です。
extension TodoListViewController: UITableViewDataSource {
    // UITableViewDataSource プロトコルに準拠すると、以下の 2つのメソッドを 必ず実装する必要があります
    //セルの個数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return = 答えを返す
        // todoListController: あなたのアプリ内で定義した ToDo 管理クラス（コントローラ）
        // todoItems: ToDoのアイテムが入っている配列（[TodoItem] など）
        // .count: 配列の中身の個数を返すプロパティ
        // 「ToDoリストのアイテム数ぶん、テーブルビューに行を表示する」という意味
        return self.todoItems.count
    }
    // セルの生成
    // テーブルビューメソッド　以降指定引数　（どのテーブルビューを対象にするか　セルローアットメソッドでセル生成　インデックスパス）指定型はUITableViewCell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 定数セル 左辺に代入　テーブルビューのデンキューセルメソッド（セルを再生するメソッド）（対象のセル）,for: どの indexPath（行・セクション）で使うか指定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath) as! TodoItemCell
        // 定数todoItem（初定義）＝　todoListControllerのtodoItems[表示するセル番号に対応する要素を取り出す]
        let todoItem = self.todoItems[indexPath.row]
        
        // ✅ ここにログを入れてください
        print("🧾 表示するアイテム: \(todoItem.title), \(todoItem.message), \(todoItem.category)")
        
        
        // cell UITableViewCell型のインスタンス（表示する1つのセル）
        // .textLabel セルにはデフォルトでtextLabel（UILabel）がついている
        // ? nilだったらときにクラッシュしないための記述
        // .text のテキストに右辺を代入
        // todoItem.title 表示したいtodoItem(セル)のタイトル
        cell.titleLabel?.text = todoItem.title
        cell.messageLabel?.text = todoItem.message
        
        cell.accessoryType = todoItem.completed ? .checkmark : .none
        return cell
    }
    // セルをスワイプで削除する
    // テーブルビューメソッド（対象のテーブルビューの指定,commit　編集スタイル editingStyleは : UITableViewCell.EditingStyle型）
    // forRowAt 引数ラベル（意味をわかりやすくするための表現）
    // indexPath: 引数の名前（内部名）。関数の中でこの名前を使う
    // IndexPath 引数の型。セクション番号と行番号を持つ構造体
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // if　エディッティング　イコール　デリート
        if editingStyle == .delete {
            //リストの削除アイテム（引数ラベル　ユーザーが操作したインデックスナンバー）
            self.removeItem(at: indexPath.row)
            // .deleteRows　デリートローズメソッド　アニメーション付きで削除する処理
            // at: [indexPath] (削除したいセルの位置（IndexPath型の配列）→ 複数行でも対応できるように「配列」で渡す必要がある)
            // with: .automatic オートマティック　削除時に使うアニメーションの種類→ .automatic はシステムに任せて最適な動きをしてくれる
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.updateCategoryCountLabels()
            
        }
        
    }
}
// デリゲートの拡張
extension TodoListViewController: UITableViewDelegate {
    //　選択時の処理
    // テーブルビューメソッド（UITableViewを指定,didSelectRow（どのセルを選択したか）　IndexPath（どのインデックスか））
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //　テーブルビューのディセレクトロウ（インデックスパス　アニメーションあり）
        tableView.deselectRow(at: indexPath, animated: true)
        // トグルメソッド　反転する　（選択するインデックス）
        //        todoListController(at: indexPath.row)
        // テーブルビューのリロード　再読み込み
        tableView.reloadData()
    }
    
}
