import 'package:flutter/material.dart';
import 'package:latest/widgets/data_display/data_table/entity/entity_model.dart';

class PageTableBody extends ChangeNotifier
{
  final EntityModel entityModel;
  final TextEditingController controller;

  PageTableBody({required this.entityModel, required this.controller});

  @override
  void dispose()
  {
    controller.dispose();
    super.dispose();
  }

  /// is edit values
  bool _isEditValues = false;
  bool get isEditValues => _isEditValues;
  void setEditValues({required bool isEdit})
  {
    _isEditValues = isEdit;
  }


  /// Save temporary pos variable
  int _index = -1; 
  int get index => _index;
  String _key = '';
  String get key => _key;

  /// Save temporary pos variable
  /// @param index
  /// @param key
  /// @return bool
  void saveTempPos({required int index, required String key})
  {
    _key    = key;
    _index  = index;
  }

  /// The key of the selected cell
  String _selectedKey = '';
  String get selectedKey => _selectedKey;
  void setSelectedKey({required String key})
  {
    if (key != _selectedKey)
    {
      _selectedKey = key;
    }
  }

  /// The edit mode of the cell
  bool _editMode = false;
  bool get editMode => _editMode;
  void setEditMode({required bool mode})
  {
    _editMode = mode;
  }



  /// The selection mode of the cell
  bool _selectionMode = false;
  bool get isSelectionMode => _selectionMode;
  /// Set the selection mode of the cell
  /// @param selectionMode
  /// @param isClickSelection 在结束选择模式时将光标定位到最后一个选择的单元格上
  /// @return {void}
  void setSelectionMode({required bool selectionMode, required bool isClickSelection})
  {
    _selectionMode = selectionMode;

    /// 结束选择模式
    if (selectionMode == false && entityModel.radiusNotEmpty) 
    {
      String key = isClickSelection ? entityModel.key : entityModel.batchKeys.last;
      int index = isClickSelection ? entityModel.index : entityModel.batchValues.last;

      entityModel.setPosition(index: index, key: key);
    }
  }


  /// The radius of the selected cell
  Offset _radius = Offset.zero;
  Offset get radius => _radius;

  /// The initial ceils position of the selected cell
  Offset _initializationCeils = Offset.zero;
  Offset get initializationCeils => _initializationCeils;

  /// Set the initial ceils position of the selected cell
  /// @param dx
  /// @param dy
  /// @return bool
  bool setInitializationCeils({required double dx, required double dy})
  {
    _initializationCeils = Offset(dx, dy);
    return true;
  }

  /// Clear the selection of the cell
  bool clearAway()
  {
    _radius               = Offset.zero;
    _initializationCeils  = Offset.zero;

    _index        = 0;
    _selectedKey  = '';

    entityModel.setBatchKeys([]);
    entityModel.setBatchValues([]);

    return true;
  }


  /// Rebuild the widget
  /// [notifyListeners]
  /// @return {void}
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

  /// set the radius of the selected cell
  /// @param dx
  /// @param dy
  /// @return List<String>
  List<String> _columnsKey(String key, double dx)
  {
    List<String>  ret         = [];
    int           id          = entityModel.sortedColumns.indexOf(key);
    double        selectWidth = 0.0;
    List<String>  keys        = entityModel.sortedColumns;
    List<String>  freezedKeys = entityModel.freeze;

    if(dx > 0)
    {
      for(id; id < keys.length; id++)
      {
        String k = keys[id];

        /// In the freeze list, it is skipped
        if(freezedKeys.contains(k))
        {
          continue;
        }

        double w = entityModel.getWidth(key: k);
        selectWidth = selectWidth + w;
        if(dx + initializationCeils.dx < selectWidth - w)
        {
          break;  
        }
        ret.add(k);
      }
    }else if(dx < 0)
    {
      ret.add(keys[id]);

      for(id; id > 0; id--)
      {
        String k = keys[id - 1];

        if(freezedKeys.contains(k))
        {
          continue;
        }


        double w = entityModel.getWidth(key: k);
        selectWidth = selectWidth - w; 

        if(dx + initializationCeils.dx > selectWidth + w) 
        {
          break;
        }

        ret.add(k);
      }
    }

    return ret;
  }

  /// set the radius of the selected cell
  /// @param index
  /// @return List<int>
  List<int> _rowsid(int index, int rowsNo)
  {
    List<int> rowsid = [];
    if (rowsNo > 0)
    {
      for (int i = 0; i < rowsNo; i++) 
      {
        int id = index + i;
        if (id >= entityModel.length) 
        {
          break;
        }

        rowsid.add(id);
      }
    }else
    {
      for (int i = 0; i >= rowsNo; i--) 
      {
        int id = index + i;
        if (id < 0) 
        {
          break;
        }
        rowsid.add(id);
      }
    }

    return rowsid;
  }

  /// Select the cell 
  /// @param x
  /// @param y
  /// @param height
  /// @return Future<bool>
  Future<bool> selection({
    required double x, 
    required double y,
    required double height
  }) async
  {
    /// The radius of the selected cell
    _radius = Offset(radius.dx + x, radius.dy + y);

    /// The number of rows selected
    int rowsNo = ((_radius.dy + initializationCeils.dy) / height).ceil();
    rowsNo = rowsNo > entityModel.length ? entityModel.length : rowsNo;

    /// The index number 
    int index = entityModel.index;

    /// The number of columns selected
    bool v = entityModel.setBatchValues(_rowsid(index, rowsNo));

    /// The selected column key
    bool k = entityModel.setBatchKeys(_columnsKey(entityModel.key, _radius.dx));

    if(!v && !k)
    {
      return false;
    }
    
    return true;
  }

  /// Whether the cell is selected
  /// @param key
  /// @param index
  /// @return bool
  bool hasRange({required String key, required int index})
  {
    return entityModel.batchKeys.contains(key) && entityModel.batchValues.contains(index);
  }

  /// Batch selection
  /// @param isShift
  /// @return Future<bool>  
  Future<bool> selectionBatch({required bool isShift}) async
  {
    bool ret = false;
    if(isShift)
    {
      /// Keys selection
      int startKeyIndex    = entityModel.sortedColumns.indexOf(key);
      int endKeyIndex      = entityModel.sortedColumns.indexOf(entityModel.key);

      if(startKeyIndex > endKeyIndex)
      {
        int temp = startKeyIndex;
        startKeyIndex = endKeyIndex;
        endKeyIndex   = temp;
      }

      List<String> keys = [];
      for(int i = startKeyIndex; i <= endKeyIndex; i++)
      {
        keys.add(entityModel.sortedColumns[i]);
      }
      entityModel.setBatchKeys(keys);

      /// Values selection
      int startValueIndex  = index;
      int endValueIndex    = entityModel.index;
      if(startValueIndex > endValueIndex)
      {
        int temp = startValueIndex;
        startValueIndex = endValueIndex;
        endValueIndex   = temp;
      }
      List<int> values = [];
      for(int i = startValueIndex; i <= endValueIndex; i++)
      {
        values.add(i);
      }
      entityModel.setBatchValues(values);

      ret = true;

    }else
    {
      entityModel.batchValues.add(entityModel.index);
      entityModel.setBatchKeys(entityModel.sortedColumns);

      ret = true;
    }

    return ret;
  }


}