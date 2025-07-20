//
//  WidgetConfigurationView.swift
//  money Watch App
//
//  Created by AI Assistant on 2024/12/20.
//

import SwiftUI
import WidgetKit

@available(watchOS 10.0, *)
struct WidgetConfigurationView: View {
    @State private var accountBooks: [AccountBook] = []
    @State private var selectedBookId: Int?
    @State private var showBalanceInWidget = true
    @State private var showBudgetProgress = true
    @State private var showCategoryStats = true
    @State private var autoRefreshEnabled = true
    @State private var refreshInterval: RefreshInterval = .thirtyMinutes
    
    private let widgetConfigKey = "WidgetConfiguration"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 標題
                Text("小工具設定")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // 帳本選擇
                VStack(alignment: .leading, spacing: 8) {
                    Text("顯示帳本")
                        .font(.headline)
                    
                    if accountBooks.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "book.circle")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            
                            Text("還沒有帳本")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("請先在主應用中創建一個帳本，然後回到這裡配置小工具。")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("重新載入") {
                                loadAccountBooks()
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    } else {
                        // 當前選擇的帳本顯示
                        if let selectedId = selectedBookId,
                           let selectedBook = accountBooks.first(where: { $0.id == selectedId }) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("目前選擇的帳本")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                NavigationLink(destination: BookSelectionView(
                                    accountBooks: accountBooks,
                                    selectedBookId: $selectedBookId
                                )) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(selectedBook.name)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Text("貨幣：\(selectedBook.currency)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Text("更改")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        } else {
                            // 沒有選擇時的狀態
                            NavigationLink(destination: BookSelectionView(
                                accountBooks: accountBooks,
                                selectedBookId: $selectedBookId
                            )) {
                                HStack {
                                    Text("選擇帳本")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("請選擇")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.horizontal)
                
                // 顯示內容選項
                VStack(alignment: .leading, spacing: 12) {
                    Text("顯示內容")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 8) {
                        SettingToggleRow(
                            title: "顯示餘額",
                            description: "在小工具中顯示帳本餘額",
                            isOn: $showBalanceInWidget,
                            icon: "dollarsign.circle"
                        )
                        
                        SettingToggleRow(
                            title: "顯示預算進度",
                            description: "顯示當前月份的預算使用情況",
                            isOn: $showBudgetProgress,
                            icon: "chart.pie"
                        )
                        
                        SettingToggleRow(
                            title: "顯示分類統計",
                            description: "顯示支出分類統計資訊",
                            isOn: $showCategoryStats,
                            icon: "chart.bar"
                        )
                    }
                }
                
                // 更新設定
                VStack(alignment: .leading, spacing: 12) {
                    Text("更新設定")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 8) {
                        SettingToggleRow(
                            title: "自動更新",
                            description: "定期自動更新小工具內容",
                            isOn: $autoRefreshEnabled,
                            icon: "arrow.clockwise"
                        )
                        
                        if autoRefreshEnabled {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("更新頻率")
                                    .font(.subheadline)
                                    .padding(.horizontal)
                                
                                Picker("更新頻率", selection: $refreshInterval) {
                                    ForEach(RefreshInterval.allCases, id: \.self) { interval in
                                        Text(interval.displayName).tag(interval)
                                    }
                                }
                                .pickerStyle(.navigationLink)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                
                // 重新整理小工具按鈕
                Button(action: refreshAllWidgets) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("立即更新所有小工具")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // 說明文字
                VStack(alignment: .leading, spacing: 8) {
                    Text("小工具說明")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Text("• 小工具會根據您選擇的帳本顯示最新的財務資訊\n• 在iOS設備上支援小、中、大三種尺寸\n• 點擊小工具的不同區域可跳轉到對應功能頁面\n• 建議開啟自動更新以獲得最新資訊")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                Spacer(minLength: 20)
            }
        }
        .onAppear {
            loadAccountBooks()
            loadConfiguration()
        }
        .onChange(of: selectedBookId) { _ in saveConfiguration() }
        .onChange(of: showBalanceInWidget) { _ in saveConfiguration() }
        .onChange(of: showBudgetProgress) { _ in saveConfiguration() }
        .onChange(of: showCategoryStats) { _ in saveConfiguration() }
        .onChange(of: autoRefreshEnabled) { _ in saveConfiguration() }
        .onChange(of: refreshInterval) { _ in saveConfiguration() }
    }
    
    private func loadAccountBooks() {
        // 使用SharedDatabaseReader來獲取帳本，確保與Widget Extension一致
        let sharedReader = SharedDatabaseReader.shared
        let widgetBooks = sharedReader.getAllAccountBooks()
        
        // 轉換為AccountBook類型以與UI兼容
        accountBooks = widgetBooks.map { widgetBook in
            AccountBook(id: widgetBook.id, currency: widgetBook.currency, name: widgetBook.name)
        }
        
        print("📚 Loaded \(accountBooks.count) account books for widget configuration")
        
        // 設定預設選擇的帳本
        if selectedBookId == nil {
            if let lastBookId = sharedReader.getLastOpenedBookId(),
               accountBooks.contains(where: { $0.id == lastBookId }) {
                selectedBookId = lastBookId
                print("📖 Selected last opened book: \(lastBookId)")
            } else {
                selectedBookId = accountBooks.first?.id
                print("📖 Selected first available book: \(selectedBookId ?? -1)")
            }
        }
    }
    
    private func loadConfiguration() {
        // 使用共享的配置加載方法
        if let config = MoneyWidgetConfiguration.load() {
            selectedBookId = config.selectedBookId
            showBalanceInWidget = config.showBalance
            showBudgetProgress = config.showBudgetProgress
            showCategoryStats = config.showCategoryStats
            autoRefreshEnabled = config.autoRefreshEnabled
            refreshInterval = config.refreshInterval
            print("⚙️ Loaded widget configuration: book \(selectedBookId ?? -1)")
        } else {
            print("⚙️ No existing widget configuration found, using defaults")
        }
    }
    
    private func saveConfiguration() {
        let config = MoneyWidgetConfiguration(
            selectedBookId: selectedBookId,
            showBalance: showBalanceInWidget,
            showBudgetProgress: showBudgetProgress,
            showCategoryStats: showCategoryStats,
            autoRefreshEnabled: autoRefreshEnabled,
            refreshInterval: refreshInterval
        )
        
        // 使用共享的配置保存方法
        config.save()
        print("💾 Saved widget configuration: book \(selectedBookId ?? -1)")
        
        // 立即更新小工具
        refreshAllWidgets()
    }
    
    private func refreshAllWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}

// MARK: - Supporting Views

struct BookSelectionView: View {
    let accountBooks: [AccountBook]
    @Binding var selectedBookId: Int?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            ForEach(accountBooks, id: \.id) { book in
                Button(action: {
                    selectedBookId = book.id
                    dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(book.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            Text("貨幣：\(book.currency)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedBookId == book.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                                .font(.subheadline)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .navigationTitle("選擇帳本")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingToggleRow: View {
    let title: String
    let description: String
    @Binding var isOn: Bool
    let icon: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(.blue)
                        .frame(width: 20)
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

#Preview {
    WidgetConfigurationView()
} 