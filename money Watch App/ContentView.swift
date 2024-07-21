//
//  ContentView.swift
//  money Watch App
//
//  Created by Show on 2024/5/3.
//

import SwiftUI

struct ContentView: View {
    @State private var navPath = NavigationPath()
    @State private var accountBooks: [AccountBook] = []
    @State private var refreshID = UUID()
    @State private var calculatorAmount: String = "0"
    @State private var calculatorIsIncome: Bool = false
    
    var body: some View {
        NavigationStack(path: $navPath) {
            ScrollView {
                VStack(spacing: 20) {
                    Text("主頁")
                        .font(.largeTitle)
                        .padding()
                    
                    if accountBooks.isEmpty {
                        Text("你還沒有帳本，點擊下方按鈕新增帳本")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(accountBooks) { book in
                            NavigationLink(value: book) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(book.name)
                                            .font(.headline)
                                        Text(book.currency)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                    }
                    
                    Spacer(minLength: 50)
                    
                    NavigationLink(destination: NewBookView(refreshAction: refreshAccountBooks)) {
                        Text("新增帳本")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationDestination(for: AccountBook.self) { book in
                MyBookView(accountBook: book)
            }
            .navigationDestination(for: String.self) { stringPath in
                switch stringPath {
                case "calculator":
                    CalculatorView(amount: $calculatorAmount, isIncome: $calculatorIsIncome)
                case "category": CategoryView()
                case "date": DateView(navPath: $navPath)
                default: EmptyView()
                }
            }
        }
        .id(refreshID)
        .onAppear {
            refreshAccountBooks()
        }
    }
    
    private func refreshAccountBooks() {
        accountBooks = AccountingManager.shared.getAllAccountBooks()
        refreshID = UUID()
    }
}

#Preview {
    ContentView()
}
