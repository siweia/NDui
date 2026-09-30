"""套用 NDui 名條預熱補丁；使用 Python 3 與 Git，不下載或同步 oUF。"""

import argparse
from datetime import datetime
import hashlib
import os
from pathlib import Path
import shutil
import subprocess
import sys
import traceback


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="只檢查狀態，不修改檔案或建立備份")
    parser.add_argument("--no-pause", action="store_true", help="執行結束後不等待 Enter，供自動化呼叫")
    args = parser.parse_args()

    root = Path(__file__).resolve().parents[1]
    target = root / "Interface/AddOns/NDui/Libs/oUF/ouf.lua"
    patch_path = root / "Patches/oUF-nameplate-prewarm.patch"
    git = shutil.which("git")
    if not git:
        print("找不到 Git；請先安裝 Git 並讓 git 可從命令列執行。", file=sys.stderr)
        return 1
    if not target.is_file() or not patch_path.is_file():
        print("缺少 Interface/AddOns/NDui/Libs/oUF/ouf.lua 或 Patches/oUF-nameplate-prewarm.patch。", file=sys.stderr)
        return 1

    # 不追隨指向專案外的目標／備份目錄連結。
    target.resolve().relative_to(root)
    backup_dir = root / "Tools/NameplatePrewarm/backups"
    backup_dir.resolve().relative_to(root)

    original = target.read_bytes()
    original.decode("utf-8")
    crlf = original.count(b"\r\n")
    if crlf and crlf != original.count(b"\n"):
        print("核心檔混用 LF 與 CRLF；請先核對換行格式，停止套用。", file=sys.stderr)
        return 1
    patch = patch_path.read_bytes()
    patch.decode("utf-8")

    def apply_git(*options):
        # 固定工作目錄與原檔換行；不讓全域 autocrlf 改寫無關行。
        return subprocess.run(
            [git, "-c", "core.autocrlf=" + ("true" if crlf else "false"),
             "-c", "core.eol=lf", "apply", "--no-index", *options, "-"],
            cwd=root, input=patch, capture_output=True, check=False,
            env=dict(os.environ, GIT_CEILING_DIRECTORIES=str(root.parent)),
        )

    # 此工具只維護單檔補丁，避免補丁被擴充後連帶修改其他檔案。
    stats = apply_git("--numstat", "-z")
    entries = stats.stdout.rstrip(b"\0").split(b"\0")
    if stats.returncode or len(entries) != 1 or entries[0].rsplit(b"\t", 1)[-1] != b"Interface/AddOns/NDui/Libs/oUF/ouf.lua":
        print("補丁無效，或修改範圍不是唯一的 Interface/AddOns/NDui/Libs/oUF/ouf.lua。", file=sys.stderr)
        return 1

    if apply_git("--reverse", "--check").returncode == 0:
        print("已套用：預熱補丁完整存在，無須修改。")
        return 0

    check = apply_git("--check")
    if check.returncode:
        print("無法套用：核心與補丁不相符，可能是部分套用或上游改動；請人工核對。", file=sys.stderr)
        print(check.stderr.decode("utf-8", errors="replace").strip(), file=sys.stderr)
        return 1
    if args.check:
        print("可套用：補丁檢查通過；尚未修改檔案或建立備份。")
        return 0

    # 備份保存原始位元組；時間戳避免覆寫先前同步版本的備份。
    digest = hashlib.sha256(original).hexdigest()
    backup_dir.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now().strftime("%Y%m%d-%H%M%S-%f")
    backup = backup_dir / f"ouf-{stamp}-{digest[:12]}.lua"
    with backup.open("xb") as stream:
        stream.write(original)
    if hashlib.sha256(backup.read_bytes()).hexdigest() != digest:
        print(f"備份雜湊不符，停止套用：{backup}", file=sys.stderr)
        return 1
    print(f"備份：{backup}")
    print(f"原檔 SHA-256：{digest}")

    if target.read_bytes() != original:
        print("檢查期間核心檔已變更，停止套用；請重新執行。", file=sys.stderr)
        return 1
    result = apply_git()
    if result.returncode:
        print("套用失敗，請依 Git 訊息核對；原始檔已備份。", file=sys.stderr)
        print(result.stderr.decode("utf-8", errors="replace").strip(), file=sys.stderr)
        return 1
    if apply_git("--reverse", "--check").returncode:
        print("套用後完整性檢查失敗；請停止更新並使用備份核對。", file=sys.stderr)
        return 1

    print("完成：預熱補丁已套用，反向完整性檢查通過。")
    print("仍須執行名條生命週期測試及遊戲內驗證。")
    return 0


if __name__ == "__main__":
    # 命令列與重導向輸出統一 UTF-8；檔案內容也只按 UTF-8 處理。
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")
    try:
        sys.exit(main())
    except (OSError, UnicodeError, ValueError) as error:
        print(f"處理失敗：{error}", file=sys.stderr)
        sys.exit(1)
    except Exception:
        traceback.print_exc()
        sys.exit(1)
    finally:
        # 雙擊或從終端執行時保留結果；管線／非互動呼叫不等待輸入。
        if sys.stdin.isatty() and "--no-pause" not in sys.argv[1:]:
            try:
                input("\n執行結束，按 Enter 關閉視窗……")
            except (EOFError, KeyboardInterrupt):
                pass
