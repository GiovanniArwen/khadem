/**
 * delete-all-users.js
 *
 * بيمسح كل حسابات Firebase Authentication في المشروع.
 * ⚠️ مفيش تراجع. استخدمه على بيانات تجريبية بس.
 *
 * الاستخدام (من فولدر functions):
 *   node delete-all-users.js
 *
 * محتاج ملف serviceAccountKey.json جنبه (اقرأ الخطوات في الرد).
 */

const admin = require("firebase-admin");
const readline = require("node:readline/promises");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const auth = admin.auth();

async function main() {
  console.log(`Project: ${serviceAccount.project_id}`);

  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });
  const answer = await rl.question(
    "This will delete ALL Authentication users. Type DELETE to continue: ",
  );
  rl.close();

  if (answer.trim() !== "DELETE") {
    console.log("Cancelled.");
    return;
  }

  let total = 0;

  for (;;) {
    const { users } = await auth.listUsers(1000);
    if (users.length === 0) break;

    const result = await auth.deleteUsers(users.map((user) => user.uid));
    total += result.successCount;

    if (result.failureCount > 0) {
      console.log("Some users failed to delete:", result.errors);
      break;
    }
  }

  console.log(`Deleted ${total} users.`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
