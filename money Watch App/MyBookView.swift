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
    @State private var showingExpenseInput = false
    @State private var showingStatsView = false
    @State private var showingBudgetView = false
    @State private var showingVoiceExpense = false
    @State private var showingQuickExpense = false
    @State private var displayMode: DisplayMode = .total
    @StateObject private var themeManager = ThemeManager.shared
    
    enum DisplayMode: CaseIterable {
        case total, income, expense
        
        func calculateAmount(income: Double, expense: Double) -> Double {
            switch self {
            case .total:
                return income - expense
            case .income:
                return income
            case .expense:
                return expense
            }
        }
        
        var title: String {
            switch self {
            case .total:
                return NSLocalizedString("Balance", comment: "")
            case .income:
                return NSLocalizedString("Income", comment: "")
            case .expense:
                return NSLocalizedString("Expense", comment: "")
            }
        }
        
        func textColor(income: Double, expense: Double) -> Color {
            switch self {
            case .total:
                return (income - expense) >= 0 ? .green : .red
            case .income:
                return .green
            case .expense:
                return .red
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                Text(accountBook.name)
                    .font(.headline)
                    .padding(.bottom, 2)
                Text(NSLocalizedString("Currency", comment: "") + ": \(accountBook.currency)")
                    .font(.caption)
                    .foregroundColor(.gray)
                VStack {
                    Text(displayMode.title)
                        .font(.caption2)
                    AutoSizingText(
                        text: formatBalance(displayMode.calculateAmount(income: totalIncome, expense: totalExpense)),
                        fontSize: 28,
                        color: displayMode.textColor(income: totalIncome, expense: totalExpense)
                    )
                    .frame(height: 30)
                }
                .padding(.vertical, 2)
                
                // 支出分析按鈕移動到餘額下面
                Button(action: {
                    showingStatsView = true
                }) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 8)
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                // 第一排按鈕
                HStack {
                    Button(action: {
                        let currentIndex = DisplayMode.allCases.firstIndex(of: displayMode)!
                        let nextIndex = (currentIndex + 1) % DisplayMode.allCases.count
                        displayMode = DisplayMode.allCases[nextIndex]
                    }) {
                        Image(systemName: "gear")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    Button(action: {
                        showingVoiceExpense = true
                    }) {
                        Image(systemName: "mic")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // 第二排按鈕
                HStack {
                    Button(action: {
                        showingQuickExpense = true
                    }) {
                        Image(systemName: "bolt")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    Button(action: {
                        showingExpenseInput = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .padding()
        .background(
            themeManager.currentBackground()
        )
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    showingDetailView = true
                }) {
                    Image(systemName: "list.bullet")
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    showingBudgetView = true
                }) {
                    Image(systemName: "creditcard")
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .sheet(isPresented: $showingDetailView, onDismiss: {
            updateTotals()
        }) {
            ExpenseDetailView(accountBook: accountBook)
        }
        .sheet(isPresented: $showingExpenseInput, onDismiss: {
            updateTotals()
        }) {
            ExpenseInputView(accountBook: accountBook)
        }
        .sheet(isPresented: $showingStatsView) {
            ExpenseStatsView(accountBook: accountBook)
        }
        .sheet(isPresented: $showingBudgetView) {
            BudgetView(accountBook: accountBook)
        }
        .sheet(isPresented: $showingVoiceExpense) {
            VoiceExpenseView(accountBook: accountBook, onSave: {
                updateTotals()
            })
        }
        .sheet(isPresented: $showingQuickExpense) {
            QuickExpenseView(accountBook: accountBook, onSave: {
                updateTotals()
            })
        }
        .onAppear {
            updateTotals()
            AccountingManager.shared.saveLastOpenedBook(id: accountBook.id)
        }
    }
    
    private func updateTotals() {
        let totals = AccountingManager.shared.getTotals(for: accountBook.id)
        totalIncome = totals.totalIncome
        totalExpense = totals.totalExpense
    }
    
    private func formatBalance(_ balance: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        let number = NSNumber(value: abs(balance))
        let formattedString = formatter.string(from: number) ?? "$0"
        
        return balance < 0 ? "-\(formattedString)" : formattedString
    }
}

struct AutoSizingText: View {
    let text: String
    var fontSize: CGFloat = 28
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            Text(text)
                .font(.system(size: fontSize))
                .foregroundColor(color)
                .minimumScaleFactor(0.1)
                .lineLimit(1)
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        }
    }
}

struct MyBookView_Previews: PreviewProvider {
    static var previews: some View {
        MyBookView(accountBook: AccountBook(id: 1, currency: "TWD", name: "測試帳本"))
    }
}
