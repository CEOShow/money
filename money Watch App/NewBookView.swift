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
    @Binding var isPresented: Bool
    var refreshAction: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                TextField(NSLocalizedString("Book Name", comment: ""), text: $name)
                
                NavigationLink(destination: CurrencySelectionView(selectedCurrency: $currency)) {
                    HStack {
                        Text(NSLocalizedString("Currency", comment: ""))
                        Spacer()
                        Text(currency)
                            .foregroundColor(.gray)
                    }
                }
                
                Button(NSLocalizedString("Create Book", comment: "")) {
                    let success = AccountingManager.shared.createAccountBook(currency: currency, name: name)
                    if success {
                        refreshAction()
                        isPresented = false
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .navigationTitle(NSLocalizedString("Add Book", comment: ""))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("Cancel", comment: "")) {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct NewBookView_Previews: PreviewProvider {
    @State static private var isPresented: Bool = true
    
    static var previews: some View {
        NewBookView(isPresented: $isPresented, refreshAction: {
            print("Refresh action called in preview")
        })
    }
}
