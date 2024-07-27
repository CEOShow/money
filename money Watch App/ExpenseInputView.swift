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
    @State private var showingDatePicker = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Amount Section
                Section {
                    Button(action: {
                        showingCalculator = true
                    }) {
                        Text(amount)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .sheet(isPresented: $showingCalculator) {
                        CalculatorView(amount: $amount, isIncome: $isIncome)
                    }

                    HStack {
                        Button(action: { isIncome = false }) {
                            Text("支出")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(isIncome ? Color.gray.opacity(0.3) : Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: { isIncome = true }) {
                            Text("收入")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(isIncome ? Color.green : Color.gray.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                
                // Category Section
                Section {
                    NavigationLink(destination: CategoryView(selectedCategory: $selectedCategory)) {
                        HStack {
                            Text("類別")
                            Spacer()
                            Text(selectedCategory.name)
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                
                // Note Section
                Section {
                    TextField("輸入備註", text: $note)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                
                // Date Section
                Section {
                    Button(action: {
                        showingDatePicker = true
                    }) {
                        HStack {
                            Text("選擇日期")
                            Spacer()
                            Text(formatDate(date))
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .sheet(isPresented: $showingDatePicker) {
                    CustomDatePickerView(date: $date, showingDatePicker: $showingDatePicker)
                }
                
                // Save Button
                Button(action: saveExpense) {
                    Text("保存")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle("新增紀錄")
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
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

struct CustomDatePickerView: View {
    @Binding var date: Date
    @Binding var showingDatePicker: Bool
    
    var body: some View {
        VStack {
            DatePicker(
                "Select Date",
                selection: $date,
                displayedComponents: [.date]
            )
            .datePickerStyle(WheelDatePickerStyle())
            .labelsHidden()
            .frame(height: 200)
            .clipped()
            
            Button("確定") {
                showingDatePicker = false
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

struct ExpenseInputView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseInputView(accountBook: AccountBook(id: 1, currency: "TWD", name: "測試帳本"))
    }
}
