class EntityColumn
{
  final String  name;

  final String  type;
  final int     length;
  final int     decimal;
  final bool    notNull;

  final String   comment; // 注释

  final List<String> range;

  EntityColumn(
    this.name, 
    {
      required this.type, 
      this.length = 0, 
      this.decimal = 0, 
      this.notNull = false, 
      this.comment = "", 
      this.range = const []
    }
  );
}

class EntityModel 
{
  double defaultWidth = 100; /// 默认宽度

  EntityModel({required this.defaultWidth});

  /// The batch keys of this entity.
  List<String> _batchKeys = [];

  /// The batch values of this entity.
  List<int> _batchValues = [];

  /// The batch keys of this entity.
  List<String> get batchKeys => _batchKeys;

  /// add batch key and value.
  List<int> get batchValues => _batchValues;

  /// Whether the selected cell is in the range
  bool get isRadius
  {
    if (_batchKeys.contains(_key))
    {
      return _batchValues.contains(_index);
    }

    return false;
  }

  
  bool get radiusNotEmpty 
  {
    return _batchKeys.isNotEmpty && _batchValues.isNotEmpty;
  }


  /// The data of this entity.
  List<Map<String, dynamic>> _data    = [];
  int get length                      => _data.length;
  List<Map<String, dynamic>> get data => _data;

  /// The current key of this entity value.
  dynamic get value
  {
    return _data[_index][_key];
  }

  /// Set the value to the current key of this entity value.
  void setValue(dynamic value)
  {
    _data[_index][_key] = value;
  }


  /// The columns of this entity.
  final Map<String, EntityColumn> _columns = {};

  /// The sorted field
  final List<String> _sortedColumns = [];
  List<String> get sortedColumns    => _sortedColumns;

  /// get columns map.
  Map<String, EntityColumn> get columns => _columns;

  /// check columns is not empty.
  bool get isColumnsNotEmpty => _columns.isNotEmpty;

  /// The freeze of this entity.
  List<String> _freeze = [];

  /// get freeze list.
  List<String> get freeze => _freeze;

  /// check freeze is not empty.
  bool get isFreezeNotEmpty => _freeze.isNotEmpty;


  /// The double of this entity.
  final Map<String, double> _size    = {};

  /// get _size map values.
  double get totalWidth
  {
    double total = 0;

    List<String> keys = _columns.keys.toList();
    for (int i = 0; i < keys.length; i++) 
    {
      total += _size[keys[i]] ?? defaultWidth;
    }

    return total;
  }
  
  /// The index of this entity.
  int _index    = 0;
  int get index => _index;

  void popupKey({required String key, required bool right})
  {
    int index = _sortedColumns.indexOf(key);
    int _index = _sortedColumns.indexOf(_key);

    if(index >= _index && right == true)
    {
      _batchKeys.remove(_sortedColumns[_index - 1]);
    }else if(right == true && !_batchKeys.contains(_key))
    {
      _batchKeys.add(_key);
    }

    if(index <= _index && right == false)
    {
      _batchKeys.remove(_sortedColumns[_index + 1]);
    }else if(right == false && !_batchKeys.contains(_key))
    {
      _batchKeys.add(_key);
    }

    /// 如果没有选中，则添加到选中列表中
    if(!_batchKeys.contains(key))
    {
      _batchValues.add(this._index);
      _batchKeys.add(key);
    }
  }

  /// Add selection
  /// @param locationId int
  /// @param up bool
  /// @return void
  void popupIndex({required int locationId, required bool up})
  {
    if(_batchKeys.isEmpty)
    {
      _batchKeys = [_key];
    }

    print("locationId: ${locationId} index: ${_index} up: ${up}");

    /// 向上移选择的行
    if(locationId > _index && up == true)
    {
      _batchValues.remove(_index);
    }else if(up == true && !_batchValues.contains(_index))
    {
      _batchValues.add(_index);
    }
    

    /// 向下移选择的行
    if(locationId < _index && up == false)
    {
      _batchValues.remove(_index);
    }else if(up == false && !_batchValues.contains(_index))
    {
      print("object: ${_index}");

      _batchValues.add(_index);
    }

    print(_batchValues);

  }

  /// nextKey
  Future<bool> nextKey() async
  {
    int index  = sortedColumns.indexOf(_key);
    int nextId = index + 1;

    bool isnext = false;
    if(sortedColumns.length > nextId)
    {
      _key = sortedColumns[nextId];

      isnext = true;
    }

    return isnext;
  }

  /// prevKey
  Future<bool> prevKey() async
  {
    int index  = sortedColumns.indexOf(_key);
    int prevId = index - 1;

    bool isprev = false;
    if(prevId >= 0)
    {
      _key = sortedColumns[prevId];

      isprev = true;
    }

    return isprev;
  }


  /// prev
  bool prev()
  {
    if(_index > 0)
    {
      _index--;
      return true;
    }

    return false;
  }


  /// next
  bool next()
  {
    if(_index < _data.length - 1)
    {
      _index++;
      return true;
    }

    return false;
  }

  /// removeAt 
  /// @param index int
  /// @return Map<String, dynamic>
  Map<String, dynamic> removeAt(int index)
  {
    return _data.removeAt(index);
  }

  /// clear data.
  /// @return void
  void clear()
  {
    _data = [];
  }

  /// insert data.
  /// @param index int
  /// @param data Map<String, dynamic>
  /// @return bool
  bool insert(int index, {required Map<String, dynamic> data})
  {
    if(index >= 0 && index < _data.length)
    {
      _data.insert(index, data);
      return true;
    }

    return false;
  }

  bool addData({required Map<String, dynamic> data})
  {
    if(data.isNotEmpty)
    {
      _data.add(data);
      return true;
    }

    return false;
  }

  /// The key of this entity.
  String _key = "";
  String get key => _key;

  
  /// Set the key of this entity.
  /// @param key String
  /// @return bool
  bool setKey(String key)
  {
    if(key.isNotEmpty && key != _key)
    {
      _key = key;
      return true;
    }

    return false;
  }

  /// Set the index of this entity.
  /// @param index int
  /// @return bool
  bool setIndex(int index)
  {
    if(index >= 0 && index != _index && index < _data.length)
    {
      _index = index;
      return true;
    }

    return false;
  }

  /// Check if this entity has a position.
  /// @param index int
  /// @param key String
  /// @return bool
  bool position({required int index, required String key})
  {
    return _key == key && _index == index;
  }

  /// Check if this entity has a position.
  /// @param index int
  /// @param key String
  /// @return bool
  bool hasPosition({required int index, required String key})
  {
    if(_data.length > index && index >= 0)
    {
      return _data[index].containsKey(key);
    }

    return false;
  }

  /// Set the position of this entity.
  /// @param index int
  /// @param key String
  /// @return bool
  Future<bool> setPosition({required int index, required String key}) async
  {
    if(hasPosition(index: index, key: key))
    {
      _index  = index;
      _key    = key;

      return true;
    }

    return false;
  }

  /// Add a column to this entity.
  /// @param key String
  /// @return bool
  bool hasColumn(String key)
  {
    return _columns.containsKey(key);
  }

  /// Add a column to this entity.
  /// @param key String
  /// @param column EntityColumn
  /// @return void
  void addColumn(String key, EntityColumn column)
  {
    if(!_columns.containsKey(key))
    {
      _columns[key] = column;

      _sortedColumns.add(key); /// Sorted columns

      /// Set key to default
      if(_key.isEmpty)
      {
        _key = key;
      }
    }
  }

  /// Get the size of this entity.
  /// @param key String
  /// @return 
  double getWidth({required String key})
  {
    return _size[key] ?? defaultWidth;
  }

  /// Set the size of this entity.
  /// @param key String
  /// @param width double
  /// @return bool
  bool setWidth({required String key, required double width})
  {
    if(_columns.containsKey(key))
    {
      _size[key] = width;
      return true;
    }

    return false;
  }

  /// Clear the freeze of this entity.
  /// @return bool
  bool clearFreeze()
  {
    _freeze = [];
    return true;
  }

  /// Set the freeze of this entity.
  /// @param key String
  /// @return bool
  bool setFreeze(String key)
  {
    if(_columns.containsKey(key))
    {
      _freeze.add(key);
      return true;
    }

    return false;
  }

  /// Set the batch keys of this entity.
  /// @param keys List<String>
  /// @return bool
  bool setBatchKeys(List<String> keys)
  {
    if(keys != batchKeys)
    {
      _batchKeys = keys;
      return true;
    }

    
    return false;
  }

  /// Set the batch values of this entity.
  /// @param values List<int>
  /// @return bool
  bool setBatchValues(List<int> values)
  {
    if(values != batchValues)
    {
      _batchValues = values;
      return true;
    }

    return false;
  }
}