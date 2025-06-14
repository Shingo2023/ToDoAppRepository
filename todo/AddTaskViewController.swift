//
//  AddTaskViewController.swift
//  todo
//
//  Created by 高橋真悟 on 2025/04/26.
//

import UIKit


//このファイルのメインクラス
class AddTaskViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    
    let categoryOptions = ["緊急&重要", "重要", "不要", "緊急"]
    var categoryPicker = UIPickerView()
    
    var selectedCategoryIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // プレースホルダー（薄文字）
        categoryTextField.placeholder = "カテゴリ"
        titleTextField.placeholder = "タイトル"
        messageTextView.delegate = self
        messageTextView.text = "メッセージ"
        messageTextView.textColor = UIColor.lightGray
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        categoryTextField.inputView = categoryPicker
        
        categoryTextField.delegate = self
        titleTextField.delegate = self
        messageTextView.delegate = self
        
        categoryTextField.layer.borderWidth = 1.0
        categoryTextField.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
        
        titleTextField.layer.borderWidth = 1.0
        titleTextField.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
        
        // メッセージTextViewに黒枠を追加
        // .borderWidth　ボーダーウィズ　線の太さ
        messageTextView.layer.borderWidth = 1.0
        // .borderColor ボーダーカラー　線の色　＝　UIkitのUIColor UIの色を決める型
        // cgColor CGColor型に変換するプロパティ
        // UIColorはUIKitの色の型。borderColorはCGColor型。だから変換が必要。
        messageTextView.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
        // .cornerRadius コーナーレイディアス　角丸の半径を指定するプロパティ（型は CGFloat）
        messageTextView.layer.cornerRadius = 5.0
        
        // pickerView のツールバー（完了ボタン付き）を作成
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "決定", style: .done, target: self, action: #selector(doneTapped))
        toolbar.setItems([spacer, doneButton], animated: false)
        
        categoryTextField.inputAccessoryView = toolbar
        
        // categoryTextFieldに何も初期値を設定しないことで、"緊急&重要"が勝手に選ばれないようにする
        categoryTextField.text = ""
        
    }
    
    //閉じるボタンの処理
    @IBAction func closeButton(_ sender: UIButton) {
        self.dismiss(animated: true , completion: nil)
    }
    
    //その保存処理
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        //何かしら文字が埋まっていれば安全なアンラップができる
        guard let title = titleTextField.text, !title.isEmpty else { return }
        // ① 既存のToDoリストを読み込む
        // カレントリストを定義：　[元の保存機能構造体] = 空の配列を代入
        var currentList: [TodoItem] = []
        // defaultsを定義　＝　ユーザーデフォルツ　ユーザーの設定やちょっとしたデータを保存・読み込みできます。
        let defaults = UserDefaults.standard
        // if let nilか確認し、処理を分ける { nilではなく値がある場合 } else { nilの場合 }
        // savedData = defaultsのdataメソッド（とその保存キー）
        if let savedData = defaults.data(forKey: todoKey),
           // 2つ目の if let こちらもnilかチェックしていく
           // decodedListを定義
            // try? エラー処理演算子の一つ　オプショナルトライ　エラーが出たら nil を返す演算子
            // デコードで保存してあるTodoItemを読み込んでいる。保存処理の第１工程
            let decodedList = try? JSONDecoder().decode([TodoItem].self, from: savedData) {
            // カレントリスト　＝　デコードリスト デコードされた時に成立する
            currentList = decodedList
        }
        // ② 新しいアイテムを追加
        // ニューアイテム = トゥドゥアイテム（falseの時は）
        let newItem = TodoItem(title: title, completed: false)
        // カレントリストにnewItemを追加
        currentList.append(newItem)
        
        // ③ リストを再度保存（エンコード）
        if let encoded = try? JSONEncoder().encode(currentList) {
            defaults.set(encoded, forKey: todoKey)
            
            NotificationCenter.default.post(name: Notification.Name("TaskAdded"), object: nil)
            
            // ④ 画面を閉じる
            dismiss(animated: true, completion: nil)
            
            print("カテゴリーテキストを保存します")
            
            
        }
    }
    
    @objc func doneTapped() {
        // nil の場合は0（＝緊急&重要）を代入
        let selectedIndex = selectedCategoryIndex ?? 0
        categoryTextField.text = categoryOptions[selectedIndex]
        selectedCategoryIndex = selectedIndex // 初回確定のためセットしておく
        categoryTextField.resignFirstResponder()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        //        outputText.text = textField.text
        return true
    }
    
}
extension AddTaskViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // 列数（基本1列）
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // 行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryOptions.count
    }
    
    // 行に表示する文字列
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategoryIndex = row
    }
}

// UITextFieldDelegateを準拠
extension AddTaskViewController: UITextFieldDelegate {
    // テキストフィールドメソッド（UITextFieldを対象に…）
    // shouldChangeCharactersIn シュッド・チェンジ・キャラクターズ・イン　文字を入力・削除しようとしたときに呼ばれるデリゲートメソッド
    // NSRange エヌエスレンジ　開始位置＋長さで範囲を表す型
    // replacementString リプレースメント・ストリング 入力・削除・貼り付けしようとしている文字列
    // -> Bool　関数の戻り値の型
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // マックスレングス　最大の長さ
        let maxLength = 20
        // カレントテキスト 現在入力されている文字列
        // ?? ""　nil合体演算子　左の値がnilの時、空の文字列
        let currentText = textField.text ?? ""
        // guard let文 オプショナル値が nil でないことを確認し、その後にアンラップされた値を使用できるようにします。
        // 条件式　guard let = nil else {nil処理（return）}　non-nil処理
        // stringRange（swift）　＝　Range：範囲（range(Objective-CのNSRange型),in(currentText型)）エルス　nilの時リターンフォルス（nilの時入力に失敗する）
        // よってstringRange　は　Range<String.Index>型　となった
        guard let stringRange = Range(range, in: currentText) else { return false }
        //　updatedText ＝　currentText　空のテキストフィールド
        // replacingCharacters リプレイシング・キャラクターズ 文字列の一部を別の文字列に置き換える
        // in: 差し替える範囲
        // with: 置き換える文字列
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        // リターン　updatedTextの要素数を返す　＜＝　マックスレングス
        // つまり、マックスレングスのほうが大きいが成立するならtrue
        // <=　比較演算子　結果はBool型になる
        return updatedText.count <= maxLength
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            if textField == categoryTextField {
                let currentRow = categoryPicker.selectedRow(inComponent: 0)
                selectedCategoryIndex = currentRow
            }
        }
    }
}
// UITextViewDelegateを準拠（必要に応じて）
extension AddTaskViewController: UITextViewDelegate {
    // textViewDidBeginEditing テキストビュー・ディッド・ビギン・エディティング
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "メッセージ" {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "メッセージ"
            textView.textColor = .lightGray
        }
    }
}
