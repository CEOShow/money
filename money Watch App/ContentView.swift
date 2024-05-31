//
//  ContentView.swift
//  money Watch App
//
//  Created by Show on 2024/5/3.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            VStack {
                
                Text("主頁")
                NavigationLink {
                    MyBookView()
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
