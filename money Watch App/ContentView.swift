//
//  ContentView.swift
//  money Watch App
//
//  Created by Show on 2024/5/3.
//

import SwiftUI

struct ContentView: View {
    @State private var accountBooks: [AccountBook] = []
    @State private var isShowingNewBook = false
    
    var body: some View {
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
                
                Button("新增帳本") {
                    isShowingNewBook = true
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .sheet(isPresented: $isShowingNewBook) {
            NewBookView(isPresented: $isShowingNewBook, refreshAction: refreshAccountBooks)
        }
        .onAppear {
            refreshAccountBooks()
        }
    }
    
    private func refreshAccountBooks() {
        accountBooks = AccountingManager.shared.getAllAccountBooks()
    }
}

#Preview {
    ContentView()
}
