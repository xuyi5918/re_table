import 'package:flutter/material.dart';
import 'package:latest/widgets/data_display/data_table/element/bit_element.dart';
import 'package:latest/widgets/data_display/data_table/element/date_timer_element.dart';
import 'package:latest/widgets/data_display/data_table/element/enum_element.dart';
import 'package:latest/widgets/data_display/data_table/element/set_element.dart';
import 'package:latest/widgets/data_display/data_table/entity/data_type.dart';
import 'package:latest/widgets/forms/date_picker.dart';

class TableElement 
{
  TableElement();

  double _height = 0.0;
  double _width = 0.0;

  double get height => _height;
  double get width => _width;

  /// Padding left for hours, minutes and seconds
  String padLeft({required int value})
  {
    return value.toString().padLeft(2, '0');
  }

  Widget createElement({
    required String element,
    required String value,
    required Offset offset,
    required List<String> range,
    required void Function(String value) onChanged,
    required Function() onFinish,

    required double width
  })
  {

    Widget widget = const SizedBox();
    
    switch (element) 
    {
      case DataType.isEnum:
        double minHeight  = 23;
        _height           = (minHeight * range.length + 13.0) + 10.0;
        _width            = width - 1;

        widget = EnumElement(
          elemnet: range, 
          defaultValue: value, 
          onChanged:onChanged,
          height: minHeight, 
          maxHeight: _height, 
          y: offset.dy,
          
          onFinish: onFinish,
        );
      break;

      case DataType.isTimer:
        _width = 305;
        widget = DateTimerElement
        (
          type: DatePicker.Timer, 
          defaultValue: value, 
          onAck:(timer) 
          {
            onChanged("${padLeft(value: timer?.hour ?? 0)}:${padLeft(value: timer?.minute ?? 0)}:${padLeft(value: timer?.second ?? 0)}");
            onFinish();
          },
          onCancel:onFinish
        );
      break;

      case DataType.isSet:
        _width = 270;
        _height = 230;
        widget = SetElement
        (
          data: range, 
          width: _width, 
          height: _height, 
          onCancel: () => onFinish(),
          defaultValue: value,
          onChanged:(element) 
          {
            onChanged(element);
            onFinish();
          },
        );
      break;

      case DataType.isDateTime:
        _width = 250;
        _height = 365;
        widget = DateTimerElement
        (
          type: DatePicker.DateTimer,
          defaultValue: value, 
          onAck: (timer) 
          {
            onChanged("${padLeft(value: timer?.year ?? 0)}-${padLeft(value: timer?.month ?? 0)}-${padLeft(value: timer?.day ?? 0)} ${padLeft(value: timer?.hour ?? 0)}:${padLeft(value: timer?.minute ?? 0)}:${padLeft(value: timer?.second ?? 0)}");
            onFinish();
          },
          onCancel:onFinish
        );
      break;

      /// case DataType.isBit: 二进制数据
      case DataType.isBit:
        widget = BitElement
        (
          defaultValue: value, 
          onChanged: onChanged, 
          onCancel: onFinish, 
          width: width, 
          height: height
        );
      break;

      
      case DataType.isDate:
        _width = 305;
        widget = DateTimerElement(
          type: DatePicker.Date, 
          defaultValue: value, 
          onAck: (timer) {
            onChanged("${padLeft(value: timer?.year ?? 0)}-${padLeft(value: timer?.month ?? 0)}-${padLeft(value: timer?.day ?? 0)}");
            onFinish();
          },
          onCancel:onFinish
        );
      break;

      default:
    }

    return widget;
  }
}