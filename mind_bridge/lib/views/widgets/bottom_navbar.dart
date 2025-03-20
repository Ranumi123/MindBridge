import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4B9FE1), // Blue primary color
            Color(0xFF1EBBD7), // Teal accent color
            Color(0xFF20E4B5), // Tertiary color
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem('assets/icons/home.svg', 'Home', 0),
          _buildNavItem('assets/icons/feed.svg', 'Feed', 1),
          _buildNavItem('assets/icons/profile.svg', 'Profile', 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(String iconPath, String label, int index) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 26,
            height: 26,
            colorFilter: ColorFilter.mode(
              isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}