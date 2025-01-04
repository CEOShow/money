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
    @State private var isShowingSettings = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 顶部的設定按鈕和標題
                HStack {
                    Button(action: {
                        isShowingSettings = true
                    }) {
                        Image(systemName: "gear")
                            .font(.system(size: 20))
                    }
                    .buttonStyle(BackButtonStyle()) // 使用自訂樣式

                    Text("Home", bundle: .main)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Spacer()
                }
                .padding([.horizontal, .top]) // 調整按鈕與標題的間距
                .padding(.bottom, 10) // 與內容間的距離

                if accountBooks.isEmpty {
                    Text("You don't have any account books yet. Tap the button below to add a new one.", bundle: .main)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(accountBooks) { book in
                        NavigationLink(destination: Text("Detail View for \(book.name)")) {
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
        .sheet(isPresented: $isShowingSettings) {
            // 設定畫面
            Text("Settings")
        }
        .onAppear {
            refreshAccountBooks()
        }
    }

    private func refreshAccountBooks() {
        accountBooks = AccountingManager.shared.getAllAccountBooks()
    }
}

// 自訂按鈕樣式
struct BackButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20))
            .foregroundColor(.white)
            .frame(width: 35, height: 35)
            .background(Color.black.opacity(0.3))
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0) // 按下時有縮放效果
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}
