//
//  categoryView.swift
//  money Watch App
//
//  Created by Show on 2024/5/22.
//

import SwiftUI

struct CategoryView: View {
    @Binding var selectedCategory: Category
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        List {
            ForEach(Category.allCases, id: \.self) { category in
                Button(action: {
                    selectedCategory = category
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text(category.name)
                        Spacer()
                        if category == selectedCategory {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("選擇類別")
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView(selectedCategory: .constant(.foodAndEntertainment))
    }
}
