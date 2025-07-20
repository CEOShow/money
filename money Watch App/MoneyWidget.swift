import WidgetKit
import SwiftUI

struct MoneyWidget: Widget {
    let kind: String = "MoneyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MoneyWidgetProvider()) { entry in
            MoneyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("記帳小工具")
        .description("顯示您的當前帳本餘額、收支情況和預算進度")
        #if os(iOS)
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryCircular, .accessoryRectangular, .accessoryInline])
        #else
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
        #endif
    }
}

struct MoneyWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> MoneyWidgetEntry {
        MoneyWidgetEntry(
            date: Date(),
            balance: 12500,
            income: 25000,
            expense: 12500,
            bookName: "我的帳本",
            categoryStats: [
                CategoryExpenseStat(categoryId: 1, totalExpense: 3000, percentage: 40),
                CategoryExpenseStat(categoryId: 2, totalExpense: 2000, percentage: 30),
                CategoryExpenseStat(categoryId: 3, totalExpense: 1500, percentage: 20)
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
        
        // 根據用戶配置和小工具尺寸調整更新頻率
        let refreshInterval: TimeInterval
        
        // 首先檢查用戶配置
        if let config = MoneyWidgetConfiguration.load(), config.autoRefreshEnabled {
            refreshInterval = config.refreshInterval.timeInterval
        } else {
            // 如果沒有配置或自動更新關閉，使用預設頻率
            #if os(iOS)
            switch context.family {
            case .systemSmall, .systemMedium, .systemLarge:
                refreshInterval = 30 * 60 // 30分鐘
            default:
                refreshInterval = 60 * 60 // 1小時
            }
            #else
            refreshInterval = 60 * 60 // 1小時 (Apple Watch)
            #endif
        }
        
        let refreshDate = Calendar.current.date(byAdding: .second, value: Int(refreshInterval), to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }
    
    private func getLatestEntry() -> MoneyWidgetEntry {
        let accountingManager = AccountingManager.shared
        let books = accountingManager.getAllAccountBooks()
        
        // 讀取用戶配置
        let config = MoneyWidgetConfiguration.load()
        
        // 根據配置選擇帳本
        var selectedBook: AccountBook?
        if let configBookId = config?.selectedBookId,
           let book = books.first(where: { $0.id == configBookId }) {
            selectedBook = book
        } else if let lastBookId = accountingManager.getLastOpenedBookId(),
                  let book = books.first(where: { $0.id == lastBookId }) {
            selectedBook = book
        } else {
            selectedBook = books.first
        }
        
        guard let book = selectedBook else {
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
        
        let totals = accountingManager.getTotals(for: book.id)
        let balance = totals.totalIncome - totals.totalExpense
        
        // 根據配置決定是否顯示分類統計
        var categoryStats: [CategoryExpenseStat] = []
        if config?.showCategoryStats ?? true {
            categoryStats = accountingManager.getCategoryExpenseStats(for: book.id)
        }
        
        // 根據配置決定是否顯示預算進度
        var budgetProgress: (spent: Double, budget: Double) = (0, 0)
        if config?.showBudgetProgress ?? true {
            if let topCategory = categoryStats.first {
                budgetProgress = accountingManager.getBudgetProgress(
                    for: book.id,
                    categoryId: topCategory.categoryId,
                    period: .monthly
                )
            }
        }
        
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
    let categoryStats: [CategoryExpenseStat]
    let budgetProgress: (spent: Double, budget: Double)
}

struct MoneyWidgetEntryView: View {
    var entry: MoneyWidgetProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        #if os(iOS)
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        #endif
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

// MARK: - iOS Widget Views

#if os(iOS)
struct SmallWidgetView: View {
    let entry: MoneyWidgetEntry
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "wallet.pass")
                    .foregroundStyle(.blue.gradient)
                    .font(.title3)
                Text(entry.bookName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                Spacer()
            }
            
            VStack(spacing: 4) {
                Text("餘額")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(formatCurrency(entry.balance))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(entry.balance >= 0 ? .green.gradient : .red.gradient)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            
            if entry.budgetProgress.budget > 0 {
                VStack(spacing: 2) {
                    HStack {
                        Text("本月預算")
                        Spacer()
                        Text("\(Int((entry.budgetProgress.spent / entry.budgetProgress.budget) * 100))%")
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    
                    ProgressView(value: entry.budgetProgress.spent, total: entry.budgetProgress.budget)
                        .tint(entry.budgetProgress.spent > entry.budgetProgress.budget ? 
                              .red.gradient : .blue.gradient)
                        .background(.gray.opacity(0.2))
                        .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .widgetURL(URL(string: "money://book/\(entry.bookName)"))
    }
}

struct MediumWidgetView: View {
    let entry: MoneyWidgetEntry
    
    var body: some View {
        VStack(spacing: 12) {
            // 標題行 - 可點擊跳轉到帳本詳情
            Link(destination: URL(string: "money://book/details")!) {
                HStack {
                    Image(systemName: "wallet.pass")
                        .foregroundStyle(.blue.gradient)
                        .font(.title2)
                    Text(entry.bookName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                    Text(DateFormatter.mediumDate.string(from: entry.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
            
            // 收支情況
            HStack(spacing: 16) {
                // 收入 - 點擊查看收入記錄
                Link(destination: URL(string: "money://income")!) {
                    FinancialSummaryCard(
                        title: "收入",
                        amount: entry.income,
                        color: .green,
                        icon: "arrow.up.circle.fill"
                    )
                }
                .buttonStyle(.plain)
                
                // 支出 - 點擊查看支出記錄
                Link(destination: URL(string: "money://expense")!) {
                    FinancialSummaryCard(
                        title: "支出",
                        amount: entry.expense,
                        color: .red,
                        icon: "arrow.down.circle.fill"
                    )
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                // 餘額顯示
                VStack(alignment: .trailing, spacing: 4) {
                    Text("餘額")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatCurrency(entry.balance))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(entry.balance >= 0 ? .green.gradient : .red.gradient)
                }
            }
            
            // 預算進度 - 點擊跳轉到預算設定
            if entry.budgetProgress.budget > 0 {
                Link(destination: URL(string: "money://budget")!) {
                    VStack(spacing: 6) {
                        HStack {
                            Text("本月預算進度")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(formatCurrency(entry.budgetProgress.spent)) / \(formatCurrency(entry.budgetProgress.budget))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(entry.budgetProgress.spent > entry.budgetProgress.budget ? 
                                      .red.gradient : .blue.gradient)
                                .frame(width: min(CGFloat(entry.budgetProgress.spent / entry.budgetProgress.budget), 1.0) * 200, height: 8)
                                .animation(.easeInOut(duration: 0.5), value: entry.budgetProgress.spent)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
        )
    }
}

struct LargeWidgetView: View {
    let entry: MoneyWidgetEntry
    
    var body: some View {
        VStack(spacing: 16) {
            // 標題和日期 - 點擊跳轉到帳本詳情
            Link(destination: URL(string: "money://book/details")!) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "wallet.pass")
                                .foregroundStyle(.blue.gradient)
                                .font(.title)
                            Text(entry.bookName)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        Text(DateFormatter.longDate.string(from: entry.date))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    // 添加快速記帳按鈕
                    Link(destination: URL(string: "money://add-expense")!) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue.gradient)
                            .font(.title)
                            .background(
                                Circle()
                                    .fill(.white)
                                    .shadow(color: .blue.opacity(0.3), radius: 4)
                            )
                    }
                }
            }
            .buttonStyle(.plain)
            
            // 財務總覽
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    Link(destination: URL(string: "money://income")!) {
                        EnhancedFinancialCard(
                            title: "收入", 
                            amount: entry.income, 
                            color: .green, 
                            icon: "arrow.up.circle.fill"
                        )
                    }
                    .buttonStyle(.plain)
                    
                    Link(destination: URL(string: "money://expense")!) {
                        EnhancedFinancialCard(
                            title: "支出", 
                            amount: entry.expense, 
                            color: .red, 
                            icon: "arrow.down.circle.fill"
                        )
                    }
                    .buttonStyle(.plain)
                }
                
                // 餘額卡片
                VStack(spacing: 8) {
                    Text("目前餘額")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(formatCurrency(entry.balance))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(entry.balance >= 0 ? .green.gradient : .red.gradient)
                        .contentTransition(.numericText())
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(entry.balance >= 0 ? 
                              .green.opacity(0.1).gradient : .red.opacity(0.1).gradient)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(entry.balance >= 0 ? .green.opacity(0.3) : .red.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            
            // 支出分類統計 - 點擊跳轉到分類統計頁面
            if !entry.categoryStats.isEmpty {
                Link(destination: URL(string: "money://categories")!) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("支出分類")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        
                        ForEach(Array(entry.categoryStats.prefix(3).enumerated()), id: \.element.categoryId) { index, stat in
                            EnhancedCategoryStatRow(stat: stat, index: index)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.gray.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.gray.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
            
            // 預算進度 - 點擊跳轉到預算管理
            if entry.budgetProgress.budget > 0 {
                Link(destination: URL(string: "money://budget")!) {
                    EnhancedBudgetProgressView(budgetProgress: entry.budgetProgress)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Enhanced Components

struct FinancialSummaryCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color.gradient)
                    .font(.title3)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(formatCurrency(amount))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(color.gradient)
        }
    }
}

struct EnhancedFinancialCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color.gradient)
                    .font(.title2)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            Text(formatCurrency(amount))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(color.gradient)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentTransition(.numericText())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1).gradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct EnhancedCategoryStatRow: View {
    let stat: CategoryExpenseStat
    let index: Int
    
    var body: some View {
        HStack {
            Circle()
                .fill(getCategoryColor(for: stat.categoryId).gradient)
                .frame(width: 8, height: 8)
            
            Text(getCategoryName(for: stat.categoryId))
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatCurrency(stat.totalExpense))
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("\(String(format: "%.1f", stat.percentage))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
        .animation(.easeInOut(duration: 0.3).delay(Double(index) * 0.1), value: stat.totalExpense)
    }
}

struct EnhancedBudgetProgressView: View {
    let budgetProgress: (spent: Double, budget: Double)
    
    var progressPercentage: Double {
        budgetProgress.budget > 0 ? budgetProgress.spent / budgetProgress.budget : 0
    }
    
    var isOverBudget: Bool {
        progressPercentage > 1.0
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("本月預算")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(Int(progressPercentage * 100))%")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(isOverBudget ? .red.gradient : .blue.gradient)
            }
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray.opacity(0.2))
                    .frame(height: 12)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(isOverBudget ? .red.gradient : .blue.gradient)
                    .frame(width: min(CGFloat(progressPercentage), 1.0) * 280, height: 12)
                    .animation(.easeInOut(duration: 0.8), value: progressPercentage)
            }
            
            HStack {
                Text("已使用: \(formatCurrency(budgetProgress.spent))")
                Spacer()
                Text("預算: \(formatCurrency(budgetProgress.budget))")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isOverBudget ? .red.opacity(0.1).gradient : .blue.opacity(0.1).gradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isOverBudget ? .red.opacity(0.3) : .blue.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

private func getCategoryColor(for categoryId: Int) -> Color {
    let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .yellow]
    return colors[categoryId % colors.count]
}

private func getCategoryName(for categoryId: Int) -> String {
    guard let category = Category(rawValue: categoryId) else {
        return "其他"
    }
    return category.name
}

extension DateFormatter {
    static let mediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    static let longDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}
#endif

// MARK: - Apple Watch Widget Views (保持原有實現)

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

// MARK: - Previews

#Preview(as: .accessoryCircular) {
    MoneyWidget()
} timeline: {
    MoneyWidgetEntry(
        date: Date(),
        balance: 12500,
        income: 25000,
        expense: 12500,
        bookName: "我的帳本",
        categoryStats: [
            CategoryExpenseStat(categoryId: 1, totalExpense: 3000, percentage: 40),
            CategoryExpenseStat(categoryId: 2, totalExpense: 2000, percentage: 30)
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

#if os(iOS)
#Preview(as: .systemSmall) {
    MoneyWidget()
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

#Preview(as: .systemMedium) {
    MoneyWidget()
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

#Preview(as: .systemLarge) {
    MoneyWidget()
} timeline: {
    MoneyWidgetEntry(
        date: Date(),
        balance: 12500,
        income: 25000,
        expense: 12500,
        bookName: "我的帳本",
        categoryStats: [
            CategoryExpenseStat(categoryId: 1, totalExpense: 3000, percentage: 40),
            CategoryExpenseStat(categoryId: 2, totalExpense: 2000, percentage: 30),
            CategoryExpenseStat(categoryId: 3, totalExpense: 1500, percentage: 20)
        ],
        budgetProgress: (spent: 3000, budget: 5000)
    )
}
#endif

#Preview(as: .accessoryRectangular) {
    MoneyWidget()
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