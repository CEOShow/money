//
//  categoryView.swift
//  money Watch App
//
//  Created by Show on 2024/5/22.
//

import SwiftUI

struct CategoryView: View {
//    @Binding var Catpath: [String]
    var body: some View {
            Text("類別")
            Divider()
        List{
            //NavigationLink {
              //  DateView(Dapath: $Catpath)
            //} label: {
              //  Text("吃喝玩樂")
                //Image(systemName: "waterbottle")
            //}
            NavigationLink(value: "stringPath 4") {
                Text("吃喝玩樂")
                Image(systemName: "waterbottle")
            }
            
            //NavigationLink {
              //  DateView(Dapath: $Catpath)
            //} label: {
              //  Text("購物")
                //Image(systemName: "basket")
            //}
            NavigationLink(value: "stringPath 4") {
                Text("購物")
                Image(systemName: "basket")
            }
//            NavigationLink {
//                DateView(Dapath: $Catpath)
//            } label: {
//                Text("零用錢")
//                Image(systemName: "banknote")
//            }
            NavigationLink(value: "stringPath 4") {
                Text("零用錢")
                Image(systemName: "banknote")
            }
//            NavigationLink {
//                DateView(Dapath: $Catpath)
//            } label: {
//                Text("旅行")
//                Image(systemName: "airplane")
//            }
            NavigationLink(value: "stringPath 4") {
                Text("旅行")
                Image(systemName: "airplane")
            }
//            NavigationLink {
//                DateView(Dapath: $Catpath)
//            } label: {
//                Text("交通")
//                Image(systemName: "car.side" )
//            }
            NavigationLink(value: "stringPath 4") {
                Text("交通")
                Image(systemName: "car.side" )
            }
        }
            

    }
}

#Preview {
//    @State var tpath = ["ihjh"]
//    return CategoryView(Catpath: $tpath)
    CategoryView()
}
