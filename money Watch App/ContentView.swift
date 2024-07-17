//
//  ContentView.swift
//  money Watch App
//
//  Created by Show on 2024/5/3.
//

import SwiftUI

struct ContentView: View {
    @State private var nevpath: [String] = []
    @State private var accountBooks: [AccountBook] = []
    @State private var refreshID = UUID()
    
    var body: some View {
        NavigationStack(path: $nevpath) {
            VStack {
                Text("主頁")
                
                NavigationLink(value: "stringPath 1") {
                    Text("我的帳本")
                }
                
                NavigationLink {
                    NewBookView(refreshAction: refreshAccountBooks)
                } label: {
                    Text("+")
                        .foregroundColor(Color.blue)
                }
                
                List(accountBooks) { book in
                    Text(book.name)
                }
            }
            .navigationDestination(for: String.self) { stringPath in
                if stringPath == "stringPath 1" {
                    MyBookView()
                } else if stringPath == "stringPath 2" {
                    CalculatorView()
                } else if stringPath == "stringPath 3" {
                    CategoryView()
                } else if stringPath == "stringPath 4" {
                    DateView(dapath: $nevpath)
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
