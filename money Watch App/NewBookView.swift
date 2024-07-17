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
            TextField("貨幣", text: $currency)
            
            Button("新增帳本") {
                let success = AccountingManager.shared.createAccountBook(currency: currency, name: name)
                if success {
                    refreshAction()
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

#Preview {
    NewBookView(refreshAction: {
        // 這裡可以是一個空的閉包，因為它只是用於預覽
        print("Refresh action called in preview")
    })
}
