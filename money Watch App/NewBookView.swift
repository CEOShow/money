//
//  NewBookView.swift
//  money Watch App
//
//  Created by Show on 2024/5/21.
//

import SwiftUI

struct NewBookView: View {
    @State private var name: String = ""  // 帳本名稱
    @State private var currency: String = "TWD"  // 默認幣值為 TWD
    @Binding var isPresented: Bool  // 用於控制視圖的顯示與隱藏
    var refreshAction: () -> Void  // 用於刷新列表的動作
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("帳本名稱", text: $name)  // 用於輸入帳本名稱
                
                NavigationLink(destination: CurrencySelectionView(selectedCurrency: $currency)) {
                    HStack {
                        Text("幣值")
                        Spacer()
                        Text(currency)  // 顯示選擇的幣值
                            .foregroundColor(.gray)
                    }
                }
                
                Button("新增帳本") {
                    let success = AccountingManager.shared.createAccountBook(currency: currency, name: name)  // 創建帳本
                    if success {
                        refreshAction()  // 執行刷新動作
                        isPresented = false  // 關閉視圖
                    }
                }
            }
            .navigationTitle("新增帳本")  // 設置導航欄標題
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        isPresented = false  // 取消操作，關閉視圖
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
            print("刷新動作在預覽中被調用")
        })
    }
}
