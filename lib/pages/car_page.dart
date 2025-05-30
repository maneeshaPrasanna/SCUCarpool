import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:santa_clara/models/vehicle.dart';

class CarPage extends StatefulWidget {
  const CarPage({super.key});

  @override
  State<CarPage> createState() => _AddCarPageState();
}

class _AddCarPageState extends State<CarPage> {
  final user = FirebaseAuth.instance.currentUser;

  final _formKey = GlobalKey<FormState>();
  final _makerController = TextEditingController();
  final _modelController = TextEditingController();
  final _carColorController = TextEditingController();
  final _plateController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadCarData();
  }

  Future<void> _loadCarData() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('cars')
        .doc(user!.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      _makerController.text = data['maker'] ?? '';
      _modelController.text = data['model'] ?? '';
      _carColorController.text = data['carColor'] ?? '';
      _plateController.text = data['plate'] ?? '';
    }
  }

  Future<void> _saveCarData() async {
    if (user == null || !_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final carDoc = FirebaseFirestore.instance.collection('cars').doc(user!.uid);
    await carDoc.set({
      'uid': user!.uid,
      'maker': _makerController.text.trim(),
      'model': _modelController.text.trim(),
      'carColor': _carColorController.text.trim(),
      'plate': _plateController.text.trim(),
    });

    // 2. Fetch rides with departureTime > now
    // final now = DateTime.now();
    // final rideSnapshot = await FirebaseFirestore.instance
    //     .collection('rides')
    //     .where('departureTime', isGreaterThan: Timestamp.fromDate(now))
    //     .get();
    // print('Found ${rideSnapshot.docs.length} rides with departureTime > now');
    // // 3. Filter rides where driver.user.uid == current user
    // for (var doc in rideSnapshot.docs) {
    final now = DateTime.now();
    final rideCollection = FirebaseFirestore.instance.collection('rides');

    final querySnapshot = await rideCollection.get();
    print('founddd ${querySnapshot.docs.length}');
    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      final departureTimeString = data['departureTime'];
      print('departureTimeString: $departureTimeString');
      if (departureTimeString is String) {}
      final departureTime = DateTime.parse(departureTimeString);
      print('departureTime: $departureTime');
      print('now: $now');
      if (departureTime.isAfter(now)) {
        print(data['driver']?['user']?['uid']);
        if (data['driver']?['user']?['uid'] == user!.uid) {
          await doc.reference.update({
            'driver.vehicle.maker': _makerController.text.trim(),
            'driver.vehicle.model': _modelController.text.trim(),
            'driver.vehicle.carColor': _carColorController.text.trim(),
            'driver.vehicle.plate': _plateController.text.trim(),
          });
        }
      }
    }

    if (mounted) {
      Navigator.pop(context, true); // 返回上一页
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Car Information",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 129, 30, 45),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _makerController,
                      decoration: const InputDecoration(labelText: 'Maker'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter car maker'
                          : null,
                    ),
                    TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(labelText: 'Model'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter car model'
                          : null,
                    ),
                    TextFormField(
                      controller: _carColorController,
                      decoration: const InputDecoration(labelText: 'Color'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter car color'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _plateController,
                      decoration:
                          const InputDecoration(labelText: 'Plate Number'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter plate number'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveCarData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 129, 30, 45),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
