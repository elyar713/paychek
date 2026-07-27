from PIL import Image
from pathlib import Path

src = Path(
    r"C:\Users\elyar\.cursor\projects\c-Users-elyar-mon-app-finder\assets"
    r"\c__Users_elyar_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images_Capture_d__cran_2026-07-27_154306-948be8e4-236b-4452-952f-3263621c3dbc.png"
)
out_dir = Path(r"C:\Users\elyar\mon_app_finder\docs\presentation\assets")
img = Image.open(src).convert("RGB")
# Soft crop: drop excess empty margins if any
w, h = img.size
# keep nearly full UI
out = out_dir / "07-safeguard-ui-blocked.png"
img.save(out, quality=90)
print(w, h, out)
