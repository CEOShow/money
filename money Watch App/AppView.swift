//
//  AppView.swift
//  money Watch App
//
//  Created by Show on 2024/8/7.
//

import SwiftUI

struct AppView: View {
    @State private var navigationPath = NavigationPath()
    @State private var hasLoadedLastBook = false

    var body: some View {
        if #available(watchOS 10, *) {
            NavigationStack(path: $navigationPath) {
                ContentView()
                    .navigationDestination(for: AccountBook.self) { book in
                        MyBookView(accountBook: book)
                    }
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
                    .navigationDestination(for: AccountBook.self) { book in
                        MyBookView(accountBook: book)
                    }
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
}

#Preview {
    AppView()
}
