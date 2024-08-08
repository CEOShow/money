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

enum Category: Int, CaseIterable {
    case foodAndEntertainment = 1
    case shopping
    case pocketMoney
    case travel
    case transportation
    
    var name: String {
        switch self {
        case .foodAndEntertainment: return "吃喝玩樂"
        case .shopping: return "購物"
        case .pocketMoney: return "零用錢"
        case .travel: return "旅行"
        case .transportation: return "交通"
        }
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
        dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!.appending("/accounting.sqlite")
        print("SQLite database path: \(dbPath)")
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
        
        executeQuery(query: createExpenseTable)
        executeQuery(query: createAccountBookTable)
        executeQuery(query: createCategoryTable)
        
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
        UserDefaults.standard.set(id, forKey: lastOpenedBookKey)
    }

    func getLastOpenedBookId() -> Int? {
        return UserDefaults.standard.object(forKey: lastOpenedBookKey) as? Int
    }
    
    deinit {
        dbManager.closeDatabase()
    }
}
