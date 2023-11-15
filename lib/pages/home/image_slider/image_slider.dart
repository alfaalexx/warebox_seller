import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CustomImageSlider extends StatefulWidget {
  final List imageList;
  final CarouselController carouselController;

  CustomImageSlider({
    required this.imageList,
    required this.carouselController,
  });

  @override
  _CustomImageSliderState createState() => _CustomImageSliderState();
}

class _CustomImageSliderState extends State<CustomImageSlider> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 20, 0),
            child: CarouselSlider(
              carouselController: widget.carouselController,
              options: CarouselOptions(
                aspectRatio: 16 / 9,
                autoPlay: true,
                reverse: false,
                enlargeCenterPage: true,
                viewportFraction: 1.0,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              items: widget.imageList.map((item) {
                return Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(12)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(item, fit: BoxFit.cover),
                  ),
                );
              }).toList(),
            ),
          ),
          Align(
            child: Container(
              margin: EdgeInsets.only(top: 190),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.imageList.asMap().entries.map((entry) {
                  int index = entry.key;
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 2.0,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? const Color(0xFF2E9496)
                          : const Color(0xFFE3E3E3),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
