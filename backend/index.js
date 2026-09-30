import { importPKCS8, importX509, SignJWT, jwtVerify } from "jose";

const FCM_SCOPE = "https://www.googleapis.com/auth/firebase.messaging";
const GOOGLE_TOKEN_URL = "https://oauth2.googleapis.com/token";
const FIREBASE_CERTS_URL =
  "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com";

let certCache = null;
let certCacheExpiresAt = 0;

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    },
  });
}

function corsResponse() {
  return new Response(null, {
    status: 204,
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type, Authorization",
    },
  });
}

/*
 * تحويل Firestore REST Value إلى JavaScript value
 */
function firestoreValue(value) {
  if (!value) return null;

  if ("stringValue" in value) return value.stringValue;
  if ("integerValue" in value) return Number(value.integerValue);
  if ("doubleValue" in value) return value.doubleValue;
  if ("booleanValue" in value) return value.booleanValue;
  if ("timestampValue" in value) return value.timestampValue;
  if ("nullValue" in value) return null;

  if ("arrayValue" in value) {
    return (value.arrayValue.values || []).map(firestoreValue);
  }

  if ("mapValue" in value) {
    const result = {};

    for (const [key, val] of Object.entries(
      value.mapValue.fields || {}
    )) {
      result[key] = firestoreValue(val);
    }

    return result;
  }

  return null;
}

function firestoreFieldsToObject(fields = {}) {
  const result = {};

  for (const [key, value] of Object.entries(fields)) {
    result[key] = firestoreValue(value);
  }

  return result;
}

/*
 * قراءة Firebase Service Account
 */
function getServiceAccount(env) {
  if (!env.FIREBASE_SERVICE_ACCOUNT_JSON) {
    throw new Error("SERVICE_ACCOUNT_SECRET_NOT_AVAILABLE");

  }

  return JSON.parse(env.FIREBASE_SERVICE_ACCOUNT_JSON);
}

/*
 * إنشاء Google OAuth access token
 *
 * ده بيستخدم Service Account لتفويض إرسال FCM
 */
async function getGoogleAccessToken(env) {
  const serviceAccount = getServiceAccount(env);

  const privateKey = await importPKCS8(
    serviceAccount.private_key,
    "RS256"
  );

  const now = Math.floor(Date.now() / 1000);

  const assertion = await new SignJWT({
    scope: FCM_SCOPE,
  })
    .setProtectedHeader({
      alg: "RS256",
      typ: "JWT",
    })
    .setIssuer(serviceAccount.client_email)
    .setSubject(serviceAccount.client_email)
    .setAudience(GOOGLE_TOKEN_URL)
    .setIssuedAt(now)
    .setExpirationTime(now + 3600)
    .sign(privateKey);

  const response = await fetch(GOOGLE_TOKEN_URL, {
    method: "POST",
    headers: {
      "Content-Type":
        "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      grant_type:
        "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(
      `Google OAuth error: ${JSON.stringify(data)}`
    );
  }

  return data.access_token;
}

/*
 * الحصول على Google public certificates
 * لاستخدامها في التحقق من Firebase ID Token
 */
async function getFirebaseCertificates() {
  const now = Date.now();

  if (certCache && now < certCacheExpiresAt) {
    return certCache;
  }

  const response = await fetch(FIREBASE_CERTS_URL);

  if (!response.ok) {
    throw new Error(
      `Failed to fetch Firebase certificates: ${response.status}`
    );
  }

  const certificates = await response.json();

  const cacheControl =
    response.headers.get("cache-control") || "";

  const maxAgeMatch =
    cacheControl.match(/max-age=(\d+)/);

  const maxAge = maxAgeMatch
    ? Number(maxAgeMatch[1])
    : 3600;

  certCache = certificates;
  certCacheExpiresAt =
    now + Math.max(60, maxAge - 60) * 1000;

  return certificates;
}

/*
 * التحقق من Firebase ID Token
 */
async function verifyFirebaseIdToken(idToken, projectId) {
  const parts = idToken.split(".");

  if (parts.length !== 3) {
    throw new Error("Invalid Firebase ID token");
  }

  const header = JSON.parse(
    atob(parts[0].replace(/-/g, "+").replace(/_/g, "/"))
  );

  const certificates = await getFirebaseCertificates();

  const certificate = certificates[header.kid];

  if (!certificate) {
    throw new Error(
      "Firebase signing key not found"
    );
  }

  const publicKey = await importX509(
    certificate,
    "RS256"
  );

  const { payload } = await jwtVerify(
    idToken,
    publicKey,
    {
      algorithms: ["RS256"],
      audience: projectId,
      issuer: `https://securetoken.google.com/${projectId}`,
    }
  );

  if (!payload.sub) {
    throw new Error("Firebase token has no UID");
  }

  return payload;
}

/*
 * قراءة Document من Firestore
 */
async function getFirestoreDocument(
  accessToken,
  projectId,
  path
) {
  const url =
    `https://firestore.googleapis.com/v1/projects/` +
    `${projectId}/databases/(default)/documents/${path}`;

  const response = await fetch(url, {
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
  });

  if (response.status === 404) {
    return null;
  }

  const data = await response.json();

  if (!response.ok) {
    throw new Error(
      `Firestore read error: ${JSON.stringify(data)}`
    );
  }

  return data;
}

/*
 * قراءة FCM Tokens الخاصة بالمستخدم
 */
async function getUserTokens(
  accessToken,
  projectId,
  uid
) {
  const url =
    `https://firestore.googleapis.com/v1/projects/` +
    `${projectId}/databases/(default)/documents/` +
    `users/${uid}/fcmTokens`;

  const response = await fetch(url, {
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
  });

  if (!response.ok) {
    const data = await response.text();

    throw new Error(
      `FCM tokens read error: ${data}`
    );
  }

  const data = await response.json();

  const documents = data.documents || [];

  return documents
    .map((doc) => {
      const fields =
        firestoreFieldsToObject(doc.fields || {});

      return fields.token;
    })
    .filter(
      (token) =>
        typeof token === "string" &&
        token.length > 0
    );
}

/*
 * إرسال إشعار FCM
 */
async function sendFCM({
  accessToken,
  projectId,
  token,
  senderName,
  text,
  senderId,
  receiverId,
  chatId,
  messageId,
}) {
  const url =
    `https://fcm.googleapis.com/v1/projects/` +
    `${projectId}/messages:send`;

  const body = {
    message: {
      token,

      notification: {
        title: senderName,
        body: text,
      },

      data: {
        type: "chat",
        senderId,
        receiverId,
        chatId,
        messageId,
        senderName,
      },

      android: {
        notification: {
          channelId: "chat_messages",
          sound: "default",
        },
      },

      apns: {
        payload: {
          aps: {
            sound: "default",
          },
        },
      },
    },
  };

  const response = await fetch(url, {
    method: "POST",

    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },

    body: JSON.stringify(body),
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(
      `FCM error: ${JSON.stringify(data)}`
    );
  }

  return data;
}

/*
 * Worker
 */
export default {
  async fetch(request, env) {
    try {
      if (request.method === "OPTIONS") {
        return corsResponse();
      }

      /*
       * اختبار السيرفر
       */
if (
  request.method === "GET" &&
  new URL(request.url).pathname === "/health"
) {
  return json({
    success: true,
    message: "Khadem Cloudflare Worker is running",
    hasServiceAccount:
      !!env.FIREBASE_SERVICE_ACCOUNT_JSON,
    envKeys: Object.keys(env),
  });
}
      /*
       * إرسال Chat Notification
       */
      if (
        request.method === "POST" &&
        new URL(request.url).pathname ===
        "/send-chat-notification"
      ) {
        const authHeader =
          request.headers.get("Authorization") || "";

        if (!authHeader.startsWith("Bearer ")) {
          return json(
            {
              success: false,
              message:
                "Missing Firebase ID token",
            },
            401
          );
        }

        const idToken =
          authHeader.substring(7);

        const body = await request.json();

        const {
          chatId,
          messageId,
          text,
        } = body;

        if (!chatId || !messageId || !text) {
          return json(
            {
              success: false,
              message:
                "chatId, messageId and text are required",
            },
            400
          );
        }

        const serviceAccount =
          getServiceAccount(env);

        const projectId =
          serviceAccount.project_id;

        /*
         * التحقق من المستخدم
         */
        const decodedToken =
          await verifyFirebaseIdToken(
            idToken,
            projectId
          );

        const senderUid =
          decodedToken.sub;

        /*
         * Google access token
         */
        const accessToken =
          await getGoogleAccessToken(env);

        /*
         * قراءة المحادثة
         */
        const chatDocument =
          await getFirestoreDocument(
            accessToken,
            projectId,
            `chats/${chatId}`
          );

        if (!chatDocument) {
          return json(
            {
              success: false,
              message: "Chat not found",
            },
            404
          );
        }

        const chatData =
          firestoreFieldsToObject(
            chatDocument.fields || {}
          );

        const participants =
          chatData.participants || [];

        /*
         * التأكد أن المرسل طرف في المحادثة
         */
        if (!participants.includes(senderUid)) {
          return json(
            {
              success: false,
              message:
                "You are not a participant in this chat",
            },
            403
          );
        }

        /*
         * تحديد المستقبل
         */
        const receiverUid =
          participants.find(
            (uid) => uid !== senderUid
          );

        if (!receiverUid) {
          return json(
            {
              success: false,
              message:
                "Receiver not found",
            },
            400
          );
        }

        /*
         * قراءة اسم المرسل
         */
        const senderDocument =
          await getFirestoreDocument(
            accessToken,
            projectId,
            `users/${senderUid}`
          );

        const senderData =
          senderDocument
            ? firestoreFieldsToObject(
              senderDocument.fields || {}
            )
            : {};

        const senderName =
          senderData.name ||
          senderData.displayName ||
          "رسالة جديدة";

        /*
         * الحصول على Tokens المستقبل
         */
        const tokens =
          await getUserTokens(
            accessToken,
            projectId,
            receiverUid
          );

        if (tokens.length === 0) {
          return json({
            success: true,
            sent: 0,
            message:
              "Receiver has no FCM tokens",
          });
        }

        let sent = 0;
        let failed = 0;

        /*
         * إرسال لكل جهاز
         */
        for (const token of tokens) {
          try {
            await sendFCM({
              accessToken,
              projectId,
              token,
              senderName,
              text,
              senderId: senderUid,
              receiverId: receiverUid,
              chatId,
              messageId,
            });

            sent++;
          } catch (error) {
            failed++;

            console.error(
              "FCM send error:",
              error.message
            );
          }
        }

        return json({
          success: true,
          sent,
          failed,
        });
      }

      return json(
        {
          success: false,
          message: "Not found",
        },
        404
      );
    } catch (error) {
      console.error(
        "Worker error:",
        error
      );

      return json(
        {
          success: false,
          message: error.message,
        },
        500
      );
    }
  },
};

// redeploy