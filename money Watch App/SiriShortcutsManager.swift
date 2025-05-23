//
//  SiriShortcutsManager.swift
//  money Watch App
//
//  Created by Show on 2024/12/19.
//

import Foundation

class SiriShortcutsManager: ObservableObject {
    static let shared = SiriShortcutsManager()
    
    private init() {}
    
    // 處理語音輸入文字解析
    func processVoiceInput(_ text: String) -> (amount: Double?, note: String?) {
        let cleanText = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 嘗試解析金額
        let amount = extractAmount(from: cleanText)
        
        // 提取備註（移除金額相關的文字）
        let note = extractNote(from: cleanText, amount: amount)
        
        return (amount, note)
    }
    
    private func extractAmount(from text: String) -> Double? {
        // 常見的金額格式匹配
        let patterns = [
            "(?:花了|花費|支出|買了|付了)?\\s*(\\d+(?:\\.\\d+)?)\\s*(?:元|塊|塊錢|dollar|dollars)?",
            "(\\d+(?:\\.\\d+)?)\\s*(?:元|塊|塊錢|dollar|dollars)",
            "(?:價格|金額|費用)\\s*(\\d+(?:\\.\\d+)?)"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(location: 0, length: text.utf16.count)
                if let match = regex.firstMatch(in: text, options: [], range: range) {
                    if match.numberOfRanges > 1 {
                        let numberRange = match.range(at: 1)
                        if let range = Range(numberRange, in: text) {
                            let numberString = String(text[range])
                            return Double(numberString)
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    private func extractNote(from text: String, amount: Double?) -> String? {
        var note = text
        
        // 移除常見的記帳關鍵字
        let removePatterns = [
            "記帳",
            "記錄",
            "支出",
            "花費",
            "花了",
            "買了",
            "付了",
            "元",
            "塊錢",
            "塊",
            "dollar",
            "dollars"
        ]
        
        for pattern in removePatterns {
            note = note.replacingOccurrences(of: pattern, with: "", options: .caseInsensitive)
        }
        
        // 移除金額
        if let amount = amount {
            let amountString = String(format: "%.0f", amount)
            note = note.replacingOccurrences(of: amountString, with: "")
        }
        
        // 清理空白和標點符號
        note = note.trimmingCharacters(in: .whitespacesAndNewlines.union(.punctuationCharacters))
        return note.isEmpty ? nil : note
    }
    
    // 快速記帳方法
    func quickAddExpense(amount: Double, note: String, completion: @escaping (Bool) -> Void) {
        let accountingManager = AccountingManager.shared
        
        guard let lastBookId = accountingManager.getLastOpenedBookId() else {
            completion(false)
            return
        }
        
        // 自動分類
        let category = categorizeExpenseByNote(note)
        
        // 金額為負數表示支出
        let expenseAmount = -abs(amount)
        
        let success = accountingManager.addExpense(
            bookId: lastBookId,
            income: expenseAmount,
            date: Date(),
            note: note,
            category: category
        )
        
        completion(success)
    }
    
    private func categorizeExpenseByNote(_ note: String) -> Category {
        let lowercaseNote = note.lowercased()
        
        // 食物與娛樂
        let foodKeywords = ["吃", "喝", "餐", "飲", "咖啡", "茶", "早餐", "午餐", "晚餐", "宵夜", "零食", "甜點", "餅乾", "飲料", "果汁", "啤酒", "酒", "餐廳", "小吃", "火鍋"]
        
        // 購物
        let shoppingKeywords = ["買", "購", "衣", "鞋", "包", "帽", "褲", "裙", "化妝", "保養", "清潔", "日用品", "生活用品", "書", "文具", "電子產品", "手機", "電腦"]
        
        // 交通
        let transportKeywords = ["車", "油", "汽油", "捷運", "公車", "公交", "計程車", "計程", "停車", "過路費", "票", "交通", "uber", "taxi", "機車", "汽車"]
        
        // 旅遊
        let travelKeywords = ["旅", "住宿", "飯店", "酒店", "旅館", "機票", "車票", "景點", "門票", "旅遊", "度假", "出遊"]
        
        for keyword in foodKeywords {
            if lowercaseNote.contains(keyword) {
                return .foodAndEntertainment
            }
        }
        
        for keyword in shoppingKeywords {
            if lowercaseNote.contains(keyword) {
                return .shopping
            }
        }
        
        for keyword in transportKeywords {
            if lowercaseNote.contains(keyword) {
                return .transportation
            }
        }
        
        for keyword in travelKeywords {
            if lowercaseNote.contains(keyword) {
                return .travel
            }
        }
        
        return .pocketMoney
    }
} 
