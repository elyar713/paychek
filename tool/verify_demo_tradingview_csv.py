#!/usr/bin/env python3
"""Vérifie rapidement le CSV démo TradingView (paires open/close, stats par jour)."""
from __future__ import annotations

import csv
import sys
from collections import defaultdict
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT = ROOT / "docs/marketing/paychek_demo_tradingview_juin_2026.csv"

POINT = {"XAUUSD": 1.0, "EURUSD": 1.0, "NAS100": 20.0, "US500": 50.0}


def parse_dt(s: str) -> datetime | None:
    s = s.strip()
    if not s:
        return None
    for fmt in ("%Y-%m-%d %H:%M:%S", "%d/%m/%Y %H:%M:%S"):
        try:
            return datetime.strptime(s, fmt)
        except ValueError:
            pass
    return None


def profit(sym: str, side: str, open_p: float, close_p: float, qty: float) -> float:
    pv = POINT.get(sym, 1.0)
    if side == "Buy":
        return (close_p - open_p) * pv * qty
    return (open_p - close_p) * pv * qty


def main() -> None:
    path = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT
    rows = list(csv.DictReader(path.open(encoding="utf-8-sig")))
    open_exec: dict[str, dict] = {}
    trades: list[dict] = []

    for r in rows:
        sym = r["Symbol"].strip()
        side = r["Side"].strip()
        qty = float(r["Qty"])
        price = float(r["Fill price"])
        placed = parse_dt(r.get("Placed time", ""))
        closed = parse_dt(r.get("Closing time", ""))
        oid = r["Order ID"].strip()

        if placed and not closed:
            open_exec.setdefault(sym, []).append(
                {"side": side, "qty": qty, "price": price, "time": placed, "oid": oid}
            )
        elif closed and not placed:
            bucket = open_exec.get(sym, [])
            opp = "Buy" if side == "Sell" else "Sell"
            idx = next((i for i, o in enumerate(bucket) if o["side"] == opp), None)
            if idx is None:
                continue
            o = bucket.pop(idx)
            matched = min(qty, o["qty"])
            pnl = profit(sym, o["side"], o["price"], price, matched)
            trades.append(
                {
                    "day": closed.date(),
                    "sym": sym,
                    "pnl": pnl,
                    "win": pnl > 0,
                }
            )

    by_day: dict = defaultdict(list)
    for t in trades:
        by_day[t["day"]].append(t)

    print(f"File: {path}")
    print(f"Closed trades: {len(trades)}")
    wins = sum(1 for t in trades if t["win"])
    print(f"Overall WR: {wins}/{len(trades)} = {100*wins/len(trades):.1f}%")
    print(f"Net PnL (approx): ${sum(t['pnl'] for t in trades):,.2f}")
    print("\nPar jour (n = trades, WR = winrate):")
    for day in sorted(by_day):
        ts = by_day[day]
        w = sum(1 for t in ts if t["win"])
        n = len(ts)
        tag = "discipline" if n <= 3 else ("modéré" if n <= 5 else "overtrade")
        print(f"  {day}  n={n}  WR={100*w/n:.0f}%  ({tag})")


if __name__ == "__main__":
    main()
