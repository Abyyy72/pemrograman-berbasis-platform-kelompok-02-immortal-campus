import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimens.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController(text: 'amanda@campus.ac.id');
  final _passwordController = TextEditingController(text: 'password123');
  String _selectedRole = 'penulis'; // 'penulis' | 'kurator' | 'admin'

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleQuickFill(String role) {
    setState(() {
      _selectedRole = role;
      if (role == 'admin') {
        _identifierController.text = 'admin@campus.ac.id';
      } else if (role == 'kurator') {
        _identifierController.text = 'rina.suryani@campus.ac.id';
      } else {
        _identifierController.text = 'amanda@campus.ac.id';
      }
      _passwordController.text = 'password123';
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.pagePadding * 1.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              // Brand Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.all_inclusive_rounded,
                  color: AppColors.primary,
                  size: 38,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'IMMORTAL CAMPUS',
                style: AppTypography.displayBold(size: 22, color: AppColors.primary),
              ),
              Text(
                'Portal Repositori & Etalase Karya Ilmiah',
                style: AppTypography.caption(size: 12),
              ),
              const SizedBox(height: 30),

              // Role Selector Tabs
              Row(
                children: [
                  _buildRoleTab('Mahasiswa', 'penulis'),
                  const SizedBox(width: 8),
                  _buildRoleTab('Kurator', 'kurator'),
                  const SizedBox(width: 8),
                  _buildRoleTab('Admin', 'admin'),
                ],
              ),
              const SizedBox(height: 20),

              // Form Box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: AppDimens.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email / NIM / NIP', style: AppTypography.headingBold(size: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _identifierController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text('Kata Sandi', style: AppTypography.headingBold(size: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (authProv.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          authProv.errorMessage!,
                          style: AppTypography.caption(size: 12, color: AppColors.error),
                        ),
                      ),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: authProv.isLoading
                            ? null
                            : () async {
                                final success = await authProv.login(
                                  _identifierController.text,
                                  _passwordController.text,
                                  _selectedRole,
                                );
                                if (success) {
                                  widget.onLoginSuccess();
                                }
                              },
                        child: authProv.isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text('Masuk Sekarang', style: AppTypography.labelBold(size: 14, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Quick Fill Accounts Chips
              Text('Akun Pengujian Demo:', style: AppTypography.caption(size: 11)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    label: const Text('Isi Mahasiswa (Amanda)'),
                    onPressed: () => _handleQuickFill('penulis'),
                  ),
                  ActionChip(
                    label: const Text('Isi Kurator (Dr. Rina)'),
                    onPressed: () => _handleQuickFill('kurator'),
                  ),
                  ActionChip(
                    label: const Text('Isi Super Admin'),
                    onPressed: () => _handleQuickFill('admin'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleTab(String label, String role) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => _handleQuickFill(role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.labelBold(
              size: 11,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
