from PIL import Image
from pathlib import Path

src = Path(
    r"C:\Users\elyar\.cursor\projects\c-Users-elyar-mon-app-finder\assets"
    r"\c__Users_elyar_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images_Capture_d__cran_2026-07-27_162557-a0fec504-6776-4030-ba98-e9723f6d2b94.png"
)
out_dir = Path(r"C:\Users\elyar\mon_app_finder\docs\presentation\assets")
img = Image.open(src).convert("RGB")
w, h = img.size
print("size", w, h)

ctx = img.crop((int(w * 0.01), int(h * 0.03), int(w * 0.80), int(h * 0.97)))
out = out_dir / "06b-addon-blocked-zone.png"
ctx.save(out, quality=90)
print("saved", ctx.size, out)
