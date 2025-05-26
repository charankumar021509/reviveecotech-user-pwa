import 'package:flutter/material.dart';
import 'package:revive_eco_tech_app/utilities/dropdownlist.dart';
class Tiles extends StatefulWidget {

  final String tilename;
  final List<Map<String,String>>? dropdownItems;
  final VoidCallback? onTap;
  final IconData? iconPath;

  const Tiles({
    super.key,
    required this . tilename,
    this.dropdownItems,
    this.onTap,
    this.iconPath
  });

  @override
  State<Tiles> createState() => _TilesState();
}

class _TilesState extends State<Tiles> {
  bool isExpanded = false;
  void dropdown(){
    setState(() {
      isExpanded = !isExpanded;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
      child:GestureDetector(
        onTap: widget.onTap ?? dropdown,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
          ),
          padding: EdgeInsets.fromLTRB(20, 10 , 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if(widget.iconPath!=null)
                    Padding(
                      padding: EdgeInsets.fromLTRB(2, 0, 12, 0),
                      child: Icon(
                        widget.iconPath,
                        size: 50,
                        color: widget.tilename=='Log Out'?Colors.red:Colors.black,
                      ),
                    ),
                  Expanded(
                    child: Text(widget.tilename,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'RedHatDisplay',
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (widget.tilename!='Log Out')
                    Icon(
                      widget.onTap != null?Icons.arrow_right:
                      (isExpanded ? Icons.arrow_drop_down_sharp: Icons.arrow_drop_up_sharp),
                      color: widget.tilename=='Log Out'?Colors.red:Colors.green,
                      size: 60,
                    ),
                ],
              ),
              if(isExpanded && widget.dropdownItems != null)
                Customdropdownlist (dropdownItems: widget.dropdownItems!),
            ],
          ),
        ),
      ),
    );
  }
}