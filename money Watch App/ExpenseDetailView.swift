//
//  ExpenseDetailView.swift
//  money Watch App
//
//  Created by Show on 2024/7/28.
//

import SwiftUI

struct ExpenseDetailView: View {
    let expenses: [Expense]
    
    var body: some View {
        List(expenses) { expense in
            ExpenseRow(expense: expense)
        }
        .navigationTitle("詳細明細")
    }
}

struct ExpenseRow: View {
    let expense: Expense
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(expense.note)
                    .font(.headline)
                Text(formatDate(expense.date))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(formatCurrency(expense.income))
                .font(.headline)
                .foregroundColor(expense.income >= 0 ? .green : .red)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "TWD"  // 您可能想要根據帳本的幣別來設定這個
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}


#Preview {
    ExpenseDetailView(expenses: [
        Expense(id: 1, bookId: 101, income: 2500, date: Date(), note: "Salary", categoryId: 1),
        Expense(id: 2, bookId: 102, income: -150, date: Date(), note: "Groceries", categoryId: 2)
    ])
}
