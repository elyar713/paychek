from PIL import Image, ImageDraw
from pathlib import Path

src = Path(
    r"C:\Users\elyar\.cursor\projects\c-Users-elyar-mon-app-finder\assets"
    r"\c__Users_elyar_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images_Capture_d__cran_2026-07-24_190041-1791cb96-bb4a-410c-95a3-e07d7c9d88ec.png"
)
out_dir = Path(r"C:\Users\elyar\mon_app_finder\docs\presentation\assets")
out_dir.mkdir(parents=True, exist_ok=True)

img = Image.open(src).convert("RGB")
w, h = img.size
print("full", w, h)

# Discipline panel is on the left (~280-320px wide on typical NT overlay)
# Calibrate from known layout: panel ~ left 0.02 to 0.22 of width, top ~0.08 to 0.92
x1 = int(w * 0.012)
x2 = int(w * 0.225)
y1 = int(h * 0.055)
y2 = int(h * 0.93)
panel = img.crop((x1, y1, x2, y2))
panel_path = out_dir / "06-addon-discipline-connected.png"
panel.save(panel_path, quality=92)
print("panel", panel.size, panel_path)

# Context crop: panel + part of chart (no need full Chart Trader)
ctx = img.crop((int(w * 0.01), int(h * 0.04), int(w * 0.72), int(h * 0.96)))
ctx_path = out_dir / "06-addon-context-chart.png"
ctx.save(ctx_path, quality=90)
print("context", ctx.size, ctx_path)

# Full copy lightly compressed for archive
full_path = out_dir / "06-addon-full.png"
img.save(full_path, quality=85)
print("full saved", full_path)
