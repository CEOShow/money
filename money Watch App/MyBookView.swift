//
//  MyBookView.swift
//  money Watch App
//
//  Created by Show on 2024/5/21.
//

import SwiftUI

struct MyBookView: View {
    var body: some View {
        Text("收入＄")
        Divider()
        Text("餘額＄")
        Divider()
        Text("支出＄")
        Divider()
        NavigationLink {
            CalculatorView()
        } label: {
            Text("+")
                .foregroundColor(Color.green)
        }


            
        
        
    }
}

#Preview {
    MyBookView()
}
