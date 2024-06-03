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
                NavigationLink {
                    MyBookView(mybookpath: $nevpath)
                } label: {
                    Text("我的帳本")
                }


                NavigationLink {
                    NewBookView()
                } label: {
                    Text("+")
                        .foregroundColor(Color.blue)
                }

                
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
