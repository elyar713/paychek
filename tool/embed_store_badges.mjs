import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(__dirname, "..");
const g = fs
  .readFileSync(path.join(root, "assets/help_center/badge_google_play.png"))
  .toString("base64");
const a = fs
  .readFileSync(path.join(root, "assets/help_center/badge_app_store.png"))
  .toString("base64");

const out = `import 'dart:convert';
import 'dart:typed_data';

/// PNG des badges Store embarqués (base64), fiables sur Web même si les assets ne sont pas servis.
abstract final class HelpCenterStoreBadgeBytes {
  HelpCenterStoreBadgeBytes._();

  static final Uint8List googlePlayPng =
      Uint8List.fromList(base64Decode(_googleB64));
  static final Uint8List appStorePng =
      Uint8List.fromList(base64Decode(_appleB64));

  static const String _googleB64 = r'''
${g}''';

  static const String _appleB64 = r'''
${a}''';
}
`;

const target = path.join(root, "lib/help_center/help_center_store_badge_bytes.dart");
fs.writeFileSync(target, out, "utf8");
console.log("Wrote", target, g.length, a.length);
