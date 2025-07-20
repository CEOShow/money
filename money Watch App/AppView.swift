//
//  AppView.swift
//  money Watch App
//
//  Created by Show on 2024/8/7.
//

import SwiftUI
import WidgetKit

struct AppView: View {
    @State private var navigationPath = NavigationPath()
    @State private var hasLoadedLastBook = false
    @State private var selectedTab = 0 // 用於處理頁面導航

    var body: some View {
        if #available(watchOS 10, *) {
            NavigationStack(path: $navigationPath) {
                ContentView()
                    .environmentObject(NavigationManager(navigationPath: $navigationPath))
                    .navigationDestination(for: AccountBook.self) { book in
                        MyBookView(accountBook: book)
                    }
                    .navigationDestination(for: DeepLinkDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .onOpenURL { url in
                handleDeepLink(url: url)
            }
            .task {
                if !hasLoadedLastBook {
                    loadLastOpenedBook()
                    hasLoadedLastBook = true
                }
            }
        } else {
            NavigationStack(path: $navigationPath) {
                ContentView()
                    .environmentObject(NavigationManager(navigationPath: $navigationPath))
                    .navigationDestination(for: AccountBook.self) { book in
                        MyBookView(accountBook: book)
                    }
                    .navigationDestination(for: DeepLinkDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .onOpenURL { url in
                handleDeepLink(url: url)
            }
            .onAppear {
                if !hasLoadedLastBook {
                    loadLastOpenedBook()
                    hasLoadedLastBook = true
                }
            }
        }
    }

    private func loadLastOpenedBook() {
        if let lastBookId = AccountingManager.shared.getLastOpenedBookId(),
           let lastBook = AccountingManager.shared.getAllAccountBooks().first(where: { $0.id == lastBookId }) {
            navigationPath.append(lastBook)
        }
    }
    
    private func handleDeepLink(url: URL) {
        guard url.scheme == "money" else { return }
        
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        
        switch url.host {
        case "book":
            if pathComponents.contains("details") {
                // 跳轉到帳本詳情
                if let lastBookId = AccountingManager.shared.getLastOpenedBookId(),
                   let lastBook = AccountingManager.shared.getAllAccountBooks().first(where: { $0.id == lastBookId }) {
                    navigationPath.append(lastBook)
                }
            }
            
        case "add-expense":
            // 跳轉到快速記帳頁面
            navigationPath.append(DeepLinkDestination.addExpense)
            
        case "income":
            // 跳轉到收入記錄頁面
            navigationPath.append(DeepLinkDestination.incomeRecords)
            
        case "expense":
            // 跳轉到支出記錄頁面
            navigationPath.append(DeepLinkDestination.expenseRecords)
            
        case "budget":
            // 跳轉到預算管理頁面
            navigationPath.append(DeepLinkDestination.budgetManagement)
            
        case "categories":
            // 跳轉到分類統計頁面
            navigationPath.append(DeepLinkDestination.categoryStats)
            
        default:
            // 預設跳轉到主頁
            navigationPath = NavigationPath()
        }
    }
    
    @ViewBuilder
    private func destinationView(for destination: DeepLinkDestination) -> some View {
        // 獲取當前活躍的帳本
        let currentBook = getCurrentAccountBook()
        
        switch destination {
        case .addExpense:
            if let book = currentBook {
                QuickExpenseView(accountBook: book) {
                    // onSave 回調 - 刷新小工具
                    WidgetCenter.shared.reloadAllTimelines()
                }
            } else {
                Text("請先選擇一個帳本")
                    .foregroundColor(.gray)
            }
        case .incomeRecords:
            if let book = currentBook {
                ExpenseStatsView(accountBook: book)
            } else {
                Text("請先選擇一個帳本")
                    .foregroundColor(.gray)
            }
        case .expenseRecords:
            if let book = currentBook {
                ExpenseStatsView(accountBook: book)
            } else {
                Text("請先選擇一個帳本")
                    .foregroundColor(.gray)
            }
        case .budgetManagement:
            if let book = currentBook {
                BudgetView(accountBook: book)
            } else {
                Text("請先選擇一個帳本")
                    .foregroundColor(.gray)
            }
        case .categoryStats:
            if let book = currentBook {
                ExpenseStatsView(accountBook: book)
            } else {
                Text("請先選擇一個帳本")
                    .foregroundColor(.gray)
            }
        }
    }
    
    private func getCurrentAccountBook() -> AccountBook? {
        // 優先獲取最後打開的帳本
        if let lastBookId = AccountingManager.shared.getLastOpenedBookId(),
           let lastBook = AccountingManager.shared.getAllAccountBooks().first(where: { $0.id == lastBookId }) {
            return lastBook
        }
        
        // 如果沒有最後打開的帳本，則返回第一個可用的帳本
        let books = AccountingManager.shared.getAllAccountBooks()
        return books.first
    }
}

// MARK: - Deep Link Destinations

enum DeepLinkDestination: Hashable {
    case addExpense
    case incomeRecords
    case expenseRecords
    case budgetManagement
    case categoryStats
}

class NavigationManager: ObservableObject {
    @Binding var navigationPath: NavigationPath
    
    init(navigationPath: Binding<NavigationPath>) {
        self._navigationPath = navigationPath
    }
    
    func navigate(to book: AccountBook) {
        navigationPath.append(book)
    }
    
    func navigate(to destination: DeepLinkDestination) {
        navigationPath.append(destination)
    }
}

#Preview {
    AppView()
}
