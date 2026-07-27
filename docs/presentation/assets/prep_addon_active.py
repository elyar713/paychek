from PIL import Image
from pathlib import Path

src = Path(
    r"C:\Users\elyar\.cursor\projects\c-Users-elyar-mon-app-finder\assets"
    r"\c__Users_elyar_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images_Capture_d__cran_2026-07-27_162238-ebc508d8-de55-4ab3-acf9-99d62c0f7ba3.png"
)
out_dir = Path(r"C:\Users\elyar\mon_app_finder\docs\presentation\assets")
img = Image.open(src).convert("RGB")
w, h = img.size
print("size", w, h)

# Full context (panel + chart) — best for slide 06
ctx = img.crop((int(w * 0.01), int(h * 0.03), int(w * 0.78), int(h * 0.97)))
ctx_path = out_dir / "06-addon-rules-active.png"
ctx.save(ctx_path, quality=90)
print("ctx", ctx.size, ctx_path)

# Panel only
panel = img.crop((int(w * 0.012), int(h * 0.05), int(w * 0.24), int(h * 0.94)))
panel_path = out_dir / "06-addon-panel-rules-active.png"
panel.save(panel_path, quality=92)
print("panel", panel.size, panel_path)
