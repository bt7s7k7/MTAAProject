importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js")
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js")
importScripts("./config.js")

firebase.initializeApp(config)
// Necessary to receive background messages:
const messaging = firebase.messaging()

// Optional:
messaging.onBackgroundMessage((m) => {
    console.log("onBackgroundMessage", m)
})
