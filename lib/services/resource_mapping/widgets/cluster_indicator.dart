import 'package:flutter/material.dart';

class ClusterIndicator extends StatelessWidget {
  final int count;

  const ClusterIndicator({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.7),
        shape: BoxShape.circle,
      ),
      child: Text(
        count.toString(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}