import 'package:flutter/material.dart';
import 'package:latest/widgets/forms/date_picker.dart';

class DateTimerElement extends StatelessWidget 
{
  final int type;
  final String defaultValue;
  final void Function() onCancel;
  final void Function(DateTime? timer) onAck;


  const DateTimerElement({
    super.key, 
    required this.type, 
    required this.defaultValue, 
    required this.onCancel,
    required this.onAck,
  });

  @override
  Widget build(BuildContext context) 
  {
    DateTime unixTime = DateTime.now();

    if(defaultValue.isNotEmpty)
    {
      unixTime = DateTime.parse(defaultValue);
    }

    /// 根据类型构建不同的控件
    return DatePicker
    (
      timestamp: unixTime.millisecondsSinceEpoch, 
      style: type, 
      size: DatePicker.minimum,
      isAck: true,
      onAck: onAck,
      onCancel: onCancel
    );
  }
}