//
//  ViewController.swift
//  todo
//
//  Created by 高橋真悟 on 2025/03/31.
//

//import UIKit すると、Foundation に含まれるクラスも自動で使えるようになります
import UIKit


//中核のクラス。
class TodoListController {
    
    //構造体(TodoItem)を格納した構造体（TodoList）をコントローラクラスに定義
    var todoList: TodoList
    
    // init() イニット　初期化メソッド（イニシャライザ）
    init() {
        // 定数デフォルツ = ユーザーデフォルツスタンダード　ユーザーの設定やちょっとしたデータを保存・読み込みできます。
        let defaults = UserDefaults.standard
        // if let nilか確認し、処理を分ける { nilではなく値がある場合 } else { nilの場合 }
        // ユーザーデフォルツにセーブするデータの処理を決めようとしている（forkeyは保存・取得する際のキーワード）
        // デフォルツデータは公式ドキュメンによりDataオプショナル型である
        // if letによりアンラップされている（nilを取り除かれている）
        // let saveList... if let の第二条件。elseの手前と後を決めてから第二条件を定義したかなと。
        if let saveData = defaults.data(forKey: "TodoList"), let savedList = try?
            // saveData を JSON としてデコード（復元）しようとしています。もし成功していたらその結果をsaveLisetに代入
            // try?により失敗してもエラーを投げずnilを返す
            // saveListもオプショナルですがif letによりアンラップされます
            JSONDecoder().decode(TodoList.self, from: saveData) {
            
            todoList = savedList
        } else {
            // ユーザーデフォルツからデータを読み込んでデコードするのに失敗した場合は、空のTodoリストで初期化する
            todoList = TodoList(items: [])
        }
    }
    //構造体TODoItemを小文字で定義
    var todoItems: [TodoItem] {
        //todoListアイテムを再代入(空の配列)
        return todoList.items
    }
    // todoを追加する
    func addItem(title : String) {
        let newItem = TodoItem(title: title, completed: false)
        todoList.items.append(newItem)
        //セーブメソッドを呼び出して保存する
        save()
    }
    
    // todoを削除する
    // at　引数ラベル。前置詞のatは名詞と他の単語を柔軟に繋げて「位置」「時」「方法」補助する役目がある
    func removeItem(at index: Int) {
        //Array型のremoveメソッドで削除処理を実装
        todoList.items.remove(at: index)
        save()
    }
    
    // todoを達成flagを反転する
    //トグルコンプリーテッド　過去を切り替える
    func toggleCompleted(at index: Int) {
        //todolistのアイテムの呼び出し[インデックスで要素を指定].コンプリーテッド（完了状態のBool型を判定）.トグル（true・falseを切り替え　る）
        todoList.items[index].completed.toggle()
        save()
    }
    
    // todoリストがアプリを消してもデータを保持する
    func save() {
        // お馴染みのデータ保存機能
        let defaults = UserDefaults.standard
        // 保存処理　todoList（swiftデータ）  --エンコード-->  JSON(Data型)  --保存-->  UserDefaults（Foundation:　ファンデーションモジュールのクラス）
        // UserDefaultsに保存するデータはデータ型である必要がある。なので、JSONを使う。
        // 読み込み処理　UserDefaults --読み出し--> JSON(Data型)  --デコード--> todoList
        //　if let 保存リストを定義 = 安全なアンラップ　JSON形式に変換.エンコードは(TodoListを指定)
        if let encodelist = try? JSONEncoder().encode(todoList) {
            //セットバリューメソッド（保存する値）（定数encodelist　ユーザーデフォルツのキー）
            defaults.setValue(encodelist, forKey: "TodoList")
        }
    }
}

//
class TodoListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    //上で決めたクラスを持ってきてる
    var todoListController = TodoListController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // +ボタンの選択時の処理
    // sender センダー　「送ってきた人」→ この関数を発動させたUI部品（ボタンなど）
    // Any エニー　「どんな型でもよい」ことを意味するSwiftの型名。例：ボタンでもスイッチでもOK
    @IBAction func addTodoItem(_ sender: Any) {
        // guard let  オプショナル値が nil でないことを確認し、その後にアンラップされた値を使用できるようにします。
        // 条件式　guard let = nil else {nil処理（return）}　non-nil処理
        // 定数タイトルは　テキストフィールドのテキスト　タイトルがない時に　リターンして中断する
        //guard let title = textField.text, !title.isEmpty else { return }
        
        // 下記はguard letにより、テキストとタイトルが存在する場合の処理
        // 定数化した中核のクラスのアイテムを追加（引数タイトル）
        
        // 当クラスのIBoutletしたtableView（UItableViewクラスの）のリロードデータメソッドを呼びだす（画面が開かれるたびに最新の状態に読み込みする）
        tableView.reloadData()
        // テキストフィールドのテキストは空を初期値とする
        //textField.text = ""
        
    }
    
    // タスク追加画面を見せる意図の関数
    @IBAction func showAddTask(_ sender: UIButton) {
        // 定数ストーリーボードの型は　UIStoryboard（型）　Storyboard型とは画面を生成する、画面の中から特定のViewControllerを取り出すなど”Storyboardファイルを操作するクラス”である
        //　UIStoryboard(name:bundle:) 呼びだすストーリーボードを指定　指定イニシャライザ（初期化メソッド）なので決められた形式で記述。引数は省略できず、明示する必要がある
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
        print("ボタンを押しました")
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
        return todoListController.todoItems.count
    }
    // セルの生成
    // テーブルビューメソッド　以降指定引数　（どのテーブルビューを対象にするか　セルローアットメソッドでセル生成　インデックスパス）指定型はUITableViewCell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 定数セル 左辺に代入　テーブルビューのデンキューセルメソッド（セルを再生するメソッド）（対象のセル）,for: どの indexPath（行・セクション）で使うか指定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        // 定数todoItem（初定義）＝　todoListControllerのtodoItems[表示するセル番号に対応する要素を取り出す]　
        let todoItem = todoListController.todoItems[indexPath.row]
        // cell UITableViewCell型のインスタンス（表示する1つのセル）
        // .textLabel セルにはデフォルトでtextLabel（UILabel）がついている
        // ? nilだったらときにクラッシュしないための記述
        // .text のテキストに右辺を代入
        // todoItem.title 表示したいtodoItem(セル)のタイトル
        cell.textLabel?.text = todoItem.title
        // セル（UIテーブルビューセルのインスタンス）のアクセサリータイプ（セルの右側に何を表示させるか設定するプロパティ）
        // completed コンプリテッド 完了状態を確認できる（Bool型）
        //　? .checkmark : .none　？は三項演算子（これからコンプリテッドの真偽の詳細を宣言する）　trueのときチェックマーク　falseのときノン
        cell.accessoryType = todoItem.completed ? .checkmark : .none
        // .noneのときセルを返す　つまり、設定を終えたセルをテーブルビューに返す
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
            todoListController.removeItem(at: indexPath.row)
            // .deleteRows　デリートローズメソッド　アニメーション付きで削除する処理
            // at: [indexPath] (削除したいセルの位置（IndexPath型の配列）→ 複数行でも対応できるように「配列」で渡す必要がある)
            // with: .automatic オートマティック　削除時に使うアニメーションの種類→ .automatic はシステムに任せて最適な動きをしてくれる
            tableView.deleteRows(at: [indexPath], with: .automatic)

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
        todoListController.toggleCompleted(at: indexPath.row)
        // テーブルビューのリロード　再読み込み
        tableView.reloadData()
    }
    
}
