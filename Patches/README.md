# NDui 的 oUF 名條預熱補丁

本目錄保存 **NDui 現行預熱的核心差異**，供日後更新 oUF 後核對／重新套用；不是另一套預熱，也不是免修改 oUF 的外掛。遊戲仍只載入 `Interface/AddOns/NDui/Libs/oUF/ouf.lua`。本目錄不在 TOC／XML 載入鏈中，並已由 `.pkgmeta` 排除發布。

## 來源與範圍

- [oUF-nameplate-prewarm.patch](oUF-nameplate-prewarm.patch) 是唯一補丁內容來源；只修改 `Interface/AddOns/NDui/Libs/oUF/ouf.lua`，47 行新增、2 行刪除。
- 精確來源為 NDui 官方 #472：`efc159771e8d901b74d200e0d8c2534b6b38bad5`，基底 commit `5d174144b0978b8df25e843dd85f02277def7c64`，原始核心 blob `1c3ec4cc7080e41aa8172b9cb730ad3a83e2b9e9`。只擷取該提交的核心功能差異，不包含單純新增檔尾換行的 hunk。
- 保留 NDui `Prewarm(count, create)` API；沒有改用 Ruri 的單張 API，沒有把排程搬到 layout。
- **不包含**材質、刷新去重、NameOnly Tag／Untag、其他 NDui 核心 patch 或整份 oUF 更新。不能把此補丁當成恢復 NDui 所有內嵌 oUF 差異的工具。
- 目前官方 NDui 10.0.8 及本地 `1e7615466` 已有預熱，因此正常應回報「已套用」。不要為了使用本補丁先刪掉既有程式。

## 使用

需要 Python 3.7 以上及 Git，不需要額外 Python 套件。在 NDui 倉庫根目錄以 cmd.exe 執行：

```cmd
python Patches/apply-nameplate-prewarm.py --check
python Patches/apply-nameplate-prewarm.py
```

- `--check` 只檢查，不寫入、不備份。
- 已套用時直接成功結束，不重複寫入或建立備份。
- 可套用時先備份原始 bytes 到 `Tools/NameplatePrewarm/backups/`，核對 SHA-256，才用 `git apply` 修改目標；完成後再做反向完整性檢查。
- 衝突、部分套用、混用 LF／CRLF、非 UTF-8、目標或 patch 缺失、補丁範圍超出唯一核心檔時，非零退出，不強制覆蓋。LF／CRLF 原格式保留，不受全域 Git 換行設定影響。
- 工具依自身位置定位 NDui 倉庫，不依賴目前命令列目錄。不下載／更新 oUF、不修改 Git 暫存區、不 commit／push、不自動還原。
- 互動執行會等待 Enter，方便雙擊閱讀結果；自動化加 `--no-pause`，非互動輸入也不等待。

更新 oUF 前先保存既有修改，保留本目錄。更新後先 `--check`；若失敗，核對新版 `initObject`／`walkObject`、ADDED／REMOVED、AuraContainer owner／STATE 及 NDui 的其他 patch，再人工適配。**套用成功只代表文字契合，不代表新版生命週期與遊戲權限已驗證。**

## NDui layout 前提

這是「已具備 NDui 預熱 layout、更新核心後重套差異」的補丁，不是替任意舊版 NDui 一鍵升級預熱。必須同時保有：

1. `Modules/UFs/Nameplates.lua` 的 `UF.CreatePlateFrames`：只建立無 unit 外觀；不在預建階段綁 Tag、註冊 unit 事件或啟用 element。
2. `UF.CreatePlates`：有既存 Health 時重用外觀、按目前設定重定位，再建立真實名條所需的 stacking bounds、Tag 與事件；冷建仍呼叫同一外觀建立函式。
3. `Modules/UFs/Spawns.lua` 的呼叫：

   ```lua
   UF.NameplateDriver:Prewarm(30, UF.CreatePlateFrames)
   ```

4. NDui 光環建立／延後 unit 更新的既有分工。不能拆走 AuraContainer 給另一個 owner，也不能在原生 initializer 後任意操作受限制的按鈕。

核心自行延遲 2 秒開始，每 0.1 秒建立一張，戰鬥中暫停背景建立；完成一張即可取用，累計達指定數量後停止，不在消耗後無限補滿。30 不是可見名條上限。

ADDED 接管整張預建 owner，只對根框架呼叫一次 `initObject`；池空仍走正常冷建。已接管框架跟隨原生名條重用，REMOVED 不放回預熱池。Widgets／SoftTarget 及 widget-only／game-object 分支保持原流程。

## 驗證與限制

本地工具測試：

```cmd
python -B Tools/NameplatePrewarm/test-patch-tool.py
node Tools/Agent/run-tests.cjs
```

前者是忽略的本地測試，不隨本目錄發布；14 個案例在本專案 Tools 下的隔離副本測試唯讀檢查、備份 hash、重複執行、既有修改、衝突／部分套用、檔案範圍、缺檔、UTF-8、LF／CRLF 及反套逐位元還原。另唯讀取用 `D:/Github/oUF` 的官方 `14.1.0`，確認可套用並逐位元反套。實際工作樹只執行檢查，不重新套用。

後者是現有 NDui 名條／玩家減益／Tags 回歸入口。mock 不模擬完整 secret／taint、protected parent、FrameLevel 傳播與繪製；更新核心後仍需測登入／Reload、預熱未完進戰、戰鬥中首次接管、空池、不同名條型態、光環、施法、高亮與堆疊。

工具參考 [oUF_Ruri 的 Patches](https://github.com/EKE00372/oUF_Ruri/tree/fbd32a7a4094e364aee5dd93e12ab8369301d0eb/Patches)，改為 NDui 路徑與既有契約；不是直接搬入 Ruri 的核心內容。
