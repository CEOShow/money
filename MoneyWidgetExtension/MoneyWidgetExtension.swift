//
//  MoneyWidgetExtension.swift
//  MoneyWidgetExtension
//
//  Created by Show on 2025/7/19.
//

import WidgetKit
import SwiftUI

// MARK: - Widget Implementation (using shared types from MoneyWidgetTypes.swift)

// MARK: - Widget Implementation

struct MoneyWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> MoneyWidgetEntry {
        MoneyWidgetEntry(
            date: Date(),
            balance: 12500,
            income: 25000,
            expense: 12500,
            bookName: "我的帳本",
            categoryStats: [
                WidgetCategoryExpenseStat(categoryId: 1, totalExpense: 3000, percentage: 40),
                WidgetCategoryExpenseStat(categoryId: 2, totalExpense: 2000, percentage: 30),
                WidgetCategoryExpenseStat(categoryId: 3, totalExpense: 1500, percentage: 20)
            ],
            budgetProgress: (spent: 3000, budget: 5000)
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (MoneyWidgetEntry) -> ()) {
        let entry = getLatestEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MoneyWidgetEntry>) -> ()) {
        let currentDate = Date()
        let entry = getLatestEntry()
        
        // 根據用戶配置調整更新頻率
        let refreshInterval: TimeInterval
        if let config = MoneyWidgetConfiguration.load(), config.autoRefreshEnabled {
            refreshInterval = config.refreshInterval.timeInterval
        } else {
            refreshInterval = 60 * 60 // 預設1小時
        }
        
        let refreshDate = Calendar.current.date(byAdding: .second, value: Int(refreshInterval), to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }
    
    private func getLatestEntry() -> MoneyWidgetEntry {
        let databaseReader = SharedDatabaseReader.shared
        let config = MoneyWidgetConfiguration.load()
        
        // 獲取所有帳本
        let books = databaseReader.getAllAccountBooks()
        print("🔍 Widget Extension: Found \(books.count) books")
        
        for book in books {
            print("📖 Book: ID=\(book.id), Name=\(book.name), Currency=\(book.currency)")
        }
        
        // 根據配置選擇帳本
        var selectedBook: WidgetAccountBook?
        if let configBookId = config?.selectedBookId {
            print("⚙️ Config specifies book ID: \(configBookId)")
            selectedBook = books.first(where: { $0.id == configBookId })
            if selectedBook != nil {
                print("✅ Found book from config: \(selectedBook!.name)")
            } else {
                print("❌ Book \(configBookId) from config not found")
            }
        } else {
            print("⚙️ No book specified in config")
        }
        
        if selectedBook == nil {
            if let lastBookId = databaseReader.getLastOpenedBookId() {
                print("🔄 Trying last opened book: \(lastBookId)")
                selectedBook = books.first(where: { $0.id == lastBookId })
                if selectedBook != nil {
                    print("✅ Found last opened book: \(selectedBook!.name)")
                } else {
                    print("❌ Last opened book \(lastBookId) not found")
                }
            } else {
                print("📝 No last opened book recorded")
            }
        }
        
        if selectedBook == nil {
            selectedBook = books.first
            if selectedBook != nil {
                print("🎯 Using first available book: \(selectedBook!.name)")
            } else {
                print("❌ No books available at all")
            }
        }
        
        guard let book = selectedBook else {
            print("💥 No book selected - returning 'no account book'")
            return MoneyWidgetEntry(
                date: Date(),
                balance: 0,
                income: 0,
                expense: 0,
                bookName: "無帳本",
                categoryStats: [],
                budgetProgress: (spent: 0, budget: 0)
            )
        }
        
        // 獲取真實的收支數據
        let totals = databaseReader.getTotals(for: book.id)
        let balance = totals.totalIncome - totals.totalExpense
        
        // 根據配置決定是否顯示分類統計
        var categoryStats: [WidgetCategoryExpenseStat] = []
        if config?.showCategoryStats ?? true {
            categoryStats = databaseReader.getCategoryExpenseStats(for: book.id)
        }
        
        // 根據配置決定是否顯示預算進度
        var budgetProgress: (spent: Double, budget: Double) = (0, 0)
        if config?.showBudgetProgress ?? true {
            if let topCategory = categoryStats.first {
                budgetProgress = databaseReader.getBudgetProgress(
                    for: book.id,
                    categoryId: topCategory.categoryId
                )
            }
        }
        
        print("📊 Widget displaying: \(book.name), Balance: \(balance), Income: \(totals.totalIncome), Expense: \(totals.totalExpense)")
        
        return MoneyWidgetEntry(
            date: Date(),
            balance: config?.showBalance ?? true ? balance : 0,
            income: totals.totalIncome,
            expense: totals.totalExpense,
            bookName: book.name,
            categoryStats: Array(categoryStats.prefix(3)), // 只取前3個分類
            budgetProgress: budgetProgress
        )
    }
}

struct MoneyWidgetEntry: TimelineEntry {
    let date: Date
    let balance: Double
    let income: Double
    let expense: Double
    let bookName: String
    let categoryStats: [WidgetCategoryExpenseStat]
    let budgetProgress: (spent: Double, budget: Double)
}

struct MoneyWidgetEntryView: View {
    var entry: MoneyWidgetProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularWidgetView(entry: entry)
        case .accessoryRectangular:
            RectangularWidgetView(entry: entry)
        case .accessoryInline:
            InlineWidgetView(entry: entry)
        default:
            CircularWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget Views

struct CircularWidgetView: View {
    let entry: MoneyWidgetEntry
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.blue.gradient)
            
            VStack(spacing: 2) {
                Text("💰")
                    .font(.system(size: 12))
                Text(formatCurrency(entry.balance))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(entry.balance >= 0 ? .green : .red)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
        }
    }
}

struct RectangularWidgetView: View {
    let entry: MoneyWidgetEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text("💰")
                Text(entry.bookName)
                    .font(.system(size: 10, weight: .medium))
                    .lineLimit(1)
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text("餘額")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                    Text(formatCurrency(entry.balance))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(entry.balance >= 0 ? .green : .red)
                }
                
                Spacer()
                
                if entry.budgetProgress.budget > 0 {
                    VStack(alignment: .trailing, spacing: 1) {
                        Text("預算")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                        Text("\(Int((entry.budgetProgress.spent / entry.budgetProgress.budget) * 100))%")
                            .font(.system(size: 10))
                            .foregroundColor(entry.budgetProgress.spent > entry.budgetProgress.budget ? .red : .blue)
                    }
                } else {
                    VStack(alignment: .trailing, spacing: 1) {
                        Text("收入")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                        Text(formatCurrency(entry.income))
                            .font(.system(size: 10))
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding(4)
    }
}

struct InlineWidgetView: View {
    let entry: MoneyWidgetEntry
    
    var body: some View {
        HStack {
            Text("💰")
            Text(entry.bookName)
            Text("餘額: \(formatCurrency(entry.balance))")
                .foregroundColor(entry.balance >= 0 ? .green : .red)
        }
        .font(.system(size: 12))
    }
}

// MARK: - Helper Functions

private func formatCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 0
    formatter.currencySymbol = "$"
    if abs(amount) >= 10000 {
        return formatter.string(from: NSNumber(value: amount/10000)) ?? "0" + "萬"
    }
    return formatter.string(from: NSNumber(value: amount)) ?? "$0"
}

// MARK: - Widget Declaration

@main
struct MoneyWidgetExtension: Widget {
    let kind: String = "MoneyWidgetExtension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MoneyWidgetProvider()) { entry in
            MoneyWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("9歲記帳")
        .description("顯示您的當前帳本餘額、收支情況和預算進度")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

// MARK: - Previews

#Preview(as: .accessoryCircular) {
    MoneyWidgetExtension()
} timeline: {
    MoneyWidgetEntry(
        date: Date(),
        balance: 12500,
        income: 25000,
        expense: 12500,
        bookName: "我的帳本",
        categoryStats: [
            WidgetCategoryExpenseStat(categoryId: 1, totalExpense: 3000, percentage: 40),
            WidgetCategoryExpenseStat(categoryId: 2, totalExpense: 2000, percentage: 30)
        ],
        budgetProgress: (spent: 3000, budget: 5000)
    )
    MoneyWidgetEntry(
        date: Date(),
        balance: -500,
        income: 25000,
        expense: 25500,
        bookName: "我的帳本",
        categoryStats: [],
        budgetProgress: (spent: 5500, budget: 5000)
    )
}

#Preview(as: .accessoryRectangular) {
    MoneyWidgetExtension()
} timeline: {
    MoneyWidgetEntry(
        date: Date(),
        balance: 12500,
        income: 25000,
        expense: 12500,
        bookName: "我的帳本",
        categoryStats: [],
        budgetProgress: (spent: 3000, budget: 5000)
    )
}    
 