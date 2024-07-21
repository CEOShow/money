//
//  NewBookView.swift
//  money Watch App
//
//  Created by Show on 2024/5/21.
//

import SwiftUI

struct NewBookView: View {
    @State private var name: String = ""
    @State private var currency: String = "TWD"
    @Environment(\.presentationMode) var presentationMode
    var refreshAction: () -> Void
    
    var body: some View {
        Form {
            TextField("帳本名稱", text: $name)
            
            NavigationLink(destination: CurrencySelectionView(selectedCurrency: $currency)) {
                HStack {
                    Text("幣值")
                    Spacer()
                    Text(currency)
                        .foregroundColor(.gray)
                }
            }
            
            Button("新增帳本") {
                let success = AccountingManager.shared.createAccountBook(currency: currency, name: name)
                if success {
                    refreshAction()
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("新增帳本")
    }
}

#Preview {
    NavigationView {
        NewBookView(refreshAction: {
            print("Refresh action called in preview")
        })
    }
}
