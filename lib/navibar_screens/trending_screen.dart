import 'package:flutter/material.dart';
import '../reusable_widgets/custom_scaffold3.dart';
class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold3(
        child: Center(child: Text("hello",style: TextStyle(fontSize: 40,color: Colors.white),))
    );
  }
}
