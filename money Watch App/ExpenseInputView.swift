//
//  ExpenseInputView.swift
//  money Watch App
//
//  Created by Show on 2024/7/19.
//

import SwiftUI

struct ExpenseInputView: View {
    @Environment(\.presentationMode) var presentationMode
    let accountBook: AccountBook
    @State private var amount: String = "0"
    @State private var selectedCategory: Category = .foodAndEntertainment
    @State private var note: String = ""
    @State private var date: Date = Date()
    @State private var isIncome: Bool = false
    @State private var showingCalculator = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("金額")) {
                    VStack {
                        Button(action: {
                            showingCalculator = true
                        }) {
                            Text(amount)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .sheet(isPresented: $showingCalculator) {
                            CalculatorView(amount: $amount, isIncome: $isIncome)
                        }

                        Picker("收支", selection: $isIncome) {
                            Text("支出").tag(false)
                            Text("收入").tag(true)
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 100)
                    }
                }
                
                Section(header: Text("類別")) {
                    Picker("選擇類別", selection: $selectedCategory) {
                        ForEach(Category.allCases, id: \.self) { category in
                            Text(category.name).tag(category)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 100)
                }
                
                Section(header: Text("備註")) {
                    TextField("輸入備註", text: $note)
                }
                
                Section(header: Text("日期")) {
                    DatePicker("選擇日期", selection: $date, displayedComponents: .date)
                }
                
                Button(action: saveExpense) {
                    Text("保存")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("新增紀錄")
            .toolbar {
                #if !os(watchOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                #endif
            }
            #if os(watchOS)
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            })
            #endif
        }
    }
    
    private func saveExpense() {
        guard let amountValue = Double(amount), amountValue > 0 else {
            print("請輸入有效的金額")
            return
        }
        
        let income = isIncome ? amountValue : -amountValue
        
        if AccountingManager.shared.addExpense(
            bookId: accountBook.id,
            income: income,
            date: date,
            note: note,
            category: selectedCategory
        ) {
            print("紀錄已保存")
            presentationMode.wrappedValue.dismiss()
        } else {
            print("保存失敗，請稍後再試")
        }
    }
}

struct ExpenseInputView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseInputView(accountBook: AccountBook(id: 1, currency: "TWD", name: "測試帳本"))
    }
}

#Preview {
    ExpenseInputView(accountBook: AccountBook(id: 1, currency: "TWD", name: "測試帳本"))
}
