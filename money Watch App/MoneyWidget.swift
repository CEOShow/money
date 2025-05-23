import WidgetKit
import SwiftUI

struct MoneyWidget: Widget {
    let kind: String = "MoneyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MoneyWidgetProvider()) { entry in
            MoneyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("記帳小工具")
        .description("顯示您的當前帳本餘額和收支情況")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct MoneyWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> MoneyWidgetEntry {
        MoneyWidgetEntry(date: Date(), balance: 0, income: 0, expense: 0, bookName: "我的帳本")
    }

    func getSnapshot(in context: Context, completion: @escaping (MoneyWidgetEntry) -> ()) {
        let entry = getLatestEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MoneyWidgetEntry>) -> ()) {
        let currentDate = Date()
        let entry = getLatestEntry()
        
        // 更新頻率設為每小時
        let refreshDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }
    
    private func getLatestEntry() -> MoneyWidgetEntry {
        let accountingManager = AccountingManager.shared
        let books = accountingManager.getAllAccountBooks()
        
        guard let lastBookId = accountingManager.getLastOpenedBookId(),
              let book = books.first(where: { $0.id == lastBookId }) else {
            return MoneyWidgetEntry(date: Date(), balance: 0, income: 0, expense: 0, bookName: "無帳本")
        }
        
        let totals = accountingManager.getTotals(for: book.id)
        let balance = totals.totalIncome - totals.totalExpense
        
        return MoneyWidgetEntry(
            date: Date(),
            balance: balance,
            income: totals.totalIncome,
            expense: totals.totalExpense,
            bookName: book.name
        )
    }
}

struct MoneyWidgetEntry: TimelineEntry {
    let date: Date
    let balance: Double
    let income: Double
    let expense: Double
    let bookName: String
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
    if abs(amount) >= 10000 {
        return formatter.string(from: NSNumber(value: amount/10000)) ?? "0" + "萬"
    }
    return formatter.string(from: NSNumber(value: amount)) ?? "$0"
}

#Preview(as: .accessoryCircular) {
    MoneyWidget()
} timeline: {
    MoneyWidgetEntry(date: Date(), balance: 12500, income: 25000, expense: 12500, bookName: "我的帳本")
    MoneyWidgetEntry(date: Date(), balance: -500, income: 25000, expense: 25500, bookName: "我的帳本")
}

#Preview(as: .accessoryRectangular) {
    MoneyWidget()
} timeline: {
    MoneyWidgetEntry(date: Date(), balance: 12500, income: 25000, expense: 12500, bookName: "我的帳本")
} 