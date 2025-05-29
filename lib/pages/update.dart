import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> updateSanJoseAddress() async {
  final firestore = FirebaseFirestore.instance;

  final ridesSnapshot = await firestore.collection('rides').get();

  for (var doc in ridesSnapshot.docs) {
    final data = doc.data();
    if (!data.containsKey('createdAt')) {
      await firestore.collection('rides').doc(doc.id).update({
        'createdAt': DateTime.now().toIso8601String(), // use server timestamp
      });
    }
  }
  //   bool updated = false;

  //   final pickup = data['pickupLocation'];
  //   final destination = data['destinationLocation'];

  //   if (pickup != null && pickup['address'] == 'San Jose, CA') {
  //     pickup['address'] = 'San Jose, CA, USA';
  //     updated = true;
  //   }

  //   if (destination != null && destination['address'] == 'San Jose, CA') {
  //     destination['address'] = 'San Jose, CA, USA';
  //     updated = true;
  //   }

  //   if (updated) {
  //     await doc.reference.update({
  //       'pickupLocation': pickup,
  //       'destinationLocation': destination,
  //     });
  //     print('Updated: ${doc.id}');
  //   }
  // }

  // print('Update complete.');
}
