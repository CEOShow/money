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
   @StateObject private var themeManager = ThemeManager.shared
   @EnvironmentObject private var navigationManager: NavigationManager

   var body: some View {
       ZStack(alignment: .bottomTrailing) {
           List {
               // 標題區域
               VStack(spacing: 10) {
                   Text("Home", bundle: .main)
                       .font(.largeTitle)
                       .fontWeight(.bold)
                       .foregroundColor(.white)
                       .frame(maxWidth: .infinity)
                       .padding(.top)
               }
               .listRowBackground(Color.clear)
               .listRowInsets(EdgeInsets())
               
               // 帳本列表
               if accountBooks.isEmpty {
                   VStack(spacing: 20) {
                       Text("You don't have any account books yet. Tap the button below to add a new one.", bundle: .main)
                           .foregroundColor(.white)
                           .padding()
                   }
                   .listRowBackground(Color.clear)
                   .listRowInsets(EdgeInsets())
               } else {
                   ForEach(accountBooks) { book in
                       NavigationLink(value: book) {
                           HStack {
                               VStack(alignment: .leading) {
                                   Text(book.name)
                                       .font(.headline)
                                       .foregroundColor(.black)
                                   Text(book.currency)
                                       .font(.subheadline)
                                       .foregroundColor(.gray)
                               }
                               Spacer()
                               Image(systemName: "chevron.right")
                                   .foregroundColor(.gray)
                           }
                           .padding()
                           .background(Color.white)
                           .cornerRadius(10)
                       }
                       .buttonStyle(PlainButtonStyle())
                       .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                           Button(role: .destructive, action: {
                               deleteAccountBook(book)
                           }) {
                               Label(NSLocalizedString("Delete", comment: ""), systemImage: "trash")
                           }
                       }
                       .listRowBackground(Color.clear)
                       .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                   }
               }
               
               // 新增帳本按鈕
               Button(String(localized: "Add Book")) {
                   isShowingNewBook = true
               }
               .padding()
               .frame(maxWidth: .infinity)
               .background(Color.green)
               .foregroundColor(.white)
               .cornerRadius(10)
               .buttonStyle(PlainButtonStyle())
               .listRowBackground(Color.clear)
               .listRowInsets(EdgeInsets(top: 20, leading: 16, bottom: 20, trailing: 16))
           }
           .listStyle(PlainListStyle())
           .scrollContentBackground(.hidden)
           .background(
               themeManager.currentBackground()
           )
           .sheet(isPresented: $isShowingNewBook) {
               NewBookView(isPresented: $isShowingNewBook, refreshAction: refreshAccountBooks)
           }
           .onAppear {
               refreshAccountBooks()
           }

           // Settings button - fixed in extreme bottom right corner
           Button(action: {
               isShowingSettings = true
           }) {
               Image(systemName: "gear")
                   .font(.system(size: 16))
                   .foregroundColor(.white)
                   .padding(8)
                   .background(
                       Circle()
                           .fill(Color.black.opacity(0.3))
                           .overlay(
                               Circle()
                                   .stroke(Color.white.opacity(0.5), lineWidth: 1)
                           )
                   )
           }
           .padding(.bottom, 10)  // 最小的底部間距
           .padding(.trailing, 10)  // 最小的右側間距
           .buttonStyle(PlainButtonStyle())
           .sheet(isPresented: $isShowingSettings) {
               SettingsView(isPresented: $isShowingSettings)
           }
       }
   }

   private func refreshAccountBooks() {
       accountBooks = AccountingManager.shared.getAllAccountBooks()
       print("載入帳本數量: \(accountBooks.count)")
       for book in accountBooks {
           print("帳本: \(book.name) - \(book.currency)")
       }
   }
   
   private func deleteAccountBook(_ book: AccountBook) {
       if AccountingManager.shared.deleteAccountBook(id: book.id) {
           refreshAccountBooks()
       }
   }
}

#Preview {
   ContentView()
}
