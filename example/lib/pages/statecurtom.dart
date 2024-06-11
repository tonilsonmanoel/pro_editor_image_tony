import 'package:flutter/material.dart';

class StateCurtom extends StatefulWidget {
  const StateCurtom({super.key});

  @override
  State<StateCurtom> createState() => _StateCurtomState();
}

class _StateCurtomState extends State<StateCurtom> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("StateCurtom "),
          ElevatedButton(onPressed: () {}, child: Text("")),
        ],
      ),
    );
  }
}
