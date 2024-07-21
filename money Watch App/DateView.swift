//
//  dateView.swift
//  money Watch App
//
//  Created by Show on 2024/5/22.
//

import SwiftUI

struct DateView: View {
    @Binding var navPath: NavigationPath
    @State private var note: String = ""
    @State private var date: Date = Date()
    
    var body: some View {
        Form {
            Section(header: Text("備註")) {
                TextField("輸入備註", text: $note)
            }
            
            Section(header: Text("日期")) {
                DatePicker("選擇日期", selection: $date, displayedComponents: [.date, .hourAndMinute])
            }
            
            Button(action: {
                // 這裡可以添加保存日期和備註的邏輯
                navPath.removeLast() // 返回上一個視圖
            }) {
                Text("完成")
                    .foregroundColor(.green)
            }
        }
        .navigationTitle("日期和備註")
    }
}

#Preview {
    NavigationStack {
        DateView(navPath: .constant(NavigationPath()))
    }
}
