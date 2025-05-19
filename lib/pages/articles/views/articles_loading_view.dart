import 'package:flutter/material.dart';
import 'package:santa_clara/widgets/main_drawer.dart';

class ArticlesLoadingView extends StatelessWidget {
  const ArticlesLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: MainDrawer(),
         appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Search",
          style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold,fontSize: 24),
        ),
        backgroundColor: const Color.fromARGB(255, 129, 30, 45),
      ),
        body: Center(child: CircularProgressIndicator()));
  }
}
