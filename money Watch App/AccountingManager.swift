//
//  AccountingManager.swift
//  money Watch App
//
//  Created by Show on 2024/7/16.
//

import Foundation
import SQLite3

// MARK: - Models

struct AccountBook: Identifiable, Hashable, Codable {
    let id: Int
    let currency: String
    let name: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: AccountBook, rhs: AccountBook) -> Bool {
        lhs.id == rhs.id
    }
}

struct Expense: Identifiable {
    let id: Int
    let bookId: Int
    let income: Double
    let date: Date
    let note: String
    let categoryId: Int
}

// 新增: 預算結構
struct Budget: Identifiable {
    let id: Int
    let bookId: Int
    let categoryId: Int
    let amount: Double
    let period: BudgetPeriod
    let createdDate: Date
}

enum BudgetPeriod: Int, CaseIterable {
    case monthly = 1
    case weekly
    case daily
    
    var name: String {
        switch self {
        case .monthly: return NSLocalizedString("Monthly", comment: "")
        case .weekly: return NSLocalizedString("Weekly", comment: "")
        case .daily: return NSLocalizedString("Daily", comment: "")
        }
    }
}

enum Category: Int, CaseIterable {
    case foodAndEntertainment = 1
    case shopping
    case pocketMoney
    case travel
    case transportation
    
    var key: String {
        switch self {
        case .foodAndEntertainment: return "Food & Entertainment"
        case .shopping: return "Shopping"
        case .pocketMoney: return "Pocket Money"
        case .travel: return "Travel"
        case .transportation: return "Transportation"
        }
    }
    
    var name: String {
        NSLocalizedString(key, comment: "")
    }
}

// MARK: - Protocols

protocol DatabaseManager {
    var db: OpaquePointer? { get }
    func openDatabase() -> Bool
    func closeDatabase()
}

protocol AccountBookRepository {
    func saveAccountBook(currency: String, name: String) -> Bool
    func getAccountBooks() -> [AccountBook]
    func deleteAccountBook(id: Int) -> Bool
    func updateAccountBook(_ accountBook: AccountBook) -> Bool
}

protocol ExpenseRepository {
    func saveExpense(expense: Expense) -> Bool
    func getExpenses(bookId: Int) -> [Expense]
    func deleteExpense(id: Int) -> Bool
    func updateExpense(_ expense: Expense) -> Bool
}

// MARK: - Implementation

class SQLiteDatabaseManager: DatabaseManager {
    var db: OpaquePointer?
    private let dbPath: String
    
    init() {
        // 使用App Groups共享容器來存儲數據庫
        if let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.show.money") {
            dbPath = sharedContainerURL.appendingPathComponent("accounting.sqlite").path
            
            // 檢查是否需要遷移舊數據
            migrateDataIfNeeded(to: dbPath)
        } else {
            // 回退到原來的路徑（如果App Groups設置失敗）
            dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!.appending("/accounting.sqlite")
            print("⚠️ App Groups not available, using private directory")
        }
        print("📁 SQLite database path: \(dbPath)")
    }
    
    private func migrateDataIfNeeded(to newPath: String) {
        let fileManager = FileManager.default
        let oldPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!.appending("/accounting.sqlite")
        
        // 如果新位置已有數據庫，不需要遷移
        if fileManager.fileExists(atPath: newPath) {
            print("✅ Database already exists in shared container")
            return
        }
        
        // 如果舊位置有數據庫，進行遷移
        if fileManager.fileExists(atPath: oldPath) {
            do {
                try fileManager.copyItem(atPath: oldPath, toPath: newPath)
                print("📦 Successfully migrated database from \(oldPath) to \(newPath)")
                
                // 可選：刪除舊的數據庫文件
                // try fileManager.removeItem(atPath: oldPath)
            } catch {
                print("❌ Failed to migrate database: \(error)")
            }
        } else {
            print("📱 No existing database found, will create new one")
        }
    }
    
    func openDatabase() -> Bool {
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            print("Successfully opened database")
            createTables()
            return true
        } else {
            print("Unable to open database")
            return false
        }
    }
    
    func closeDatabase() {
        if let db = db {
            sqlite3_close(db)
        }
    }
    
    private func createTables() {
        let createExpenseTable = """
        CREATE TABLE IF NOT EXISTS Expense (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            bookId INTEGER,
            income REAL,
            date TEXT,
            note TEXT,
            categoryId INTEGER,
            FOREIGN KEY (bookId) REFERENCES AccountBook(id),
            FOREIGN KEY (categoryId) REFERENCES Category(id)
        );
        """
        
        let createAccountBookTable = """
        CREATE TABLE IF NOT EXISTS AccountBook (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            currency TEXT,
            name TEXT
        );
        """
        
        let createCategoryTable = """
        CREATE TABLE IF NOT EXISTS Category (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
        );
        """
        
        let createBudgetTable = """
        CREATE TABLE IF NOT EXISTS Budget (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            bookId INTEGER,
            categoryId INTEGER,
            amount REAL,
            period INTEGER,
            createdDate TEXT,
            FOREIGN KEY (bookId) REFERENCES AccountBook(id),
            FOREIGN KEY (categoryId) REFERENCES Category(id)
        );
        """
        
        executeQuery(query: createExpenseTable)
        executeQuery(query: createAccountBookTable)
        executeQuery(query: createCategoryTable)
        executeQuery(query: createBudgetTable)
        
        // Initialize categories
        for category in Category.allCases {
            insertCategory(id: category.rawValue, name: category.name)
        }
    }
    
    private func executeQuery(query: String) {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Query executed successfully")
            } else {
                print("Query execution failed")
            }
        } else {
            print("Query preparation failed")
        }
        sqlite3_finalize(statement)
    }
    
    private func insertCategory(id: Int, name: String) {
        let query = "INSERT OR IGNORE INTO Category (id, name) VALUES (?, ?);"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(id))
            sqlite3_bind_text(statement, 2, (name as NSString).utf8String, -1, nil)
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Category inserted successfully")
            } else {
                print("Failed to insert category")
            }
        } else {
            print("INSERT statement preparation failed")
        }
        sqlite3_finalize(statement)
    }
}

class SQLiteAccountBookRepository: AccountBookRepository {
    private let dbManager: DatabaseManager
    
    init(dbManager: DatabaseManager) {
        self.dbManager = dbManager
    }
    
    func saveAccountBook(currency: String, name: String) -> Bool {
        let query = "INSERT INTO AccountBook (currency, name) VALUES (?, ?);"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(dbManager.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (currency as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (name as NSString).utf8String, -1, nil)
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Account book saved successfully")
                sqlite3_finalize(statement)
                return true
            } else {
                print("Failed to save account book")
            }
        } else {
            print("INSERT statement preparation failed")
        }
        sqlite3_finalize(statement)
        return false
    }
    
    func getAccountBooks() -> [AccountBook] {
        var accountBooks: [AccountBook] = []
        let query = "SELECT id, currency, name FROM AccountBook;"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(dbManager.db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let currency = String(cString: sqlite3_column_text(statement, 1))
                let name = String(cString: sqlite3_column_text(statement, 2))
                accountBooks.append(AccountBook(id: id, currency: currency, name: name))
            }
        }
        sqlite3_finalize(statement)
        return accountBooks
    }
    
    func deleteAccountBook(id: Int) -> Bool {
        // 先刪除該帳本相關的所有記錄
        let deleteExpensesQuery = "DELETE FROM Expense WHERE bookId = ?;"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(dbManager.db, deleteExpensesQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(id))
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
        
        // 刪除該帳本相關的所有預算
        let deleteBudgetsQuery = "DELETE FROM Budget WHERE bookId = ?;"
        if sqlite3_prepare_v2(dbManager.db, deleteBudgetsQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(id))
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
        
        // 最後刪除帳本本身
        let deleteBookQuery = "DELETE FROM AccountBook WHERE id = ?;"
        if sqlite3_prepare_v2(dbManager.db, deleteBookQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(id))
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Account book deleted successfully")
                sqlite3_finalize(statement)
                return true
            } else {
                print("Failed to delete account book")
            }
        } else {
            print("DELETE statement preparation failed")
        }
        sqlite3_finalize(statement)
        return false
    }
    
    func updateAccountBook(_ accountBook: AccountBook) -> Bool {
        let query = "UPDATE AccountBook SET currency = ?, name = ? WHERE id = ?;"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(dbManager.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (accountBook.currency as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (accountBook.name as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 3, Int32(accountBook.id))
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Account book updated successfully")
                sqlite3_finalize(statement)
                return true
            } else {
                print("Failed to update account book")
            }
        } else {
            print("UPDATE statement preparation failed")
        }
        sqlite3_finalize(statement)
        return false
    }
}

class SQLiteExpenseRepository: ExpenseRepository {
    private let dbManager: DatabaseManager
    
    init(dbManager: DatabaseManager) {
        self.dbManager = dbManager
    }
    
    func saveExpense(expense: Expense) -> Bool {
        let query = "INSERT INTO Expense (bookId, income, date, note, categoryId) VALUES (?, ?, ?, ?, ?);"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(dbManager.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(expense.bookId))
            sqlite3_bind_double(statement, 2, expense.income)
            let dateString = ISO8601DateFormatter().string(from: expense.date)
            sqlite3_bind_text(statement, 3, (dateString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 4, (expense.note as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 5, Int32(expense.categoryId))
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Expense saved successfully")
                sqlite3_finalize(statement)
                return true
            } else {
                print("Failed to save expense")
            }
        } else {
            print("INSERT statement preparation failed")
        }
        sqlite3_finalize(statement)
        return false
    }
    
    func getExpenses(bookId: Int) -> [Expense] {
        var expenses: [Expense] = []
        let query = "SELECT id, income, date, note, categoryId FROM Expense WHERE bookId = ? ORDER BY date DESC;"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(dbManager.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(bookId))
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let income = sqlite3_column_double(statement, 1)
                let dateString = String(cString: sqlite3_column_text(statement, 2))
                let date = ISO8601DateFormatter().date(from: dateString) ?? Date()
                let note = String(cString: sqlite3_column_text(statement, 3))
                let categoryId = Int(sqlite3_column_int(statement, 4))
                expenses.append(Expense(id: id, bookId: bookId, income: income, date: date, note: note, categoryId: categoryId))
            }
        }
        sqlite3_finalize(statement)
        return expenses
    }
    
    func deleteExpense(id: Int) -> Bool {
        let query = "DELETE FROM Expense WHERE id = ?;"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(dbManager.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(id))
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Expense deleted successfully")
                sqlite3_finalize(statement)
                return true
            } else {
                print("Failed to delete expense")
            }
        } else {
            print("DELETE statement preparation failed")
        }
        sqlite3_finalize(statement)
        return false
    }
    
    func updateExpense(_ expense: Expense) -> Bool {
        let query = "UPDATE Expense SET income = ?, date = ?, note = ?, categoryId = ? WHERE id = ?;"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(dbManager.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_double(statement, 1, expense.income)
            let dateString = ISO8601DateFormatter().string(from: expense.date)
            sqlite3_bind_text(statement, 2, (dateString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (expense.note as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 4, Int32(expense.categoryId))
            sqlite3_bind_int(statement, 5, Int32(expense.id))
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Expense updated successfully")
                sqlite3_finalize(statement)
                return true
            } else {
                print("Failed to update expense")
            }
        } else {
            print("UPDATE statement preparation failed")
        }
        sqlite3_finalize(statement)
        return false
    }
}

class AccountingManager {
    static let shared = AccountingManager()
    
    private let dbManager: SQLiteDatabaseManager
    private let accountBookRepository: AccountBookRepository
    private let expenseRepository: ExpenseRepository
    
    private let lastOpenedBookKey = "lastOpenedBookId"
    
    private init() {
        dbManager = SQLiteDatabaseManager()
        accountBookRepository = SQLiteAccountBookRepository(dbManager: dbManager)
        expenseRepository = SQLiteExpenseRepository(dbManager: dbManager)
        setup()
    }
    
    private func setup() {
        guard dbManager.openDatabase() else {
            fatalError("Unable to open database")
        }
    }
    
    func createAccountBook(currency: String, name: String) -> Bool {
        return accountBookRepository.saveAccountBook(currency: currency, name: name)
    }
    
    func getAllAccountBooks() -> [AccountBook] {
        return accountBookRepository.getAccountBooks()
    }
    
    func deleteAccountBook(id: Int) -> Bool {
        return accountBookRepository.deleteAccountBook(id: id)
    }
    
    func updateAccountBook(_ accountBook: AccountBook) -> Bool {
        return accountBookRepository.updateAccountBook(accountBook)
    }
    
    func addExpense(bookId: Int, income: Double, date: Date, note: String, category: Category) -> Bool {
        let expense = Expense(id: 0, bookId: bookId, income: income, date: date, note: note, categoryId: category.rawValue)
        return expenseRepository.saveExpense(expense: expense)
    }
    
    func getExpenses(for bookId: Int) -> [Expense] {
        return expenseRepository.getExpenses(bookId: bookId)
    }
    
    func deleteExpense(id: Int) -> Bool {
        return expenseRepository.deleteExpense(id: id)
    }
    
    func updateExpense(_ expense: Expense) -> Bool {
        return expenseRepository.updateExpense(expense)
    }
    
    func getTotals(for bookId: Int) -> (totalIncome: Double, totalExpense: Double) {
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
        if sqlite3_prepare_v2(dbManager.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(bookId))
            if sqlite3_step(statement) == SQLITE_ROW {
                totalIncome = sqlite3_column_double(statement, 0)
                totalExpense = sqlite3_column_double(statement, 1)
            }
        }
        sqlite3_finalize(statement)
        
        return (totalIncome, totalExpense)
    }
    
    func saveLastOpenedBook(id: Int) {
        // 同時保存到標準UserDefaults和App Groups共享容器
        UserDefaults.standard.set(id, forKey: lastOpenedBookKey)
        
        if let appGroupDefaults = UserDefaults(suiteName: "group.com.show.money") {
            appGroupDefaults.set(id, forKey: lastOpenedBookKey)
        }
    }

    func getLastOpenedBookId() -> Int? {
        // 優先從App Groups讀取，如果沒有則從標準UserDefaults讀取
        if let appGroupDefaults = UserDefaults(suiteName: "group.com.show.money"),
           let bookId = appGroupDefaults.object(forKey: lastOpenedBookKey) as? Int {
            return bookId
        }
        return UserDefaults.standard.object(forKey: lastOpenedBookKey) as? Int
    }
    
    // 新增: 獲取分類支出統計
    func getCategoryExpenseStats(for bookId: Int) -> [CategoryExpenseStat] {
        var stats: [CategoryExpenseStat] = []
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
        if sqlite3_prepare_v2(dbManager.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(bookId))
            while sqlite3_step(statement) == SQLITE_ROW {
                let categoryId = Int(sqlite3_column_int(statement, 0))
                let totalExpense = sqlite3_column_double(statement, 1)
                stats.append(CategoryExpenseStat(categoryId: categoryId, totalExpense: totalExpense))
            }
        }
        sqlite3_finalize(statement)
        
        // 計算百分比
        let totalExpense = stats.reduce(0) { $0 + $1.totalExpense }
        return stats.map { stat in
            CategoryExpenseStat(
                categoryId: stat.categoryId,
                totalExpense: stat.totalExpense,
                percentage: totalExpense > 0 ? (stat.totalExpense / totalExpense) * 100 : 0
            )
        }
    }
    
    // 新增: 預算管理方法
    func saveBudget(bookId: Int, categoryId: Int, amount: Double, period: BudgetPeriod) -> Bool {
        // 先檢查是否已存在該分類的預算，如果存在則更新
        if let existingBudget = getBudget(bookId: bookId, categoryId: categoryId) {
            return updateBudget(id: existingBudget.id, amount: amount, period: period)
        }
        
        let query = "INSERT INTO Budget (bookId, categoryId, amount, period, createdDate) VALUES (?, ?, ?, ?, ?);"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(dbManager.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(bookId))
            sqlite3_bind_int(statement, 2, Int32(categoryId))
            sqlite3_bind_double(statement, 3, amount)
            sqlite3_bind_int(statement, 4, Int32(period.rawValue))
            let dateString = ISO8601DateFormatter().string(from: Date())
            sqlite3_bind_text(statement, 5, (dateString as NSString).utf8String, -1, nil)
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Budget saved successfully")
                sqlite3_finalize(statement)
                return true
            }
        }
        sqlite3_finalize(statement)
        return false
    }
    
    func getBudgets(for bookId: Int) -> [Budget] {
        var budgets: [Budget] = []
        let query = "SELECT id, categoryId, amount, period, createdDate FROM Budget WHERE bookId = ?;"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(dbManager.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(bookId))
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let categoryId = Int(sqlite3_column_int(statement, 1))
                let amount = sqlite3_column_double(statement, 2)
                let period = BudgetPeriod(rawValue: Int(sqlite3_column_int(statement, 3))) ?? .monthly
                let dateString = String(cString: sqlite3_column_text(statement, 4))
                let date = ISO8601DateFormatter().date(from: dateString) ?? Date()
                budgets.append(Budget(id: id, bookId: bookId, categoryId: categoryId, amount: amount, period: period, createdDate: date))
            }
        }
        sqlite3_finalize(statement)
        return budgets
    }
    
    func getBudget(bookId: Int, categoryId: Int) -> Budget? {
        let query = "SELECT id, amount, period, createdDate FROM Budget WHERE bookId = ? AND categoryId = ?;"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(dbManager.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(bookId))
            sqlite3_bind_int(statement, 2, Int32(categoryId))
            if sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let amount = sqlite3_column_double(statement, 1)
                let period = BudgetPeriod(rawValue: Int(sqlite3_column_int(statement, 2))) ?? .monthly
                let dateString = String(cString: sqlite3_column_text(statement, 3))
                let date = ISO8601DateFormatter().date(from: dateString) ?? Date()
                sqlite3_finalize(statement)
                return Budget(id: id, bookId: bookId, categoryId: categoryId, amount: amount, period: period, createdDate: date)
            }
        }
        sqlite3_finalize(statement)
        return nil
    }
    
    func updateBudget(id: Int, amount: Double, period: BudgetPeriod) -> Bool {
        let query = "UPDATE Budget SET amount = ?, period = ? WHERE id = ?;"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(dbManager.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_double(statement, 1, amount)
            sqlite3_bind_int(statement, 2, Int32(period.rawValue))
            sqlite3_bind_int(statement, 3, Int32(id))
            if sqlite3_step(statement) == SQLITE_DONE {
                sqlite3_finalize(statement)
                return true
            }
        }
        sqlite3_finalize(statement)
        return false
    }
    
    func deleteBudget(id: Int) -> Bool {
        let query = "DELETE FROM Budget WHERE id = ?;"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(dbManager.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(id))
            if sqlite3_step(statement) == SQLITE_DONE {
                sqlite3_finalize(statement)
                return true
            }
        }
        sqlite3_finalize(statement)
        return false
    }
    
    // 獲取預算使用情況
    func getBudgetProgress(for bookId: Int, categoryId: Int, period: BudgetPeriod) -> (spent: Double, budget: Double) {
        guard let budget = getBudget(bookId: bookId, categoryId: categoryId) else {
            return (0, 0)
        }
        
        let now = Date()
        let calendar = Calendar.current
        var startDate: Date
        
        switch period {
        case .monthly:
            startDate = calendar.dateInterval(of: .month, for: now)?.start ?? now
        case .weekly:
            startDate = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        case .daily:
            startDate = calendar.startOfDay(for: now)
        }
        
        let query = """
        SELECT SUM(CASE WHEN income < 0 THEN ABS(income) ELSE 0 END) as totalSpent
        FROM Expense 
        WHERE bookId = ? AND categoryId = ? AND date >= ?;
        """
        
        var spent: Double = 0
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(dbManager.db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(bookId))
            sqlite3_bind_int(statement, 2, Int32(categoryId))
            let dateString = ISO8601DateFormatter().string(from: startDate)
            sqlite3_bind_text(statement, 3, (dateString as NSString).utf8String, -1, nil)
            if sqlite3_step(statement) == SQLITE_ROW {
                spent = sqlite3_column_double(statement, 0)
            }
        }
        sqlite3_finalize(statement)
        
        return (spent, budget.amount)
    }
    
    deinit {
        dbManager.closeDatabase()
    }
}

// 新增: 分類支出統計結構
struct CategoryExpenseStat {
    let categoryId: Int
    let totalExpense: Double
    let percentage: Double
    
    init(categoryId: Int, totalExpense: Double, percentage: Double = 0) {
        self.categoryId = categoryId
        self.totalExpense = totalExpense
        self.percentage = percentage
    }
}
