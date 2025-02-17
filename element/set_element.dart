import 'package:flutter/material.dart';
import 'package:latest/generated/l10n.dart';
import 'package:latest/widgets/data_entry/checked_text.dart';

class SetElement extends StatefulWidget 
{
  final List<String> data;

  final String defaultValue; // 默认值


  final double width;
  final double height;

  final void Function(String) onChanged;

  final void Function() onCancel;

  const SetElement({
    super.key, 
    required this.data, 
    required this.width, 
    required this.height, 
    required this.onChanged,
    required this.onCancel,
    required this.defaultValue, // 默认值
  });

  @override
  State<SetElement> createState() => _SetElementState();
}

class _SetElementState extends State<SetElement> 
{
  Map<String, bool> checked = {};

  @override
  void dispose()
  {
    checked.clear();
    super.dispose();
  }

  @override
  void initState()
  {
    super.initState();

    if(widget.defaultValue != "")
    {
      List<String> values = widget.defaultValue.split(",");
      for(var value in values)
      {
        if(widget.data.contains(value))
        {
          checked[value] = true;
        }
      }
    }
  }

  /// 初始化数据
  /// @param value 初始化数据
  /// @param checked 初始化选中状态
  void _onChanged(String value, bool? changed)
  {
    setState(() 
    {
      checked[value] = changed!;
    });
  }

  /// 构建单个控件
  /// @param value 控件文本
  /// @return 控件
  Widget _buildCeils(String value)
  {
    bool v = checked[value] ?? false;

    return CheckedText
    (
      text: value, 
      isChecked: v, 
      onChanged:(changed) => _onChanged(value, changed),
      size: 0.70
    );
  }

  /// 构建集合控件
  /// @return 控件
  Widget _buildSet()
  {
    return Container
    (
      decoration: BoxDecoration
      (
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border
        (
          bottom: BorderSide(color: Theme.of(context).dividerTheme.color!, width: 1),
          top: BorderSide(color: Theme.of(context).dividerTheme.color!, width: 1),
        ),
      ),


      child: ListView.builder
      (
        scrollDirection: Axis.vertical,
        itemCount: widget.data.length,
        itemBuilder:(context, index) 
        {
          String value = widget.data[index];

          return _buildCeils(value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    return Container
    (
      decoration: BoxDecoration
      (
        border: Border.all(color: Theme.of(context).dividerTheme.color!, width: 1.5),
        borderRadius: BorderRadius.circular(5),
        color: Theme.of(context).appBarTheme.backgroundColor
      ),
      width: widget.width,
      height: widget.height,
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
      child: Column
      (
        children: 
        [
          Expanded(flex: 1, child:  _buildSet()),

          Container
          (
            padding: const EdgeInsets.fromLTRB(5, 8, 5, 8),
            height: 43,
            child: Row
            (
              mainAxisAlignment: MainAxisAlignment.end,
              children: 
              [
                TextButton
                (
                  onPressed:() 
                  {
                    String r = "";

                    for(var key in checked.keys)
                    {
                      if(checked[key] == true)
                      {
                        r += "$key,";
                      }
                    }

                    widget.onChanged(r.substring(0, r.length - 1));
                  },
                  child: Text(S.current.confirm)
                ),
                TextButton
                (
                  onPressed:widget.onCancel,
                  child: Text(S.current.cancel)
                )
              ],
            ),
          )
        ]
      ),
    );
  }
}