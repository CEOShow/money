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
            VStack(spacing: 16) {
                // Header Section
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Budget Management")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        Text("Track your spending")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.top, 8)
                .padding(.horizontal)
                
                if budgets.isEmpty {
                    // Empty state design
                    VStack(spacing: 16) {
                        // Icon
                        Image(systemName: "chart.pie.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.blue.gradient)
                            .padding(.top, 20)
                        
                        VStack(spacing: 8) {
                            Text("Start setting budgets")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                            
                            Text("Set budgets for different categories\nto better control your spending")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                        }
                        
                        Button("Set your first budget") {
                            showingAddBudget = true
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.top, 8)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .stroke(.quaternary, lineWidth: 0.5)
                    }
                    .padding(.horizontal)
                } else {
                    // Budget summary statistics
                    BudgetSummaryCard(budgets: budgets, accountBook: accountBook)
                        .padding(.horizontal)
                    
                    // Budget list
                    LazyVStack(spacing: 12) {
                        ForEach(budgets) { budget in
                            BudgetRowView(budget: budget, accountBook: accountBook)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.bottom)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showingAddBudget = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.blue.gradient)
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
struct BudgetSummaryCard: View {
    let budgets: [Budget]
    let accountBook: AccountBook
    @State private var totalBudget: Double = 0
    @State private var totalSpent: Double = 0
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("This Month Overview")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Spent")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(formatCurrency(totalSpent))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(totalSpent > totalBudget ? .red : .primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total Budget")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(formatCurrency(totalBudget))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
            }
            
            // Total progress bar
            VStack(spacing: 4) {
                let percentage = totalBudget > 0 ? min(totalSpent / totalBudget, 1.0) : 0
                HStack {
                    Text("\(Int(percentage * 100))% used")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("Remaining \(formatCurrency(max(totalBudget - totalSpent, 0)))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.quaternary)
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(progressGradient(for: percentage))
                            .frame(width: geometry.size.width * percentage, height: 6)
                            .animation(.easeInOut(duration: 0.3), value: percentage)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .stroke(.quaternary, lineWidth: 0.5)
        }
        .onAppear {
            calculateTotals()
        }
    }
    
    private func progressGradient(for percentage: Double) -> LinearGradient {
        if percentage > 1.0 {
            return LinearGradient(colors: [.red, .red.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
        } else if percentage > 0.8 {
            return LinearGradient(colors: [.orange, .orange.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
        } else {
            return LinearGradient(colors: [.green, .green.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
        }
    }
    
    private func calculateTotals() {
        totalBudget = 0
        totalSpent = 0
        
        for budget in budgets {
            let progress = AccountingManager.shared.getBudgetProgress(
                for: accountBook.id,
                categoryId: budget.categoryId,
                period: budget.period
            )
            totalBudget += progress.budget
            totalSpent += progress.spent
        }
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
        VStack(spacing: 0) {
            // Top information
            HStack(alignment: .center, spacing: 12) {
                // Category icon
                ZStack {
                    Circle()
                        .fill(categoryColor.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Text(categoryColor == .orange ? "🍽️" :
                         categoryColor == .blue ? "🚗" :
                         categoryColor == .pink ? "🛍️" :
                         categoryColor == .green ? "💰" :
                         categoryColor == .purple ? "✈️" : "💰")
                        .font(.caption)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(category?.name ?? "Unknown Category")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text(budget.period.name)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatCurrency(progress.spent))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(progressPercentage > 1.0 ? .red : .primary)
                    
                    Text("/ \(formatCurrency(progress.budget))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // Progress bar area
            VStack(spacing: 8) {
                HStack {
                    Text("\(Int(progressPercentage * 100))% used")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(progressPercentage > 0.8 ? .orange : .secondary)
                    
                    Spacer()
                    
                    Text(formatCurrency(max(progress.budget - progress.spent, 0)))
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
                
                // Custom progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.quaternary)
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(progressGradient)
                            .frame(width: geometry.size.width * progressPercentage, height: 8)
                            .animation(.easeInOut(duration: 0.5), value: progressPercentage)
                        
                        // Indicator for overbudget
                        if progressPercentage > 1.0 {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.red.opacity(0.3))
                                .frame(height: 8)
                                .overlay {
                                    HStack {
                                        Spacer()
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .font(.system(size: 8))
                                            .foregroundStyle(.red)
                                            .padding(.trailing, 4)
                                    }
                                }
                        }
                    }
                }
                .frame(height: 8)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .stroke(.quaternary, lineWidth: 0.5)
        }
        .onAppear {
            updateProgress()
        }
    }
    
    private var categoryColor: Color {
        switch category {
        case .foodAndEntertainment: return .orange
        case .transportation: return .blue
        case .shopping: return .pink
        case .pocketMoney: return .green
        case .travel: return .purple
        default: return .gray
        }
    }
    
    private var progressGradient: LinearGradient {
        if progressPercentage > 1.0 {
            return LinearGradient(colors: [.red, .red.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
        } else if progressPercentage > 0.8 {
            return LinearGradient(colors: [.orange, .orange.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
        } else {
            return LinearGradient(colors: [categoryColor, categoryColor.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
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
    @State private var budgetAmount: String = "0"
    @State private var selectedPeriod: BudgetPeriod = .monthly
    @State private var showingCategoryPicker = false
    @State private var showingCalculator = false
    @State private var isIncome: Bool = false // Budget is always expense, but CalculatorView needs this parameter
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    VStack(spacing: 8) {
                        Text("Set Budget")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text("Set spending limit for category")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top)
                    
                    // Amount input
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Budget Amount")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        
                        Button(action: {
                            showingCalculator = true
                        }) {
                            HStack {
                                Text(budgetAmount)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                            .padding(12)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                                    .stroke(.quaternary, lineWidth: 0.5)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .sheet(isPresented: $showingCalculator) {
                            CalculatorView(amount: $budgetAmount, isIncome: $isIncome)
                        }
                    }
                    
                    // Category selection
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Select Category")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        
                        Button(action: {
                            showingCategoryPicker = true
                        }) {
                            HStack {
                                Text(selectedCategory.name)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                            .padding(12)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                                    .stroke(.quaternary, lineWidth: 0.5)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .sheet(isPresented: $showingCategoryPicker) {
                            CategoryView(selectedCategory: $selectedCategory)
                        }
                    }
                    
                    // Period selection
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Budget Period")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            ForEach(BudgetPeriod.allCases, id: \.self) { period in
                                Button(action: {
                                    selectedPeriod = period
                                }) {
                                    Text(period.name)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundStyle(selectedPeriod == period ? .white : .primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background {
                                            Group {
                                                if selectedPeriod == period {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(.blue.gradient)
                                                } else {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(.ultraThinMaterial)
                                                        .stroke(.quaternary, lineWidth: 0.5)
                                                }
                                            }
                                        }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    Spacer(minLength: 20)
                    
                    // Save button
                    Button("Save Budget") {
                        saveBudget()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(budgetAmount == "0" || Double(budgetAmount) == nil)
                }
                .padding()
            }
            .navigationTitle("Add Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
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

// Custom button style
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.blue.gradient)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

private func formatCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 0
    return formatter.string(from: NSNumber(value: amount)) ?? "$0"
}

#Preview {
    BudgetView(accountBook: AccountBook(id: 1, currency: "TWD", name: "Test Account Book"))
}
