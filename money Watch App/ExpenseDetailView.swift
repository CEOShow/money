//
//  ExpenseDetailView.swift
//  money Watch App
//
//  Created by Show on 2024/7/28.
//

import SwiftUI

struct ExpenseDetailView: View {
    let accountBook: AccountBook
    @State private var expenses: [Expense] = []
    @State private var editingExpense: Expense?
    @State private var showingEditView = false
    @State private var refreshID = UUID()
    
    var body: some View {
        List {
            ForEach(expenses) { expense in
                ExpenseRow(expense: expense, expenses: $expenses, editAction: {
                    editingExpense = expense
                    showingEditView = true
                }, deleteAction: {
                    deleteExpense(expense)
                })
                .listRowInsets(EdgeInsets())
                .id(refreshID)
            }
        }
        .navigationTitle("詳細明細")
        .onAppear {
            loadExpenses()
        }
        .sheet(isPresented: $showingEditView) {
            if let expense = editingExpense {
                ExpenseInputView(accountBook: accountBook, editingExpense: expense, onSave: { updatedExpense in
                    if let index = expenses.firstIndex(where: { $0.id == updatedExpense.id }) {
                        expenses[index] = updatedExpense
                    }
                    showingEditView = false
                    loadExpenses()
                    refreshID = UUID()
                })
            }
        }
    }
    
    private func loadExpenses() {
        expenses = AccountingManager.shared.getExpenses(for: accountBook.id)
    }
    
    private func deleteExpense(_ expense: Expense) {
        if AccountingManager.shared.deleteExpense(id: expense.id) {
            expenses.removeAll { $0.id == expense.id }
            refreshID = UUID()
        }
    }
}

struct ExpenseRow: View {
    let expense: Expense
    @Binding var expenses: [Expense]
    let editAction: () -> Void
    let deleteAction: () -> Void
    @State private var offset: CGFloat = 0
    @State private var showingDeleteConfirmation = false

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                Button(action: editAction) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.gray)
                }
                
                Button(action: {
                    withAnimation {
                        self.showingDeleteConfirmation = true
                    }
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.red)
                }
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text(expense.note)
                        .font(.headline)
                    Text(formatDate(expense.date))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text(formatBalance(expense.income))
                    .font(.headline)
                    .foregroundColor(expense.income >= 0 ? .green : .red)
            }
            .padding()
            .background(Color.white) 
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.width < 0 {
                            self.offset = max(value.translation.width, -120)
                        }
                    }
                    .onEnded { value in
                        if value.translation.width < -50 {
                            withAnimation {
                                self.offset = -120
                            }
                        } else {
                            withAnimation {
                                self.offset = 0
                            }
                        }
                    }
            )
        }
        .alert(isPresented: $showingDeleteConfirmation) {
            Alert(
                title: Text("確認刪除"),
                message: Text("您確定要刪除這筆記錄嗎？"),
                primaryButton: .destructive(Text("刪除")) {
                    deleteAction()
                },
                secondaryButton: .cancel {
                    withAnimation {
                        self.offset = 0
                    }
                }
            )
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatBalance(_ balance: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        let number = NSNumber(value: abs(balance))
        let formattedString = formatter.string(from: number) ?? "0"
        
        return balance < 0 ? "-$\(formattedString)" : "$\(formattedString)"
    }
}

struct ExpenseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseDetailView(accountBook: AccountBook(id: 1, currency: "TWD", name: "測試帳本"))
    }
}
