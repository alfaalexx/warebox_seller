import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomWarehouseItem extends StatelessWidget {
  final IconData icon; // Change the type to IconData
  final String title1;
  final String title2;
  final Function() onTap;

  CustomWarehouseItem({
    required this.icon, // Change the type to IconData
    required this.title1,
    required this.title2,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 18, top: 10),
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: const Color(0xFFF2F5F9),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(icon,
                    size: 32,
                    color: const Color(0xFF2E9496)), // Use Icon widget
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(left: 10.0, top: 8.0),
            child: Column(
              children: [
                Text(
                  title1,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF77838F),
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  title2,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF77838F),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
