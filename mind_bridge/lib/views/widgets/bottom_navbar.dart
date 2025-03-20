// This file contains the bottom navigation bar widget that is displayed at the bottom of the screen.
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import '../therapist_dashboard/doctor_list_screen.dart';

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
      height: 65,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(context, 'assets/icons/home.svg', 'Home', 0),
          _buildNavItem(context, 'assets/icons/therapist.svg', 'Therapist', 1),
          _buildNavItem(context, 'assets/icons/feed.svg', 'Feed', 2),
          _buildNavItem(context, 'assets/icons/settings.svg', 'Settings', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, String iconPath, String label, int index) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        // Let the parent widget handle the navigation logic
        onItemTapped(index);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 60,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isSelected)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: 1.0,
                    child: Container(
                      width: 45,
                      height: 3,
                      margin: const EdgeInsets.only(top: 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                _buildIcon(iconPath, index),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(String iconPath, int index) {
    bool isSelected = selectedIndex == index;
    Widget icon;

    // Use pure white for all icons, with opacity for unselected
    final Color iconColor = isSelected ? Colors.white : Colors.white.withOpacity(0.7);

    switch (index) {
      case 0: // Home
        icon = Icon(
          Icons.home_rounded,
          size: 24,
          color: iconColor,
        );
        break;
      case 1: // Therapist
        icon = Icon(
          Icons.medical_services_rounded,
          size: 24,
          color: iconColor,
        );
        break;
      case 2: // Feed
        icon = Icon(
          Icons.dynamic_feed_rounded,
          size: 24,
          color: iconColor,
        );
        break;
      case 3: // Settings
        icon = Icon(
          Icons.settings_rounded,
          size: 24,
          color: iconColor,
        );
        break;
      default:
      // For SVG icons, ensure they're white
        icon = SvgPicture.asset(
          iconPath,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            iconColor,
            BlendMode.srcIn,
          ),
        );
    }

    return AnimatedScale(
      scale: isSelected ? 1.1 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: icon,
    );
  }
}