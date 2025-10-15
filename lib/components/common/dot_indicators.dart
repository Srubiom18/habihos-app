import 'dart:ui';
import 'package:flutter/material.dart';

class DotIndicators extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final PageController pageController;

  const DotIndicators({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: const Color.fromARGB(122, 245, 245, 245),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              totalPages,
              (index) => _buildDotIndicator(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDotIndicator(int pageIndex) {
    bool isActive = currentPage == pageIndex;
    return GestureDetector(
      onTap: () {
        pageController.animateToPage(
          pageIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isActive ? 24 : 12,
        height: 12,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.grey[400],
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
