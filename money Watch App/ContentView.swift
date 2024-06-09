//
//  ContentView.swift
//  money Watch App
//
//  Created by Show on 2024/5/3.
//

import SwiftUI

struct ContentView: View {
    @State private var nevpath: [String] = []
    var body: some View {
        NavigationStack(path:$nevpath ){
            VStack {
                
                Text("主頁")
                //NavigationLink {
                 //   MyBookView(mybookpath: $nevpath)
                // } label: {
                  //  Text("我的帳本")
               // }
                //NavigationLink(value: "stringPath 1", label: Text("我的帳本"))
                NavigationLink(value: "stringPath 1") {
                    Text("我的帳本")
                }
                
                NavigationLink {
                    NewBookView()
                } label: {
                    Text("+")
                        .foregroundColor(Color.blue)
                }
                
                
            }.navigationDestination(for: String.self) { stringPath in
                if stringPath == "stringPath 1"{
//                    MyBookView(mybookpath: $nevpath)
                    MyBookView()
                } else if stringPath == "stringPath 2"{
                    CalculatorView()
                } else if stringPath == "stringPath 3"{
                    CategoryView()
                } else if stringPath == "stringPath 4"{
                    DateView(dapath: $nevpath)
                }
                
                
            }
        }
    }
}

#Preview {
    ContentView()
}
