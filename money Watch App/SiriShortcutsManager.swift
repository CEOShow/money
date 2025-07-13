//
//  SiriShortcutsManager.swift
//  money Watch App
//
//  Created by Show on 2024/12/19.
//

import Foundation

class SiriShortcutsManager: ObservableObject {
    static let shared = SiriShortcutsManager()
    
    private init() {}
    
    // 處理語音輸入文字解析
    func processVoiceInput(_ text: String) -> (amount: Double?, note: String?) {
        let cleanText = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 嘗試解析金額
        let amount = extractAmount(from: cleanText)
        
        // 提取備註（移除金額相關的文字）
        let note = extractNote(from: cleanText, amount: amount)
        
        return (amount, note)
    }
    
    private func extractAmount(from text: String) -> Double? {
        // 先嘗試中文數字轉換
        let textWithArabicNumbers = convertChineseNumbersToArabic(text)
        
        // 更全面的金額格式匹配
        let patterns = [
            // 標準格式：花了100元、買了50塊
            "(?:花了|花費|支出|買了|付了|用了|消費|花|買|付|用|記帳|記錄|記|帳|支付|付款|消費了|花掉|用掉|買下|購買|付出|費用|成本|價格|價錢|金額|錢|款|支)\\s*(\\d+(?:\\.\\d+)?)\\s*(?:元|塊|塊錢|dollar|dollars|蚊|毛|分|角|圓|塊錢|塊|元錢|元整|整|台幣|人民幣|港幣|美金|美元)?",
            
            // 直接數字：100元、50塊
            "(\\d+(?:\\.\\d+)?)\\s*(?:元|塊|塊錢|dollar|dollars|蚊|毛|分|角|圓|塊錢|塊|元錢|元整|整|台幣|人民幣|港幣|美金|美元)",
            
            // 價格格式：價格100、費用50
            "(?:價格|金額|費用|成本|價錢|錢|款項|支出|開支|花費|消費|總計|合計|共計|一共|總共|共)\\s*(?:是|為|有|要|需要|需|得|要花|要付|要用|要買|要給|給|付|用|花|買|支付|消費|開支|支出)?\\s*(\\d+(?:\\.\\d+)?)\\s*(?:元|塊|塊錢|dollar|dollars|蚊|毛|分|角|圓|塊錢|塊|元錢|元整|整|台幣|人民幣|港幣|美金|美元)?",
            
            // 口語化：一百塊、五十元
            "(?:花了|花費|支出|買了|付了|用了|消費|花|買|付|用|記帳|記錄|記|帳|支付|付款|消費了|花掉|用掉|買下|購買|付出|費用|成本|價格|價錢|金額|錢|款|支)?\\s*([一二三四五六七八九十百千萬壹貳參肆伍陸柒捌玖拾佰仟萬]+|\\d+(?:\\.\\d+)?)\\s*(?:元|塊|塊錢|dollar|dollars|蚊|毛|分|角|圓|塊錢|塊|元錢|元整|整|台幣|人民幣|港幣|美金|美元)?",
            
            // 小數格式：一塊五、三塊錢五毛
            "(?:花了|花費|支出|買了|付了|用了|消費|花|買|付|用|記帳|記錄|記|帳|支付|付款|消費了|花掉|用掉|買下|購買|付出|費用|成本|價格|價錢|金額|錢|款|支)?\\s*(\\d+)\\s*(?:元|塊|塊錢|圓)\\s*(?:五|五毛|五角|五分|一毛|一角|一分|二毛|二角|二分|三毛|三角|三分|四毛|四角|四分|六毛|六角|六分|七毛|七角|七分|八毛|八角|八分|九毛|九角|九分)?",
            
            // 更多格式
            "(?:總共|總計|合計|一共|共)\\s*(?:是|為|有|要|需要|需|得|要花|要付|要用|要買|要給|給|付|用|花|買|支付|消費|開支|支出)?\\s*(\\d+(?:\\.\\d+)?)\\s*(?:元|塊|塊錢|dollar|dollars|蚊|毛|分|角|圓|塊錢|塊|元錢|元整|整|台幣|人民幣|港幣|美金|美元)?",
            
            // 簡單數字匹配（最後嘗試）
            "(\\d+(?:\\.\\d+)?)",
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(location: 0, length: textWithArabicNumbers.utf16.count)
                if let match = regex.firstMatch(in: textWithArabicNumbers, options: [], range: range) {
                    if match.numberOfRanges > 1 {
                        let numberRange = match.range(at: 1)
                        if let range = Range(numberRange, in: textWithArabicNumbers) {
                            let numberString = String(textWithArabicNumbers[range])
                            
                            // 如果是中文數字，轉換為阿拉伯數字
                            if let arabicNumber = chineseNumberToArabic(numberString) {
                                return arabicNumber
                            }
                            
                            // 處理小數格式（如：一塊五 = 1.5）
                            if let baseAmount = Double(numberString) {
                                if textWithArabicNumbers.contains("五毛") || textWithArabicNumbers.contains("五角") || textWithArabicNumbers.contains("五分") {
                                    return baseAmount + 0.5
                                }
                                return baseAmount
                            }
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    private func extractNote(from text: String, amount: Double?) -> String? {
        var note = text
        
        // 移除金額相關的文字但保留重要內容
        let removePatterns = [
            "記帳", "記錄", "記", "帳",
            "花了", "花費", "花", "支出", "買了", "付了", "用了", "消費", "買", "付", "用",
            "支付", "付款", "消費了", "花掉", "用掉", "買下", "購買", "付出",
            "費用", "成本", "價格", "價錢", "金額", "錢", "款", "支",
            "總共", "總計", "合計", "一共", "共", "總",
            "是", "為", "有", "要", "需要", "需", "得", "要花", "要付", "要用", "要買", "要給", "給"
        ]
        
        // 移除貨幣單位
        let currencyPatterns = [
            "元", "塊錢", "塊", "dollar", "dollars", "蚊", "毛", "分", "角", "圓",
            "元錢", "元整", "整", "台幣", "人民幣", "港幣", "美金", "美元",
            "五毛", "五角", "五分", "一毛", "一角", "一分", "二毛", "二角", "二分",
            "三毛", "三角", "三分", "四毛", "四角", "四分", "六毛", "六角", "六分",
            "七毛", "七角", "七分", "八毛", "八角", "八分", "九毛", "九角", "九分"
        ]
        
        // 移除數字
        if let amount = amount {
            let amountString = String(format: "%.0f", amount)
            note = note.replacingOccurrences(of: amountString, with: "")
            
            // 移除可能的小數部分
            if amount.truncatingRemainder(dividingBy: 1) != 0 {
                let decimalString = String(format: "%.1f", amount)
                note = note.replacingOccurrences(of: decimalString, with: "")
            }
        }
        
        // 移除中文數字
        let chineseNumbers = ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "百", "千", "萬", "壹", "貳", "參", "肆", "伍", "陸", "柒", "捌", "玖", "拾", "佰", "仟", "萬"]
        for number in chineseNumbers {
            note = note.replacingOccurrences(of: number, with: "")
        }
        
        // 移除關鍵字
        for pattern in removePatterns {
            note = note.replacingOccurrences(of: pattern, with: "", options: .caseInsensitive)
        }
        
        // 移除貨幣單位
        for pattern in currencyPatterns {
            note = note.replacingOccurrences(of: pattern, with: "", options: .caseInsensitive)
        }
        
        // 清理空白和標點符號
        note = note.trimmingCharacters(in: .whitespacesAndNewlines.union(.punctuationCharacters))
        
        // 移除多餘的空白
        note = note.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        return note.isEmpty ? nil : note
    }
    
    // 中文數字轉阿拉伯數字
    private func chineseNumberToArabic(_ chinese: String) -> Double? {
        let numberMap: [String: Int] = [
            "零": 0, "一": 1, "二": 2, "三": 3, "四": 4, "五": 5, "六": 6, "七": 7, "八": 8, "九": 9,
            "壹": 1, "貳": 2, "參": 3, "肆": 4, "伍": 5, "陸": 6, "柒": 7, "捌": 8, "玖": 9,
            "十": 10, "拾": 10, "百": 100, "佰": 100, "千": 1000, "仟": 1000, "萬": 10000
        ]
        
        if let directValue = numberMap[chinese] {
            return Double(directValue)
        }
        
        // 處理複合數字（如：一十五、三百二十）
        var result = 0
        var temp = 0
        var multiplier = 1
        
        for char in chinese {
            let charStr = String(char)
            
            if let value = numberMap[charStr] {
                if value >= 10 {
                    if value >= 10000 {
                        result = (result + temp) * value
                        temp = 0
                        multiplier = 1
                    } else {
                        temp *= value
                        multiplier *= value
                    }
                } else {
                    temp += value * multiplier
                }
            }
        }
        
        result += temp
        return result > 0 ? Double(result) : nil
    }
    
    // 轉換文字中的中文數字為阿拉伯數字
    private func convertChineseNumbersToArabic(_ text: String) -> String {
        var result = text
        
        // 常見的中文數字替換
        let replacements = [
            "一十": "10", "十一": "11", "十二": "12", "十三": "13", "十四": "14", "十五": "15",
            "十六": "16", "十七": "17", "十八": "18", "十九": "19", "二十": "20",
            "三十": "30", "四十": "40", "五十": "50", "六十": "60", "七十": "70", "八十": "80", "九十": "90",
            "一百": "100", "二百": "200", "三百": "300", "四百": "400", "五百": "500",
            "六百": "600", "七百": "700", "八百": "800", "九百": "900",
            "一千": "1000", "二千": "2000", "三千": "3000", "四千": "4000", "五千": "5000",
            "六千": "6000", "七千": "7000", "八千": "8000", "九千": "9000",
            "一萬": "10000", "二萬": "20000", "三萬": "30000", "四萬": "40000", "五萬": "50000",
            "六萬": "60000", "七萬": "70000", "八萬": "80000", "九萬": "90000",
            "十": "10", "一": "1", "二": "2", "三": "3", "四": "4", "五": "5",
            "六": "6", "七": "7", "八": "8", "九": "9"
        ]
        
        for (chinese, arabic) in replacements {
            result = result.replacingOccurrences(of: chinese, with: arabic)
        }
        
        return result
    }
    
    // 快速記帳方法
    func quickAddExpense(amount: Double, note: String, completion: @escaping (Bool) -> Void) {
        let accountingManager = AccountingManager.shared
        
        guard let lastBookId = accountingManager.getLastOpenedBookId() else {
            completion(false)
            return
        }
        
        // 自動分類
        let category = categorizeExpenseByNote(note)
        
        // 金額為負數表示支出
        let expenseAmount = -abs(amount)
        
        let success = accountingManager.addExpense(
            bookId: lastBookId,
            income: expenseAmount,
            date: Date(),
            note: note,
            category: category
        )
        
        completion(success)
    }
    
    private func categorizeExpenseByNote(_ note: String) -> Category {
        let lowercaseNote = note.lowercased()
        
        // 食物與娛樂 - 更全面的關鍵字
        let foodKeywords = [
            // 食物
            "吃", "喝", "餐", "飲", "食", "用餐", "點餐", "外食", "堂食", "外帶", "外賣", "外送",
            // 餐點
            "早餐", "午餐", "晚餐", "宵夜", "下午茶", "點心", "零食", "甜點", "蛋糕", "麵包", "餅乾",
            // 飲品
            "咖啡", "茶", "奶茶", "果汁", "飲料", "汽水", "可樂", "啤酒", "酒", "紅酒", "白酒", "威士忌",
            // 餐廳類型
            "餐廳", "小吃", "火鍋", "燒烤", "麵店", "飯店", "速食", "快餐", "自助餐", "buffet", "吃到飽",
            // 特定食物
            "漢堡", "薯條", "雞排", "牛排", "魚", "肉", "蔬菜", "水果", "米飯", "麵條", "湯", "粥",
            "pizza", "pasta", "牛肉麵", "拉麵", "壽司", "便當", "三明治", "沙拉", "湯麵", "乾麵",
            // 娛樂
            "電影", "ktv", "卡拉ok", "遊戲", "娛樂", "唱歌", "看電影", "玩", "遊樂園", "夜市"
        ]
        
        // 購物 - 更全面的關鍵字
        let shoppingKeywords = [
            // 購物行為
            "買", "購", "購買", "購物", "shopping", "逛街", "血拼", "採購", "選購",
            // 服飾
            "衣", "衣服", "服裝", "鞋", "鞋子", "包", "包包", "帽", "帽子", "褲", "褲子", "裙", "裙子",
            "t恤", "襯衫", "外套", "大衣", "夾克", "牛仔褲", "短褲", "長褲", "內衣", "襪子", "絲襪",
            // 美容保養
            "化妝", "保養", "化妝品", "保養品", "面膜", "精華", "乳液", "防曬", "護膚", "美容",
            "口紅", "粉底", "眼影", "睫毛膏", "指甲油", "香水", "護髮", "洗髮精", "沐浴乳",
            // 生活用品
            "清潔", "日用品", "生活用品", "衛生紙", "牙膏", "牙刷", "洗衣精", "清潔劑", "垃圾袋",
            "毛巾", "床單", "棉被", "枕頭", "家具", "裝飾", "燈", "電器", "家電",
            // 書籍文具
            "書", "書籍", "文具", "筆", "紙", "筆記本", "文件夾", "膠水", "剪刀", "計算機",
            // 電子產品
            "電子產品", "手機", "電腦", "平板", "耳機", "充電器", "線", "鍵盤", "滑鼠", "螢幕",
            "相機", "攝影", "音響", "電視", "遊戲機", "switch", "ps5", "xbox"
        ]
        
        // 交通 - 更全面的關鍵字
        let transportKeywords = [
            // 交通工具
            "車", "機車", "汽車", "腳踏車", "自行車", "摩托車", "scooter", "計程車", "計程", "taxi", "uber",
            // 大眾運輸
            "捷運", "地鐵", "公車", "公交", "巴士", "bus", "火車", "高鐵", "台鐵", "客運", "mrt",
            // 燃料
            "油", "汽油", "加油", "柴油", "gas", "petrol", "燃料",
            // 費用
            "停車", "停車費", "過路費", "路費", "高速公路", "通行費", "收費站",
            // 票券
            "票", "車票", "機票", "船票", "悠遊卡", "一卡通", "icash", "easy卡",
            // 維修
            "修車", "保養", "維修", "洗車", "換胎", "換油", "檢查", "驗車",
            // 其他
            "交通", "通勤", "出行", "移動", "載客", "搭乘", "乘坐", "開車", "騎車", "走路", "步行"
        ]
        
        // 旅遊 - 更全面的關鍵字
        let travelKeywords = [
            // 旅遊行為
            "旅", "旅遊", "旅行", "travel", "trip", "度假", "vacation", "出遊", "遊玩", "觀光", "sightseeing",
            // 住宿
            "住宿", "飯店", "酒店", "hotel", "旅館", "民宿", "青年旅舍", "airbnb", "booking",
            // 交通
            "機票", "車票", "船票", "航班", "flight", "火車票", "高鐵票", "巴士票",
            // 景點
            "景點", "名勝", "古蹟", "博物館", "美術館", "動物園", "遊樂園", "主題樂園", "迪士尼",
            // 門票
            "門票", "入場券", "通行證", "套票", "一日券", "pass", "ticket",
            // 活動
            "導覽", "tour", "行程", "活動", "體驗", "冒險", "探索", "健行", "登山", "潛水",
            // 地點
            "國外", "海外", "出國", "國內", "本土", "台灣", "日本", "韓國", "泰國", "歐洲", "美國"
        ]
        
        // 按優先級檢查（先檢查較具體的分類）
        for keyword in travelKeywords {
            if lowercaseNote.contains(keyword) {
                return .travel
            }
        }
        
        for keyword in transportKeywords {
            if lowercaseNote.contains(keyword) {
                return .transportation
            }
        }
        
        for keyword in foodKeywords {
            if lowercaseNote.contains(keyword) {
                return .foodAndEntertainment
            }
        }
        
        for keyword in shoppingKeywords {
            if lowercaseNote.contains(keyword) {
                return .shopping
            }
        }
        
        // 預設分類
        return .pocketMoney
    }
} 
