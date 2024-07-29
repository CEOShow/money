//
//  MyBookView.swift
//  money Watch App
//
//  Created by Show on 2024/5/21.
//

import SwiftUI

struct MyBookView: View {
    let accountBook: AccountBook
    @State private var totalIncome: Double = 0
    @State private var totalExpense: Double = 0
    @State private var showingDetailView = false

    var body: some View {
        VStack {
            Text(accountBook.name)
                .font(.headline)
                .padding(.bottom, 5)

            Text("幣別: \(accountBook.currency)")
                .font(.caption)
                .foregroundColor(.gray)

            VStack {
                Text("餘額")
                    .font(.caption2)
                Text("$\(totalIncome - totalExpense, specifier: "%.2f")")
                    .font(.title2)
                    .foregroundColor(totalIncome - totalExpense >= 0 ? .blue : .red)
            }
            .padding(.vertical, 10)

            NavigationLink(destination: ExpenseInputView(accountBook: accountBook)) {
                Text("+")
                    .font(.title)
                    .foregroundColor(.green)
                    .padding()
                    .background(Circle().fill(Color.green.opacity(0.2)))
            }
            .padding(.top, 5)
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: {
                    showingDetailView = true
                }) {
                    Image(systemName: "list.bullet")
                }
            }
        }
        .sheet(isPresented: $showingDetailView) {
            ExpenseDetailView(accountBook: accountBook)
        }
        .onAppear {
            updateTotals()
        }
    }

    private func updateTotals() {
        let totals = AccountingManager.shared.getTotals(for: accountBook.id)
        totalIncome = totals.totalIncome
        totalExpense = totals.totalExpense
    }
}

struct MyBookView_Previews: PreviewProvider {
    static var previews: some View {
        MyBookView(accountBook: AccountBook(id: 1, currency: "TWD", name: "測試帳本"))
    }
}
