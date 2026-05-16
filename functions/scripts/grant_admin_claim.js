/**
 * Accorde une fois le custom claim Firebase `{ admin: true }` à un utilisateur.
 * L’admin Paychek lit ce claim dans lib/admin/admin_auth_gate.dart.
 *
 * 1. Console Firebase → Paramètres du projet → Comptes de service →
 *    « Générer une nouvelle clé privée » → enregistrer le JSON (NE PAS commit).
 *
 * 2. Récupère l’UID : Authentication → Utilisateurs → colonne « ID utilisateur ».
 *
 * PowerShell (Windows) :
 *   $env:GOOGLE_APPLICATION_CREDENTIALS="C:\chemin\compte-service.json"
 *   cd c:\Users\elyar\mon_app_finder\functions
 *   node scripts\grant_admin_claim.js TON_UID_ICI
 *
 * Après succès : se déconnecter / se reconnecter sur la console admin.
 *
 * Comptes supplémentaires : si ton adresse figure dans PAYCHEK_SUPERADMIN_EMAILS
 * dans `functions/index.js`, utilise l’onglet « Équipe admin » avec la fonction
 * `managePaychekStaffAdmin`.
 */

const admin = require("firebase-admin");

const uid = process.argv[2]?.trim();

if (!uid) {
  console.error("Usage: node scripts/grant_admin_claim.js <UID_UTILISATEUR>");
  process.exit(1);
}

if (
  !process.env.GOOGLE_APPLICATION_CREDENTIALS ||
  `${process.env.GOOGLE_APPLICATION_CREDENTIALS}`.trim() === ""
) {
  console.error(
    "Variable d'environnement GOOGLE_APPLICATION_CREDENTIALS manquante : " +
      "elle doit pointer vers le fichier JSON du compte de service.",
  );
  process.exit(1);
}

async function main() {
  admin.initializeApp();
  await admin.auth().setCustomUserClaims(uid, {admin: true});
  const u = await admin.auth().getUser(uid);
  console.log("OK — claim admin accordé.");
  console.log("  UID   :", u.uid);
  console.log("  Email :", u.email ?? "(non renseigné)");
  console.log(
    "",
  );
  console.log(
    "L’utilisateur doit se déconnecter puis se reconnecter sur la console admin " +
      "(pour recharger un jeton JWT contenant ce claim).",
  );
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
