from PIL import Image
from pathlib import Path
import shutil

assets_dir = Path(r"C:\Users\elyar\.cursor\projects\c-Users-elyar-mon-app-finder\assets")
out_dir = Path(r"C:\Users\elyar\mon_app_finder\docs\presentation\assets")
out_dir.mkdir(parents=True, exist_ok=True)

# Map: timestamp fragment -> output name
mapping = {
    "154136": "ui-cooldown.png",
    "154712": "ui-exit-sl.png",
    "154223": "ui-session.png",
    "154213": "ui-max-loss-trade.png",
    "154255": "ui-discipline-level.png",
    "154336": "ui-daily-loss.png",
    "154235": "ui-overview-blocked.png",
    "154306": "ui-overview-blocked-b.png",
    "154247": "ui-discipline-level-b.png",
}

found = []
for p in assets_dir.glob("*.png"):
    name = p.name
    for key, out_name in mapping.items():
        if key in name:
            img = Image.open(p).convert("RGB")
            dest = out_dir / out_name
            img.save(dest, quality=90)
            found.append((out_name, img.size))
            print("OK", out_name, img.size)

print("count", len(found))
