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
                   .fontWeight(.bold)
                   .foregroundColor(.white)
                   .frame(maxWidth: .infinity)
                   .padding([.horizontal, .top])
                   .padding(.bottom, 10)

               if accountBooks.isEmpty {
                   Text("You don't have any account books yet. Tap the button below to add a new one.", bundle: .main)
                       .foregroundColor(.white)
                       .padding()
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
                   }
               }

               Spacer(minLength: 10)

               Button(String(localized: "Add Book")) {
                   isShowingNewBook = true
               }
               .padding()
               .frame(maxWidth: .infinity)
               .background(Color.green)
               .foregroundColor(.white)
               .cornerRadius(10)
               .buttonStyle(PlainButtonStyle())
           }
           .padding()
       }
       .background(
           LinearGradient(
            gradient: Gradient(colors: [.blue, .purple]),
               startPoint: .topLeading,
               endPoint: .bottomTrailing
           )
           .ignoresSafeArea()
       )
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
