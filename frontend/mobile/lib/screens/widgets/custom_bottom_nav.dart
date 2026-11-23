import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String userRole; // 'penulis' | 'kurator' | 'admin' | 'tamu'

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: const Border(top: BorderSide(color: AppColors.borderLight)),
        boxShadow: AppDimens.bottomNavShadow,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.explore_outlined, Icons.explore_rounded, 'Jelajah'),
              if (userRole == 'penulis')
                _buildNavItem(1, Icons.auto_stories_outlined, Icons.auto_stories_rounded, 'Karya Saya')
              else if (userRole == 'kurator' || userRole == 'admin')
                _buildNavItem(1, Icons.assignment_turned_in_outlined, Icons.assignment_turned_in_rounded, 'Kurasi')
              else
                _buildNavItem(1, Icons.login_rounded, Icons.login_rounded, 'Masuk'),
              if (userRole == 'penulis')
                _buildNavItem(2, Icons.cloud_upload_outlined, Icons.cloud_upload_rounded, 'Unggah')
              else if (userRole == 'admin')
                _buildNavItem(2, Icons.manage_accounts_outlined, Icons.manage_accounts_rounded, 'Admin')
              else
                _buildNavItem(2, Icons.info_outline_rounded, Icons.info_rounded, 'Panduan'),
              _buildNavItem(3, Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData filledIcon, String label) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? filledIcon : outlineIcon,
            size: 22,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
