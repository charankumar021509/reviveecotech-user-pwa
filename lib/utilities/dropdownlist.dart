import 'package:flutter/material.dart';
class Customdropdownlist extends StatefulWidget {

  final List<Map<String,String>> dropdownItems;

  const Customdropdownlist({
    super.key,
    required this.dropdownItems
  });

  @override
  State<Customdropdownlist> createState() => _CustomdropdownlistState();
}

class _CustomdropdownlistState extends State<Customdropdownlist> {
  @override
  Widget build(BuildContext context) {
    return Column(
        children: widget.dropdownItems.map(
              (item)=>Padding(
            padding:EdgeInsets.fromLTRB(24, 10, 24, 0),
            child: Container(
              padding: EdgeInsets.fromLTRB(6, 8, 6, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  if(item['image']!=null && item['image']!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,0,16,0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          item['image']!,
                          width:40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['name'] ?? '',
                          style: TextStyle(
                            fontFamily: 'RedHatDisplay',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if(item['price']!=null && item['price']!.isNotEmpty)
                          Text(
                            item['price'] ?? '',
                            style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'RedHatDisplay',
                                fontWeight: FontWeight.bold
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).toList()
    );
  }
}