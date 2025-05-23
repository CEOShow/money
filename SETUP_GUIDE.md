# Apple Watch 記帳 App 功能設置指南

## 📋 功能清單

本次更新為您的 Apple Watch 記帳 App 添加了以下五大功能：

1. **🏷️ 小工具 (Widget)**
2. **📊 消費明細百分比統計**
3. **💰 預算管理**
4. **🎨 背景主題自訂**
5. **⚡ 快速記帳（含語音功能）**

## ⚠️ 系統需求

- **watchOS 10.0 或更新版本**
- **iOS 17.0 或更新版本**（配對 iPhone）
- **Xcode 15.0 或更新版本**（開發環境）

---

## 🔧 Xcode 設置步驟

### 1. 將新文件添加到專案

確保以下文件已添加到您的 watchOS 目標：

**核心功能文件：**
- `ThemeManager.swift`
- `ThemeSettingsView.swift`
- `ExpenseStatsView.swift`
- `BudgetView.swift`
- `QuickExpenseView.swift`
- `VoiceExpenseView.swift`
- `SiriShortcutsManager.swift`

**Widget 文件：**
- `WidgetKit/MoneyWidget.swift`

### 2. Widget Extension 設置

1. 在 Xcode 中選擇 **File > New > Target**
2. 選擇 **watchOS > Widget Extension**
3. 命名為 `MoneyWidgetExtension`
4. 將 `MoneyWidget.swift` 添加到 Widget Extension target

### 3. Info.plist 權限設置

在 `money Watch App-Info.plist` 中添加：

```xml
<key>NSMicrophoneUsageDescription</key>
<string>此App需要使用麥克風來進行語音記帳功能</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>此App需要語音識別來解析記帳語音指令</string>
```

### 4. Capabilities 設置

1. 選擇專案 > watchOS Target
2. 前往 **Signing & Capabilities**
3. 添加以下 Capabilities：
   - **WidgetKit Extension** (如果使用 Widget)
   - **Siri** (如果要支援 Siri 整合)

---

## 🚀 功能使用指南

### 小工具設置
1. 在 Apple Watch 上長按錶面
2. 點擊「編輯」
3. 滑動到「複雜功能」
4. 選擇「記帳」小工具

### 主題更換
1. 打開 App
2. 點擊右下角齒輪圖示
3. 選擇「主題設定」
4. 選擇喜歡的背景主題

### 預算設置
1. 在帳本頁面點擊左上角信用卡圖示
2. 點擊「+」新增預算
3. 選擇分類、設定金額和週期
4. 點擊「儲存預算」

### 快速記帳
**方法 1 - 快速按鈕：**
1. 點擊閃電圖示
2. 選擇常用金額或自訂金額
3. 選擇分類
4. 添加備註（可選）
5. 確認記帳

**方法 2 - 語音記帳：**
1. 點擊麥克風圖示
2. 點擊「開始聽寫」
3. 說出如「記帳 100 元午餐」
4. 確認解析結果
5. 點擊「確認記帳」

### 統計查看
1. 點擊圓餅圖圖示
2. 查看分類支出百分比
3. 查看圓餅圖和詳細列表

---

## 🎯 按鈕功能說明

### 主界面按鈕佈局：

**第一排：**
- ⚙️ **齒輪** - 切換顯示模式（餘額/收入/支出）
- 📊 **圓餅圖** - 支出統計分析
- 🎤 **麥克風** - 語音記帳

**第二排：**
- ⚡ **閃電** - 快速記帳
- ➕ **加號** - 詳細記帳

**工具列：**
- 💳 **信用卡**（左上）- 預算管理
- 📋 **列表**（右上）- 明細記錄

**主選單：**
- ⚙️ **設定** - 主題設定、語言、關於

---

## 🔍 故障排除

### 已修復的常見問題：

**Q: 編譯錯誤 - 'Preview(_:as:widget:timeline:)' is only available in watchOS 10.0**
A: ✅ 已修復 - Widget 預覽語法已更新為向後兼容的 PreviewProvider 格式

**Q: 編譯錯誤 - Type 'UIColor' has no member 'systemGray4/5/6'**
A: ✅ 已修復 - 所有 systemGray 顏色已替換為 Color.gray.opacity() 

**Q: 編譯錯誤 - 'SegmentedPickerStyle' is unavailable in watchOS**
A: ✅ 已修復 - 所有分段控制器已替換為適合 Apple Watch 的按鈕網格選擇

**Q: 編譯錯誤 - TextField keyboardType 和 RoundedBorderTextFieldStyle 在 watchOS 不可用**
A: ✅ 已修復 - 移除 keyboardType 修飾符，使用 PlainTextFieldStyle + 自定義樣式

**Q: 編譯錯誤 - Ambiguous use of 'init' 在 ExpenseInputView**
A: ✅ 已修復 - 明確化 Expense 和 Text 初始化，移除歧義的參數調用

**Q: 編譯錯誤 - Cannot find type 'AddExpenseIntentHandling'**
A: ✅ 已修復 - 移除了複雜的 Siri Intent 整合，使用簡化的語音處理

**Q: 缺少 @available 註釋錯誤**
A: ✅ 已修復 - 所有新的 View 結構都已添加 @available(watchOS 10.0, *) 註釋

### 其他常見問題：

**Q: Widget 不顯示資料？**
A: 確保 Widget Extension 有正確的 App Group 設置

**Q: 語音記帳無法使用？**
A: 檢查麥克風權限是否已開啟

**Q: 主題不會保存？**
A: 確保 UserDefaults 有寫入權限

**Q: 預算進度不更新？**
A: 檢查日期計算邏輯和資料庫查詢

### 編譯錯誤處理：

1. **找不到模組錯誤**：確保所有文件都添加到正確的 target
2. **權限錯誤**：檢查 Info.plist 設置
3. **Widget 錯誤**：確保 Widget Extension 正確配置
4. **版本兼容性錯誤**：確保所有新功能都有適當的 @available 註釋

---

## 📱 用戶體驗提升

### 設計特色：
- **直觀操作**：針對 Apple Watch 小螢幕優化
- **快速記帳**：常用金額一鍵選擇
- **智能分類**：自動分析消費類型
- **視覺回饋**：清晰的顏色和圖示系統
- **個性化**：多種主題選擇

### 效能優化：
- 資料庫查詢優化
- UI 更新最小化
- 記憶體使用控制
- 電池效能考量

---

## 🔄 未來擴展

可以進一步添加的功能：
- iCloud 同步
- 更多分類自訂
- 匯出報表功能
- Apple Pay 整合
- 更多 Widget 樣式
- Siri Shortcuts 完整支援

---

## ⌚ Apple Watch 專用 UI 設計

### 已針對 watchOS 優化的控件：

**1. 選擇控件** 🔘
- **原本**: SegmentedPickerStyle（不支援 watchOS）
- **優化後**: 按鈕網格選擇，更適合小螢幕操作
- **位置**: 主題設定背景類型選擇、預算週期選擇

**2. 顏色系統** 🎨  
- **原本**: UIColor.systemGray4/5/6（部分版本不支援）
- **優化後**: Color.gray.opacity()，確保跨版本兼容
- **效果**: 統一的半透明灰色背景

**3. 文字輸入** ⌨️
- **原本**: RoundedBorderTextFieldStyle + keyboardType（watchOS 不支援）
- **優化後**: PlainTextFieldStyle + 自定義背景樣式
- **位置**: 金額輸入、備註輸入、預算設定

**4. Widget 設計** 📱
- **三種樣式**: 圓形、矩形、內聯
- **智能顯示**: 自動格式化金額（超過萬元顯示「萬」）
- **即時更新**: 每小時自動刷新數據

**5. 操作流程** ⚡
- **快速記帳**: 常用金額按鈕 + 分類輪選
- **語音記帳**: 系統聽寫 + 智能解析
- **預算監控**: 進度條 + 顏色警示

### Apple Watch 交互設計原則：

- ✅ **大按鈕**: 適合手指觸控的按鈕尺寸
- ✅ **簡化選項**: 減少複雜的選擇操作  
- ✅ **即時反饋**: 清晰的視覺狀態變化
- ✅ **快速完成**: 最少點擊次數完成操作
- ✅ **滾動友好**: 適合 Digital Crown 滾動的布局

---

**🎉 恭喜！您的 Apple Watch 記帳 App 現在功能更加豐富實用！** 