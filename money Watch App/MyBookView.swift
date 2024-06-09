//
//  MyBookView.swift
//  money Watch App
//
//  Created by Show on 2024/5/21.
//

import SwiftUI

struct MyBookView: View {
//    @Binding var mybookpath: [String]
    var body: some View {
        Text("收入＄")
        Divider()
        Text("餘額＄")
        Divider()
        Text("支出＄")
        Divider()
        //NavigationLink {
          //  CalculatorView(calpath: $mybookpath)
        //} label: {
          //  Text("+")
            //    .foregroundColor(Color.green)
        //}
        NavigationLink(value: "stringPath 2") {
            Text("+")
                .foregroundColor(Color.green)
        }


            
        
        
    }
}

#Preview {
//    @State var tpath = ["ihjh"]
//    return MyBookView(mybookpath: $tpath)
    MyBookView()
    
}
