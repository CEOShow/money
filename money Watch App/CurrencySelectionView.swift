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
        "TWD - 新台幣",
        "JPY - 日圓",
        "KRW - 韓元",
        "CNY - 人民幣",
        "THB - 泰銖",
        "VND - 越南盾",
        "USD - 美元",
        "EUR - 歐元",
        "GBP - 英鎊",
        "AUD - 澳元",
        "CAD - 加拿大元",
        "CHF - 瑞士法郎",
        "HKD - 港幣"
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
        .navigationTitle("選擇幣值")
    }
}

#Preview {
    CurrencySelectionView(selectedCurrency: .constant("USD"))
}
