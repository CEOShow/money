//
//  dateView.swift
//  money Watch App
//
//  Created by Show on 2024/5/22.
//

import SwiftUI

struct DateView: View {
    @Binding var dapath: [String]
    var body: some View {
        Text("備註：")
        Text("日期：")
        Button(action: {
            dapath = []
        }, label: {
            Text("完成！")
                .foregroundColor(Color.green)
        })

    }
}

#Preview {
    @State var tpath = ["ihjh", "fjsdkafj"]
    return DateView(dapath: $tpath)

}
