import 'package:latest/widgets/data_display/data_table/entity/data_type.dart';

class DataFormat 
{
  final String text;
  final String format;

  final String prefix; // prefix for the data

  const DataFormat({required this.text, required this.format, required this.prefix});

  String get getValue
  {
    return formatValue();
  }
  

  String formatValue()
  {
    String value = text;

    switch (format) 
    {
      case DataType.isBlob:
      case DataType.isLongBlob:
        value = "($prefix) ${text.codeUnits.length} bytes";
      break;

      default:
        value = text;
      break;
    }

    return value;
  }
}