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
                Text("Home", bundle: .main)
                    .font(.largeTitle)
                    .padding()
                
                if accountBooks.isEmpty {
                    Text("You don't have any account books yet. Tap the button below to add a new one.", bundle: .main)
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
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer(minLength: 10)
                
                Button(String(localized: "Add Book")) {
                    isShowingNewBook = true
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .buttonStyle(PlainButtonStyle())
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
