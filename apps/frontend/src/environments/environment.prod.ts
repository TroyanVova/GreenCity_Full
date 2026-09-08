export const environment = {
  production: true,
  apiKeys: '${API_KEYS}',
  apiMapKey: '${API_MAP_KEY}',
  backendLink: '${BACKEND_LINK}',
  backendChatLink: '${BACKEND_CHAT_LINK}',
  backendUserLink: '${BACKEND_USER_LINK}',
  backendUbsLink: '${BACKEND_UBS_LINK}',
  frontendLink: '${FRONTEND_LINK}',
  socket: '${SOCKET}',
  chatSocket: '${CHAT_SOCKET}',
  firebaseConfig: {
    apiKey: '${FIREBASE_API_KEY}',
    authDomain: '${FIREBASE_AUTH_DOMAIN}',
    databaseURL: '${FIREBASE_DATABASE_URL}',
    projectId: '${FIREBASE_PROJECT_ID}',
    storageBucket: '${FIREBASE_STORAGE_BUCKET}',
    messagingSenderId: '${FIREBASE_MESSAGING_SENDER_ID}',
    appId: '${FIREBASE_APP_ID}',
    measurementId: '${FIREBASE_MEASUREMENT_ID}'
  },
  ubsAdmin: {
    backendUbsAdminLink: '${BACKEND_UBS_ADMIN_LINK}'
  },
  googleClientId: '${GOOGLE_CLIENT_ID}',
  agmCoreModuleApiKey: '${AGM_CORE_MODULE_API_KEY}'
};