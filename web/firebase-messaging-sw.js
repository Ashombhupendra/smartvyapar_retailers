importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyB3mzX26wHMalPoYpruw1X73XAf-kP4mCY",
  authDomain: "smartvyapaar2025.firebaseapp.com",
  databaseURL: "https://ammart-8885e-default-rtdb.firebaseio.com",
  projectId: "smartvyapaar2025",
  storageBucket: "smartvyapaar2025.firebasestorage.app",
  messagingSenderId: "996442516867",
  appId: "1:1000163153346:web:4f702a4b5adbd5c906b25b",
  measurementId: "G-5KFWBX03XT"
});

const messaging = firebase.messaging();

messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            const title = payload.notification.title;
            const options = {
                body: payload.notification.score
              };
            return registration.showNotification(title, options);
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});