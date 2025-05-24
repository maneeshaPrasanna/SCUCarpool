
import 'package:santa_clara/widgets/main_drawer.dart';
import 'package:flutter/material.dart';

class GenericPage extends StatelessWidget {
  const GenericPage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold,fontSize: 24),
        ),
        backgroundColor: const Color.fromARGB(255, 129, 30, 45),
      ),
      body: Center(
        child: Text(title),
      ),
      drawer: const MainDrawer(),
    );
  }
}
