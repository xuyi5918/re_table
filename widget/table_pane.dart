import 'package:flutter/material.dart';
import 'package:latest/utils/theme/theme_colour.dart';

class TablePane extends StatelessWidget
{
  final IconData icon;
  final double size;

  final bool Function(int index) taking;
  final int itemCount;
  
  final Future<bool> Function(int index) onSelect;
  final ScrollController controller;
  final void Function(int index, TapUpDetails details) contextMenuBuilder; // context menu builder

  final double minHeight;

  TablePane({
    super.key, 
    required this.icon, 
    required this.size, 

    required this.taking, 
    
    required this.itemCount, 
    required this.minHeight,

    required this.onSelect, 
    required this.contextMenuBuilder,
    required this.controller,
  });

  final ValueNotifier<bool> _rebuild = ValueNotifier(false);

  /// Dispose the notifier.
  void dispose()
  {
    _rebuild.dispose();
  }
  
  /// Rebuild the widget.
  void rebuild(bool rebuild)
  {
    if (rebuild) 
    {
      _rebuild.value = !_rebuild.value;
    }
  }


  @override
  Widget build(BuildContext context) 
  {
    Color reverseColor =  Color(ThemeColour.reverseColor(context));

    return ScrollConfiguration
    (
      behavior:ScrollConfiguration.of(context).copyWith(scrollbars: false), 
      child: ValueListenableBuilder(valueListenable: _rebuild, builder:(context, value, child) 
      {
        return ListView.builder
        (
          controller: controller,
          itemCount: itemCount,
          itemBuilder:(context, index) 
          {
            return GestureDetector
            (
              onTapUp: (details) 
              {
                onSelect(index).then((value)
                {
                  if (value) 
                  {
                    rebuild(true);
                  }
                });
              },

              onSecondaryTapUp: (details) 
              {

                contextMenuBuilder(index, details); /// 显示菜单

                
                onSelect(index).then((value)
                {
                  if (value) 
                  {
                    rebuild(true);
                  }
                });
              },

              child: Container
              (
                width: double.infinity,
                height: minHeight,
                alignment: Alignment.center,
                decoration: BoxDecoration
                (
                  border: Border
                  (
                    bottom: BorderSide
                    (
                      color: Theme.of(context).dividerTheme.color ?? Colors.transparent, 
                      width: 0.8
                    )
                  )
                ),
                child: taking(index) ? Icon(icon, size: size, color: reverseColor) : null,
              ),
            );
          },
        );  
      }),
    );
  }
}