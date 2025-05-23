//
//  AddExpenseIntent.swift
//  money Watch App
//
//  Created by Show on 2024/12/19.
//

import Foundation
import Intents

// 簡化的記帳 Intent 處理器
@available(iOS 14.0, watchOS 7.0, *)
class AddExpenseIntentHandler: NSObject {
    
    func handleAddExpense(amount: Double, note: String, completion: @escaping (Bool) -> Void) {
        // 取得最後打開的帳本
        let accountingManager = AccountingManager.shared
        guard let lastBookId = accountingManager.getLastOpenedBookId() else {
            completion(false)
            return
        }
        
        // 判斷分類（簡單的關鍵字匹配）
        let category = categorizeExpense(note: note)
        
        // 金額為負數表示支出
        let expenseAmount = -abs(amount)
        
        // 儲存支出
        let success = accountingManager.addExpense(
            bookId: lastBookId,
            income: expenseAmount,
            date: Date(),
            note: note,
            category: category
        )
        
        completion(success)
    }
    
    private func categorizeExpense(note: String) -> Category {
        let lowercaseNote = note.lowercased()
        
        if lowercaseNote.contains("吃") || lowercaseNote.contains("喝") || 
           lowercaseNote.contains("餐") || lowercaseNote.contains("飲") ||
           lowercaseNote.contains("咖啡") || lowercaseNote.contains("零食") {
            return .foodAndEntertainment
        } else if lowercaseNote.contains("買") || lowercaseNote.contains("購") ||
                  lowercaseNote.contains("衣") || lowercaseNote.contains("鞋") {
            return .shopping
        } else if lowercaseNote.contains("車") || lowercaseNote.contains("油") ||
                  lowercaseNote.contains("捷運") || lowercaseNote.contains("公車") ||
                  lowercaseNote.contains("計程車") || lowercaseNote.contains("停車") {
            return .transportation
        } else if lowercaseNote.contains("旅") || lowercaseNote.contains("住宿") ||
                  lowercaseNote.contains("機票") || lowercaseNote.contains("景點") {
            return .travel
        } else {
            return .pocketMoney
        }
    }
} 