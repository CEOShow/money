//
//  CurrencySelectionView.swift
//  money Watch App
//
//  Created by Show on 2024/7/19.
//

import SwiftUI

struct CurrencySelectionView: View {
    @Binding var selectedCurrency: String
    @Environment(\.presentationMode) var presentationMode
    
    let currencies = [
        "TWD - Taiwan Dollar",
        "JPY - Japanese Yen",
        "KRW - Korean Won",
        "CNY - Chinese Yuan",
        "THB - Thai Baht",
        "VND - Vietnamese Dong",
        "USD - US Dollar",
        "EUR - Euro",
        "GBP - British Pound",
        "AUD - Australian Dollar",
        "CAD - Canadian Dollar",
        "CHF - Swiss Franc",
        "HKD - Hong Kong Dollar"
    ]
    
    var body: some View {
        List {
            ForEach(currencies, id: \.self) { currency in
                Button(action: {
                    selectedCurrency = String(currency.prefix(3))
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text(currency)
                        Spacer()
                        if selectedCurrency == String(currency.prefix(3)) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle(NSLocalizedString("Select Currency", comment: ""))
    }
}

#Preview {
    CurrencySelectionView(selectedCurrency: .constant("USD"))
}
