//
//  dateView.swift
//  money Watch App
//
//  Created by Show on 2024/5/22.
//

import SwiftUI

struct DateView: View {
    var body: some View {
        Text("備註：")
        Text("日期：")
        NavigationLink(destination: {
            FinishView()
        }, label: {
            Text("OK")
        })
            .foregroundColor(Color.green)
    }
}

#Preview {
    DateView()
}
