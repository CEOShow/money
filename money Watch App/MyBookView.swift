//
//  MyBookView.swift
//  money Watch App
//
//  Created by Show on 2024/5/21.
//

import SwiftUI

struct MyBookView: View {
    let accountBook: AccountBook
    @State private var expenses: [Expense] = []
    @State private var totalIncome: Double = 0
    @State private var totalExpense: Double = 0
    @State private var showingDetailView = false
    
    var body: some View {
        VStack {
            Text(accountBook.name)
                .font(.largeTitle)
                .padding()
            
            Text("幣別: \(accountBook.currency)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                VStack {
                    Text("收入")
                    Text("$\(totalIncome, specifier: "%.2f")")
                        .foregroundColor(.green)
                }
                Divider()
                VStack {
                    Text("餘額")
                    Text("$\(totalIncome - totalExpense, specifier: "%.2f")")
                        .foregroundColor(totalIncome - totalExpense >= 0 ? .blue : .red)
                }
                Divider()
                VStack {
                    Text("支出")
                    Text("$\(totalExpense, specifier: "%.2f")")
                        .foregroundColor(.red)
                }
            }
            .padding()
            

            NavigationLink(destination: ExpenseInputView(accountBook: accountBook)) {
                Text("+")
                    .font(.largeTitle)
                    .foregroundColor(.green)
                    .padding()
                    .background(Circle().fill(Color.green.opacity(0.2)))
            }
        }
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
            ExpenseDetailView(expenses: expenses)
        }
        .onAppear {
            loadExpenses()
        }
    }
    
    private func loadExpenses() {
        expenses = AccountingManager.shared.getExpenses(for: accountBook.id)
        calculateTotals()
    }
    
    private func calculateTotals() {
        totalIncome = expenses.filter { $0.income > 0 }.reduce(0) { $0 + $1.income }
        totalExpense = expenses.filter { $0.income < 0 }.reduce(0) { $0 + abs($1.income) }
    }
}


struct MyBookView_Previews: PreviewProvider {
    static var previews: some View {
        MyBookView(accountBook: AccountBook(id: 1, currency: "TWD", name: "測試帳本"))
    }
}
#Preview {
    MyBookView(accountBook: AccountBook(id: 1, currency: "TWD", name: "測試帳本"))
}
