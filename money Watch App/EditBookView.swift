//
//  EditBookView.swift
//  money Watch App
//
//  Created by Show on 2026/7/5.
//

import SwiftUI

struct EditBookView: View {
    @Binding var isPresented: Bool
    let accountBook: AccountBook
    let onSave: (AccountBook) -> Void
    
    @State private var bookName: String = ""
    @State private var selectedCurrency: String = "TWD"
    
    let currencies = ["TWD", "USD", "JPY", "EUR", "GBP", "CNY", "HKD", "KRW"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Edit Book", bundle: .main)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Book Name", bundle: .main)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextField(NSLocalizedString("Enter book name", comment: ""), text: $bookName)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .foregroundColor(.black)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Currency", bundle: .main)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Picker(NSLocalizedString("Currency", comment: ""), selection: $selectedCurrency) {
                        ForEach(currencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .foregroundColor(.black)
                }
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(String(localized: "Cancel")) {
                        isPresented = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(String(localized: "Save")) {
                        let updatedBook = AccountBook(
                            id: accountBook.id,
                            currency: selectedCurrency,
                            name: bookName
                        )
                        onSave(updatedBook)
                        isPresented = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(bookName.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(bookName.isEmpty)
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .background(Color.black.opacity(0.8))
        .onAppear {
            bookName = accountBook.name
            selectedCurrency = accountBook.currency
        }
    }
}

#Preview {
    EditBookView(
        isPresented: .constant(true),
        accountBook: AccountBook(id: 1, currency: "TWD", name: "測試帳本"),
        onSave: { _ in }
    )
} 