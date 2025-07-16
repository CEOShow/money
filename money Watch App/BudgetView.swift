//
//  BudgetView.swift
//  money Watch App
//
//  Created by Show on 2024/12/19.
//

import SwiftUI
import UIKit

@available(watchOS 10.0, *)
struct BudgetView: View {
    let accountBook: AccountBook
    @State private var budgets: [Budget] = []
    @State private var showingAddBudget = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("預算管理")
                    .font(.headline)
                    .padding(.top)
                
                if budgets.isEmpty {
                    VStack(spacing: 8) {
                        Text("尚未設定任何預算")
                            .foregroundColor(.gray)
                        Button("設定第一個預算") {
                            showingAddBudget = true
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding()
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(budgets) { budget in
                            BudgetRowView(budget: budget, accountBook: accountBook)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showingAddBudget = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showingAddBudget) {
            AddBudgetView(accountBook: accountBook, onSave: {
                loadBudgets()
            })
        }
        .onAppear {
            loadBudgets()
        }
    }
    
    private func loadBudgets() {
        budgets = AccountingManager.shared.getBudgets(for: accountBook.id)
    }
}

@available(watchOS 10.0, *)
struct BudgetRowView: View {
    let budget: Budget
    let accountBook: AccountBook
    @State private var progress: (spent: Double, budget: Double) = (0, 0)
    
    private var category: Category? {
        Category(rawValue: budget.categoryId)
    }
    
    private var progressPercentage: Double {
        guard progress.budget > 0 else { return 0 }
        return min(progress.spent / progress.budget, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(category?.name ?? "未知分類")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text(budget.period.name)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatCurrency(progress.budget))
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text("預算")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // 進度條
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("已花費: \(formatCurrency(progress.spent))")
                        .font(.caption2)
                        .foregroundColor(progressPercentage > 0.8 ? .red : .primary)
                    Spacer()
                    Text("\(Int(progressPercentage * 100))%")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(progressPercentage > 1.0 ? .red : .primary)
                }
                
                ProgressView(value: progressPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                    .scaleEffect(y: 1.5)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
        .onAppear {
            updateProgress()
        }
    }
    
    private var progressColor: Color {
        if progressPercentage > 1.0 {
            return .red
        } else if progressPercentage > 0.8 {
            return .orange
        } else {
            return .green
        }
    }
    
    private func updateProgress() {
        progress = AccountingManager.shared.getBudgetProgress(
            for: accountBook.id,
            categoryId: budget.categoryId,
            period: budget.period
        )
    }
}

@available(watchOS 10.0, *)
struct AddBudgetView: View {
    let accountBook: AccountBook
    let onSave: () -> Void
    
    @State private var selectedCategory: Category = .foodAndEntertainment
    @State private var budgetAmount: String = ""
    @State private var selectedPeriod: BudgetPeriod = .monthly
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Text("設定預算")
                        .font(.headline)
                        .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("分類")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("分類", selection: $selectedCategory) {
                            ForEach(Category.allCases, id: \.self) { category in
                                Text(category.name)
                                    .tag(category)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 100)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("預算金額")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("輸入金額", text: $budgetAmount)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(6)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("週期")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // 使用按鈕網格代替分段控制器（適合 watchOS）
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            ForEach(BudgetPeriod.allCases, id: \.self) { period in
                                Button(action: {
                                    selectedPeriod = period
                                }) {
                                    Text(period.name)
                                        .font(.caption)
                                        .foregroundColor(selectedPeriod == period ? .white : .primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(selectedPeriod == period ? Color.blue : Color.gray.opacity(0.2))
                                        .cornerRadius(6)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    Spacer(minLength: 20)
                    
                    Button("儲存預算") {
                        saveBudget()
                    }
                    .disabled(budgetAmount.isEmpty || Double(budgetAmount) == nil)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(budgetAmount.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("新增預算")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveBudget() {
        guard let amount = Double(budgetAmount), amount > 0 else { return }
        
        let success = AccountingManager.shared.saveBudget(
            bookId: accountBook.id,
            categoryId: selectedCategory.rawValue,
            amount: amount,
            period: selectedPeriod
        )
        
        if success {
            onSave()
            dismiss()
        }
    }
}

private func formatCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 0
    return formatter.string(from: NSNumber(value: amount)) ?? "$0"
}

#Preview {
    BudgetView(accountBook: AccountBook(id: 1, currency: "TWD", name: "測試帳本"))
} 