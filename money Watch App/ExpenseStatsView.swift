//
//  ExpenseStatsView.swift
//  money Watch App
//
//  Created by Show on 2024/12/19.
//

import SwiftUI
import UIKit

@available(watchOS 10.0, *)
struct ExpenseStatsView: View {
    let accountBook: AccountBook
    @State private var categoryStats: [CategoryExpenseStat] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("支出統計")
                    .font(.headline)
                    .padding(.top)
                
                if categoryStats.isEmpty {
                    Text("暫無支出記錄")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    // 圓餅圖
                    PieChartView(stats: categoryStats)
                        .frame(height: 120)
                        .padding(.horizontal)
                    
                    // 統計列表
                    VStack(spacing: 8) {
                        ForEach(categoryStats, id: \.categoryId) { stat in
                            CategoryStatRow(stat: stat)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("支出分析")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadStats()
        }
    }
    
    private func loadStats() {
        categoryStats = AccountingManager.shared.getCategoryExpenseStats(for: accountBook.id)
    }
}

@available(watchOS 10.0, *)
struct CategoryStatRow: View {
    let stat: CategoryExpenseStat
    
    private var category: Category? {
        Category(rawValue: stat.categoryId)
    }
    
    var body: some View {
        HStack {
            // 分類標示
            Circle()
                .fill(colorForCategory(stat.categoryId))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category?.name ?? "未知分類")
                    .font(.caption)
                    .fontWeight(.medium)
                Text(formatCurrency(stat.totalExpense))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 百分比條
            HStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(colorForCategory(stat.categoryId))
                    .frame(width: max(4, stat.percentage * 0.4), height: 8)
                
                Text("\(Int(stat.percentage))%")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .frame(minWidth: 24, alignment: .trailing)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(6)
    }
}

@available(watchOS 10.0, *)
struct PieChartView: View {
    let stats: [CategoryExpenseStat]
    
    var body: some View {
        ZStack {
            ForEach(Array(stats.enumerated()), id: \.offset) { index, stat in
                PieSlice(
                    startAngle: startAngle(for: index),
                    endAngle: endAngle(for: index),
                    color: colorForCategory(stat.categoryId)
                )
            }
            
            // 中央顯示總支出
            VStack(spacing: 2) {
                Text("總支出")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(formatCurrency(stats.reduce(0) { $0 + $1.totalExpense }))
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
    }
    
    private func startAngle(for index: Int) -> Angle {
        let percentagesBeforeIndex = stats[0..<index].reduce(0) { $0 + $1.percentage }
        return Angle(degrees: percentagesBeforeIndex * 3.6 - 90)
    }
    
    private func endAngle(for index: Int) -> Angle {
        let percentagesUpToIndex = stats[0...index].reduce(0) { $0 + $1.percentage }
        return Angle(degrees: percentagesUpToIndex * 3.6 - 90)
    }
}

@available(watchOS 10.0, *)
struct PieSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    
    var body: some View {
        Path { path in
            let center = CGPoint(x: 60, y: 60)
            path.move(to: center)
            path.addArc(center: center, radius: 50, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            path.closeSubpath()
        }
        .fill(color)
    }
}

private func colorForCategory(_ categoryId: Int) -> Color {
    let colors: [Color] = [.blue, .green, .orange, .red, .purple, .pink, .yellow]
    return colors[categoryId % colors.count]
}

private func formatCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 0
    return formatter.string(from: NSNumber(value: amount)) ?? "$0"
}

#Preview {
    ExpenseStatsView(accountBook: AccountBook(id: 1, currency: "TWD", name: "測試帳本"))
} 