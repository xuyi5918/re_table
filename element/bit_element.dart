import 'package:flutter/material.dart';

class BitElement extends StatefulWidget 
{
  final String defaultValue;
  final double width;
  final double height;

  final void Function(String) onChanged;
  final void Function() onCancel;

  const BitElement({
    super.key, 
    required this.defaultValue, 
    required this.onChanged, 
    required this.onCancel, 
    
    required this.width, 
    required this.height
  });

  @override
  State<BitElement> createState() => _BitElementState();
}

class _BitElementState extends State<BitElement> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}