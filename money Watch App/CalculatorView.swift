//
//  calculatorView.swift
//  money Watch App
//
//  Created by Show on 2024/5/21.
//

import SwiftUI

struct CalculatorView: View {
    @Binding var calpath: [String]
    var body: some View {
        VStack{  // 1
            HStack{ // 2
                Text("-0").frame(maxWidth: .infinity)
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Image(systemName: "delete.left.fill")
                }).buttonStyle(PlainButtonStyle())
            } // 2
            Divider()
            HStack{ // 3
                VStack{
                HStack{
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text("1")
                    }).buttonStyle(PlainButtonStyle())
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text("2")
                    }).buttonStyle(PlainButtonStyle())
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text("3")
                    }).buttonStyle(PlainButtonStyle())
                }
                HStack{ // 5
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text("4")
                    }).buttonStyle(PlainButtonStyle())
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text("5")
                    }).buttonStyle(PlainButtonStyle())
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text("6")
                    }).buttonStyle(PlainButtonStyle())
                }
                HStack{ // 7
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text("7")
                    }).buttonStyle(PlainButtonStyle())
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text("8")
                    }).buttonStyle(PlainButtonStyle())
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text("9")
                    }).buttonStyle(PlainButtonStyle())
                }
                    HStack{ // 8
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Text("0")
                        }).buttonStyle(PlainButtonStyle())
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Text("00")
                        }).buttonStyle(PlainButtonStyle())
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Text(".")
                        }).buttonStyle(PlainButtonStyle())
                    }
                    
                }
                Divider()
                VStack{
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text("收")
                    }).buttonStyle(PlainButtonStyle())
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text("支")
                    }).buttonStyle(PlainButtonStyle())
                    NavigationLink {
                        CategoryView()
                    } label: {
                        Text("OK")
                            .foregroundColor(Color.green)
                    }.buttonStyle(PlainButtonStyle())

                }
            }
        } // 1
    }
}

#Preview {
    @State var tpath = ["ihjh"]
    return CalculatorView(calpath: $tpath)
}

