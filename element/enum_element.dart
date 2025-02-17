import 'package:flutter/material.dart';
import 'package:latest/utils/theme/theme_colour.dart';

class EnumElement extends StatefulWidget 
{
  final List<String> elemnet;
  final String defaultValue;
  final double height;
  final void Function(String) onChanged; // Function that will be called when the value changes.

  final void Function() onFinish;
  
  final double maxHeight;
  final double y;

  const EnumElement({
    super.key, 
    required this.elemnet, 
    required this.defaultValue, 
    required this.onChanged, 
    required this.height, 
    required this.maxHeight, 
    required this.onFinish,
    required this.y
  });

  @override
  State<EnumElement> createState() => _EnumElementState();
}

class _EnumElementState extends State<EnumElement> 
{
  String element = "";

  Widget _buildCeils({required String value})
  {
    return MouseRegion
    (
      cursor: SystemMouseCursors.click,
      
      onEnter: (event) =>
      {
        setState(() {
          element = value;
        }),
      },
      onExit: (event) =>
      {
        setState(() {
          element = "";
        })
      },

      child: GestureDetector
      (
        onTapDown: (details) 
        {
          widget.onChanged(value);
        },

        onTapUp: (details) {
          widget.onFinish();
        },
        child: Container
        (
          height: widget.height,
          decoration: BoxDecoration
          (
            borderRadius: BorderRadius.circular(3),
            color: element == value ? Theme.of(context).hoverColor : Colors.transparent,
          ),
          child: Row
          (
            children: 
            [
              Container
              (
                width: 3, 
                height: 10,
                alignment: Alignment.center,
                margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                decoration: BoxDecoration
                (
                  color: widget.defaultValue == value ? Theme.of(context).colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Text(value, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        )
      ) 
    );
  }


  Widget _buildEnum()
  {
    return ListView.builder
    (
      scrollDirection: Axis.vertical,
      itemCount: widget.elemnet.length,
      itemBuilder:(context, index) 
      {
        String value = widget.elemnet[index];

        return _buildCeils(value: value);
      },
    );
  }
  @override
  Widget build(BuildContext context) 
  {
    bool isOverflow = MediaQuery.of(context).size.height - (widget.y + widget.maxHeight) < widget.height + 1;

    return Container
    (
      constraints: const BoxConstraints
      (
        maxHeight: 180,
      ),
      height: widget.height * widget.elemnet.length + 13,
      padding: const EdgeInsets.fromLTRB(3, 5, 3, 5),
      decoration: BoxDecoration
      (
        border: Border.all(color: Color(ThemeColour.reverseColor(context)), width: 0.4),
        color: Color(ThemeColour.color(context)),
        borderRadius: isOverflow ? BorderRadius.circular(3) : const BorderRadius.only
        (
          bottomLeft: Radius.circular(3),
          bottomRight: Radius.circular(3),
        ),
      ),
      child: _buildEnum()
    );
  }
}