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
        
        // --- プレースホルダーと初期テキスト ---
        categoryTextField.placeholder = "カテゴリ"
        titleTextField.placeholder = "タイトル"
        messageTextView.text = "メッセージ"
        messageTextView.textColor = .lightGray
        categoryTextField.text = "" // 自動選択されないよう空文字
        
        // --- PickerView 設定 ---
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        categoryTextField.inputView = categoryPicker
        
        // --- ツールバー作成（Picker用） ---
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "決定", style: .done, target: self, action: #selector(doneTapped))
        toolbar.setItems([spacer, doneButton], animated: false)
        categoryTextField.inputAccessoryView = toolbar
        
        // --- デリゲート設定 ---
        categoryTextField.delegate = self
        titleTextField.delegate = self
        messageTextView.delegate = self
        
        // --- 枠線と角丸設定 ---
        // cgColor CGColor型に変換するプロパティ
        // UIColorはUIKitの色の型。borderColorはCGColor型。だから変換が必要。
        // .withAlphaComponent(0.3) → 透過度30%の黒色に変えています（0が完全透明、1が不透明）。
        let borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
        
        categoryTextField.layer.borderWidth = 1.0
        categoryTextField.layer.borderColor = borderColor

        titleTextField.layer.borderWidth = 1.0
        titleTextField.layer.borderColor = borderColor

        // メッセージTextViewに黒枠を追加
        // .borderWidth　ボーダーウィズ　線の太さ
        messageTextView.layer.borderWidth = 1.0
        // .borderColor ボーダーカラー　線の色　＝　UIkitのUIColor UIの色を決める型
        messageTextView.layer.borderColor = borderColor
        // .cornerRadius コーナーレイディアス　角丸の半径を指定するプロパティ（型は CGFloat）
        messageTextView.layer.cornerRadius = 5.0
        
        messageTextView.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
        
        
    }
    
    //閉じるボタンの処理
    @IBAction func closeButton(_ sender: UIButton) {
        self.dismiss(animated: true , completion: nil)
    }
    
    //その保存処理
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let title = titleTextField.text, !title.isEmpty else { return }
        
        let category = categoryTextField.text ?? "未設定"
        let message = (messageTextView.text == "メッセージ") ? "" : messageTextView.text ?? ""
        let newItem = TodoItem(category: category, title: title, message: message, completed: false)
        
        var currentList: [TodoItem] = []
        
        let defaults = UserDefaults.standard
        if let savedData = defaults.data(forKey: "TodoList"),
           let savedList = try? JSONDecoder().decode(TodoList.self, from: savedData) {
            currentList = savedList.items
        }
        
        // ✅ newItemを追加
        currentList.append(newItem)
        
        // ✅ TodoList構造体にラップ
        let updatedList = TodoList(items: currentList)
        
        do {
            let encoded = try JSONEncoder().encode(updatedList)
            defaults.set(encoded, forKey: "TodoList")
            NotificationCenter.default.post(name: Notification.Name("TaskAdded"), object: nil)
            dismiss(animated: true, completion: nil)
            print("✅ 保存成功: \(newItem.title), カテゴリ: \(newItem.category)")
        } catch {
            print("❌ エンコード失敗: \(error)")
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
        // 何もしない（即時確定させたくないから）
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
