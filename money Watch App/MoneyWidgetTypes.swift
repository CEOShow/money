//
//  MoneyWidgetTypes.swift
//  money Watch App
//
//  Created by AI Assistant on 2024/12/20.
//

import Foundation
import SQLite3

// MARK: - Shared Widget Configuration Types

public struct MoneyWidgetConfiguration: Codable {
    public let selectedBookId: Int?
    public let showBalance: Bool
    public let showBudgetProgress: Bool
    public let showCategoryStats: Bool
    public let autoRefreshEnabled: Bool
    public let refreshInterval: RefreshInterval
    
    public init(selectedBookId: Int?, showBalance: Bool, showBudgetProgress: Bool, showCategoryStats: Bool, autoRefreshEnabled: Bool, refreshInterval: RefreshInterval) {
        self.selectedBookId = selectedBookId
        self.showBalance = showBalance
        self.showBudgetProgress = showBudgetProgress
        self.showCategoryStats = showCategoryStats
        self.autoRefreshEnabled = autoRefreshEnabled
        self.refreshInterval = refreshInterval
    }
    
    static func load() -> MoneyWidgetConfiguration? {
        // 嘗試從App Groups讀取，如果失敗則從標準UserDefaults讀取
        let appGroupDefaults = UserDefaults(suiteName: "group.com.show.money")
        let standardDefaults = UserDefaults.standard
        
        var data: Data?
        if let appGroupData = appGroupDefaults?.data(forKey: "WidgetConfiguration") {
            data = appGroupData
        } else if let standardData = standardDefaults.data(forKey: "WidgetConfiguration") {
            data = standardData
        }
        
        guard let configData = data,
              let config = try? JSONDecoder().decode(MoneyWidgetConfiguration.self, from: configData) else {
            return nil
        }
        return config
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            // 同時保存到App Groups和標準UserDefaults
            let appGroupDefaults = UserDefaults(suiteName: "group.com.show.money")
            let standardDefaults = UserDefaults.standard
            
            appGroupDefaults?.set(data, forKey: "WidgetConfiguration")
            standardDefaults.set(data, forKey: "WidgetConfiguration")
        }
    }
}

public enum RefreshInterval: String, CaseIterable, Codable {
    case fifteenMinutes = "15min"
    case thirtyMinutes = "30min"
    case oneHour = "1hour"
    case twoHours = "2hour"
    
    public var displayName: String {
        switch self {
        case .fifteenMinutes: return "15分鐘"
        case .thirtyMinutes: return "30分鐘"
        case .oneHour: return "1小時"
        case .twoHours: return "2小時"
        }
    }
    
    public var timeInterval: TimeInterval {
        switch self {
        case .fifteenMinutes: return 15 * 60
        case .thirtyMinutes: return 30 * 60
        case .oneHour: return 60 * 60
        case .twoHours: return 120 * 60
        }
    }
}

// MARK: - Shared Data Models

public struct WidgetAccountBook {
    public let id: Int
    public let currency: String
    public let name: String
}

public struct WidgetCategoryExpenseStat {
    public let categoryId: Int
    public let totalExpense: Double
    public let percentage: Double
}

// MARK: - Shared Database Reader

public class SharedDatabaseReader {
    private var db: OpaquePointer?
    private let dbPath: String
    
    public static let shared = SharedDatabaseReader()
    
    private init() {
        // 使用與主應用相同的App Groups共享容器
        if let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.show.money") {
            dbPath = sharedContainerURL.appendingPathComponent("accounting.sqlite").path
        } else {
            // 回退路徑
            dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!.appending("/accounting.sqlite")
        }
        print("🔗 Widget database path: \(dbPath)")
    }
    
    private func openDatabase() -> Bool {
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            return true
        } else {
            print("❌ Widget unable to open database")
            return false
        }
    }
    
    private func closeDatabase() {
        if let db = db {
            sqlite3_close(db)
        }
    }
    
    public func getAllAccountBooks() -> [WidgetAccountBook] {
        guard openDatabase() else { return [] }
        defer { closeDatabase() }
        
        var books: [WidgetAccountBook] = []
        let query = "SELECT id, currency, name FROM AccountBook;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let currency = String(cString: sqlite3_column_text(statement, 1))
                let name = String(cString: sqlite3_column_text(statement, 2))
                books.append(WidgetAccountBook(id: id, currency: currency, name: name))
            }
        }
        sqlite3_finalize(statement)
        return books
    }
    
    public func getTotals(for bookId: Int) -> (totalIncome: Double, totalExpense: Double) {
        guard openDatabase() else { return (0, 0) }
        defer { closeDatabase() }
        
        var totalIncome: Double = 0
        var totalExpense: Double = 0
        
        let query = """
        SELECT
            SUM(CASE WHEN income >= 0 THEN income ELSE 0 END) AS totalIncome,
            SUM(CASE WHEN income < 0 THEN ABS(income) ELSE 0 END) AS totalExpense
        FROM Expense
        WHERE bookId = ?;
        """
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(bookId))
            if sqlite3_step(statement) == SQLITE_ROW {
                totalIncome = sqlite3_column_double(statement, 0)
                totalExpense = sqlite3_column_double(statement, 1)
            }
        }
        sqlite3_finalize(statement)
        
        return (totalIncome, totalExpense)
    }
    
    public func getCategoryExpenseStats(for bookId: Int) -> [WidgetCategoryExpenseStat] {
        guard openDatabase() else { return [] }
        defer { closeDatabase() }
        
        var stats: [WidgetCategoryExpenseStat] = []
        let query = """
        SELECT 
            categoryId,
            SUM(CASE WHEN income < 0 THEN ABS(income) ELSE 0 END) as totalExpense
        FROM Expense 
        WHERE bookId = ? 
        GROUP BY categoryId
        HAVING totalExpense > 0
        ORDER BY totalExpense DESC;
        """
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(bookId))
            while sqlite3_step(statement) == SQLITE_ROW {
                let categoryId = Int(sqlite3_column_int(statement, 0))
                let totalExpense = sqlite3_column_double(statement, 1)
                stats.append(WidgetCategoryExpenseStat(categoryId: categoryId, totalExpense: totalExpense, percentage: 0))
            }
        }
        sqlite3_finalize(statement)
        
        // 計算百分比
        let totalExpense = stats.reduce(0) { $0 + $1.totalExpense }
        return stats.map { stat in
            WidgetCategoryExpenseStat(
                categoryId: stat.categoryId,
                totalExpense: stat.totalExpense,
                percentage: totalExpense > 0 ? (stat.totalExpense / totalExpense) * 100 : 0
            )
        }
    }
    
    public func getLastOpenedBookId() -> Int? {
        let userDefaults = UserDefaults(suiteName: "group.com.show.money") ?? UserDefaults.standard
        let bookId = userDefaults.object(forKey: "lastOpenedBookId") as? Int
        return bookId
    }
    
    public func getBudgetProgress(for bookId: Int, categoryId: Int) -> (spent: Double, budget: Double) {
        guard openDatabase() else { return (0, 0) }
        defer { closeDatabase() }
        
        // 獲取預算
        let budgetQuery = "SELECT amount FROM Budget WHERE bookId = ? AND categoryId = ? LIMIT 1;"
        var budgetAmount: Double = 0
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, budgetQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(bookId))
            sqlite3_bind_int(statement, 2, Int32(categoryId))
            if sqlite3_step(statement) == SQLITE_ROW {
                budgetAmount = sqlite3_column_double(statement, 0)
            }
        }
        sqlite3_finalize(statement)
        
        if budgetAmount == 0 {
            return (0, 0)
        }
        
        // 獲取本月支出
        let now = Date()
        let calendar = Calendar.current
        let startDate = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        let expenseQuery = """
        SELECT SUM(CASE WHEN income < 0 THEN ABS(income) ELSE 0 END) as totalSpent
        FROM Expense 
        WHERE bookId = ? AND categoryId = ? AND date >= ?;
        """
        
        var spent: Double = 0
        if sqlite3_prepare_v2(db, expenseQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(bookId))
            sqlite3_bind_int(statement, 2, Int32(categoryId))
            let dateString = ISO8601DateFormatter().string(from: startDate)
            sqlite3_bind_text(statement, 3, (dateString as NSString).utf8String, -1, nil)
            if sqlite3_step(statement) == SQLITE_ROW {
                spent = sqlite3_column_double(statement, 0)
            }
        }
        sqlite3_finalize(statement)
        
        return (spent, budgetAmount)
    }
} 