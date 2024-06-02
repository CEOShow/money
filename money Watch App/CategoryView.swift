//
//  categoryView.swift
//  money Watch App
//
//  Created by Show on 2024/5/22.
//

import SwiftUI

struct CategoryView: View {
    var body: some View {
            Text("類別")
            Divider()
        List{
            NavigationLink {
                DateView()
            } label: {
                Text("吃喝玩樂")
                Image(systemName: "waterbottle")
            }
            
            NavigationLink {
                DateView()
            } label: {
                Text("購物")
                Image(systemName: "basket")
            }
            NavigationLink {
                DateView()
            } label: {
                Text("零用錢")
                Image(systemName: "banknote")
            }
            NavigationLink {
                DateView()
            } label: {
                Text("旅行")
                Image(systemName: "airplane")
            }
            NavigationLink {
                DateView()
            } label: {
                Text("交通")
                Image(systemName: "car.side" )
            }
        }
            

    }
}

#Preview {
    CategoryView()
}
