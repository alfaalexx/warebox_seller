import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomListItem extends StatelessWidget {
  final String imagePath;
  final String title;
  final String location;
  final String price;
  final String rating;

  CustomListItem({
    required this.imagePath,
    required this.title,
    required this.location,
    required this.price,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 108,
      margin: const EdgeInsets.only(left: 18.0, right: 18.0, top: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12.0),
              bottomLeft: Radius.circular(12.0),
            ),
            child: Image.asset(
              imagePath,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    letterSpacing: 1,
                    color: const Color(0xFF1E2022),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  location,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    letterSpacing: 1,
                    color: const Color(0xFF77838F),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 30.0),
                      child: Text(
                        price,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          letterSpacing: 1,
                          color: const Color(0xFF77838F),
                        ),
                      ),
                    ),
                    Image.asset("assets/images/star.png"),
                    Container(
                      margin: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        rating,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          letterSpacing: 1,
                          color: const Color(0xFF77838F),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
