# Safeguard Windows download

Public download URL (licence page **Télécharger Safeguard**):

`https://paychek.pro/downloads/PaychekSafeguard-Windows.zip`

Served from Firebase Hosting (`web/downloads/` → `build/web/downloads/`).

## What’s in the zip (user-facing root)

Only these files matter for users:

- **1-Read-Me.txt** — 5 short steps (English)
- **2-Install-Addon.bat** — install NinjaTrader 8 addon (close NT → run → reopen → F5)
- **3-Open-Safeguard.bat** — open Safeguard UI + enter PAYC code (creates Desktop shortcut on first run)
- **4-Uninstall-Addon.bat** — remove addon (close NT → run → reopen → F5)
- **_technique\\** — technical only (`runtime`, `src`, Ninja scripts). Do not open.

There is **no** `PaychekSafeguard.exe`. Users only use the numbered `.bat` files.

Activation stays **code-only** in the browser UI (`PAYC-…` from the licence page).

**Users:** 1) Unzip 2) Close NT → **2-Install-Addon.bat** → F5 3) **3-Open-Safeguard.bat** + PAYC 4) NT → New → Paychek Safeguard.

Do **not** open `http://127.0.0.1:8080` alone — the server must be running via **3-Open-Safeguard.bat**.

## Update the hosting file (each kit)

1. Build from `tradingview-hybrid-automation`:

```powershell
cd ..\tradingview-hybrid-automation
.\scripts\build-desktop-exe.ps1
# Or, addon-only refresh:
.\scripts\rebuild-ninja-addon-zip.ps1
```

This writes `dist\PaychekSafeguard-Windows.zip`.

2. Copy to the stable hosting filename:

```powershell
New-Item -ItemType Directory -Force -Path web\downloads | Out-Null
Copy-Item -Force `
  ..\tradingview-hybrid-automation\dist\PaychekSafeguard-Windows.zip `
  web\downloads\PaychekSafeguard-Windows.zip
```

3. Deploy hosting (see `scripts/deploy_web_hosting_only.ps1`) so `/downloads/PaychekSafeguard-Windows.zip` updates.

Bump the `?v=` cache-bust query on download links in `safeguard.html`, `licence.html`, and `web/js/safeguard-page.js` when shipping a new kit.

The zip is gitignored (`web/downloads/*.zip`); keep a local copy for deploys.

## Optional: publish to GitHub Releases

Requires `gh auth login`:

```powershell
gh release create safeguard-windows `
  --repo elyar713/paychek `
  --title "Safeguard Windows" `
  --notes "Paychek Safeguard for NinjaTrader 8 (2-Install-Addon.bat + 3-Open-Safeguard.bat)." `
  .\PaychekSafeguard-Windows.zip
```

To replace the asset on an existing release:

```powershell
gh release upload safeguard-windows .\PaychekSafeguard-Windows.zip `
  --repo elyar713/paychek --clobber
```
