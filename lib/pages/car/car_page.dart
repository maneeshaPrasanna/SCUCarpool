import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final _plateController = TextEditingController();
  final _carColorController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadCarData();
  }

  Future<void> _loadCarData() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('cars').doc(user!.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      _makerController.text = data['maker'] ?? '';
      _modelController.text = data['model'] ?? '';
      _plateController.text = data['plate'] ?? '';
      _carColorController.text = data['carColor'] ?? '';
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
      'plate': _plateController.text.trim(),
      'carColor': _carColorController.text.trim(),
    });

   

    if (mounted) {
      Navigator.pop(context,true); // 返回上一页
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF811E2D), // Maroon color
        iconTheme: const IconThemeData(color: Colors.white), // White icons
        title: const Text('Car Information'),
        elevation: 2,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
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
                      validator: (value) => value == null || value.isEmpty ? 'Please enter car maker' : null,
                    ),
                    TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(labelText: 'Model'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter car model' : null,
                    ),
                    TextFormField(
                      controller: _plateController,
                      decoration: const InputDecoration(labelText: 'Plate Number'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter plate number' : null,
                    ),
                    TextFormField(
                      controller: _carColorController,
                      decoration: const InputDecoration(labelText: 'Car Color'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter car color' : null,
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
