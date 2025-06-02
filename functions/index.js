const { onDocumentUpdated } = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');
admin.initializeApp();

exports.notifyDriverOnJoin = onDocumentUpdated('rides/{rideId}', async (event) => {
  const beforeData = event.data.before;
  const afterData = event.data.after;

  if (!beforeData || !afterData) {
    console.log('Missing before/after data');
    return;
  }

  const beforeUsers = beforeData.joinedUsers || {};
  const afterUsers = afterData.joinedUsers || {};

  // Get list of uids
  const beforeUids = Object.keys(beforeUsers);
  const afterUids = Object.keys(afterUsers);

  // Find the newly added UID
  const newUids = afterUids.filter((uid) => !beforeUids.includes(uid));
  if (newUids.length === 0) return;

  const newUserId = newUids[0];
  const newUser = afterUsers[newUserId];
  const newUserName = newUser.name || 'A user';

  // Get driver's FCM token
  const driverId = afterData.driverId;
  if (!driverId) {
    console.log('Driver ID is missing in afterData');
    return;
  }
  console.log("ppgohpfdkjghiurehhptlkhrtkh");

  const driverDoc = await admin.firestore().collection('users').doc(driverId).get();
  const driverData = driverDoc.data();
  const fcmToken = driverData?.fcmToken;

  if (fcmToken) {
    const payload = {
      notification: {
        title: 'New Ride Join Request',
        body: `${newUserName} has joined your ride.`,
      },
      token: fcmToken,
    };

    await admin.messaging().send(payload);
    console.log(`Notification sent to driver (${driverId}) about ${newUserName}`);
  } else {
    console.log(`Driver ${driverId} has no FCM token.`);
  }
});
