import 'package:flutter/material.dart';
import 'package:latest/widgets/data_display/data_table/entity/entity_model.dart';

class PageTableHeader extends ChangeNotifier
{
  final EntityModel entityModel;
  PageTableHeader({required this.entityModel});

  /// Rebuild the widget.
  /// [notifyListeners]
  /// @return void
  void rebuild()
  {
    notifyListeners();
  }

  /// Get the width of the freezed column all
  /// @return double
  double get freezedWidth
  {
    double width = 0;

    int length = entityModel.freeze.length;
    for (int i = 0; i < length; i++) 
    {
      width += entityModel.getWidth(key: entityModel.freeze[i]);
    }

    return width;
  }

}