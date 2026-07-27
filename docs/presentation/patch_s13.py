from pathlib import Path

p = Path(r"C:\Users\elyar\mon_app_finder\docs\presentation\paychek-safeguard-fr.html")
t = p.read_text(encoding="utf-8")
start = t.find("<!-- 13 Cooldown -->")
end = t.find("<!-- 14 Max loss trade -->")
if start < 0 or end < 0:
    raise SystemExit(f"markers not found start={start} end={end}")

new = """    <!-- 13 Cooldown -->
    <section class="slide" id="s13">
      <p class="kicker">Règle · Trade cooldown</p>
      <div class="grid-2">
        <div>
          <h2>Intervalle entre trades</h2>
          <ul class="clean" style="margin-top:10px;">
            <li>Durée configurable (ex. 15 min)</li>
            <li><strong>After loss</strong> ou <strong>Every trade</strong></li>
            <li>Visible dans NinjaTrader après Save / Enabled</li>
            <li>Anti revenge trading</li>
          </ul>
        </div>
        <div class="media">
          <img src="assets/ui-cooldown.png" alt="Trade cooldown settings" />
        </div>
      </div>
      <div class="footer-meta"><span>Paychek Safeguard</span><span>13</span></div>
    </section>

"""
p.write_text(t[:start] + new + t[end:], encoding="utf-8")
print("cooldown slide updated")
