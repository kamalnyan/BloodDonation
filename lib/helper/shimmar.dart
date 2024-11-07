import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../themes/dark_light_switch.dart';

Widget shimmarr(BuildContext context) {
  return Shimmer.fromColors(
    baseColor: isDarkMode(context) ? Colors.grey[700]! : Colors.grey[300]!,
    highlightColor: isDarkMode(context) ? Colors.grey[500]! : Colors.grey[100]!,
    child: Card(
      color: isDarkMode(context) ? Colors.black54 : Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: SizedBox(
        height: 120, // Default card height; adjust as needed
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: double.infinity,
                height: 14,
                color: Colors.white,
              ),
              Container(
                width: 200,
                height: 12,
                color: Colors.white,
              ),
              Container(
                width: 180,
                height: 12,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
