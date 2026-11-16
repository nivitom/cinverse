import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/glass_container.dart';
import 'main_navigation_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  int _selectedDemoIndex = 0;

  @override
  void initState() {
    super.initState();
    _fillPredefinedUser(0);
  }

  void _fillPredefinedUser(int index) {
    final users = AuthService().predefinedUsers;
    if (index >= 0 && index < users.length) {
      final user = users[index];
      setState(() {
        _selectedDemoIndex = index;
        _emailController.text = user.email;
        _passwordController.text = user.password;
        _nameController.text = user.name;
        _phoneController.text = user.phone;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    if (_isLogin) {
      await AuthService().login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } else {
      await AuthService().register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _phoneController.text.trim(),
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  void _continueAsGuest() {
    AuthService().loginAsGuest();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final demoUsers = AuthService().predefinedUsers;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient Glow Background
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Cinema Logo
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.movie_filter_rounded, size: 34, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _isLogin ? 'Welcome to CINEVERSE' : 'Join CINEVERSE Tamil Nadu',
                      style: AppTextStyles.displayMedium.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tamil Nadu’s Premier Cinema Booking Platform',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 4 Predefined Demo Accounts Selector Section
                    _buildDemoAccountsCard(demoUsers),

                    const SizedBox(height: 18),

                    // Tab Switcher (Sign In / Register)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isLogin = true),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _isLogin ? AppColors.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    'Sign In',
                                    style: AppTextStyles.button.copyWith(
                                      fontSize: 14,
                                      color: _isLogin ? Colors.white : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isLogin = false),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: !_isLogin ? AppColors.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    'Register',
                                    style: AppTextStyles.button.copyWith(
                                      fontSize: 14,
                                      color: !_isLogin ? Colors.white : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Auth Form Card
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!_isLogin) ...[
                              Text('Full Name', style: AppTextStyles.caption),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _nameController,
                                style: AppTextStyles.bodyLarge,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                                  hintText: 'Enter your full name',
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
                              ),
                              const SizedBox(height: 14),
                              Text('Phone Number (Tamil Nadu)', style: AppTextStyles.caption),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: AppTextStyles.bodyLarge,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary),
                                  hintText: '+91 98401 23456',
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'Phone is required' : null,
                              ),
                              const SizedBox(height: 14),
                            ],

                            Text('Email Address', style: AppTextStyles.caption),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: AppTextStyles.bodyLarge,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
                                hintText: 'karthik.tn@cineverse.in',
                              ),
                              validator: (v) =>
                                  (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                            ),
                            const SizedBox(height: 14),

                            Text('Password', style: AppTextStyles.caption),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: AppTextStyles.bodyLarge,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: AppColors.textMuted,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                hintText: '••••••••',
                              ),
                              validator: (v) => (v == null || v.length < 4)
                                  ? 'Password must be at least 4 characters'
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            // Submit Button
                            CustomButton(
                              text: _isLogin ? 'Sign In to Account' : 'Create Account',
                              isLoading: _isLoading,
                              onPressed: _submit,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Guest Login Option
                    TextButton(
                      onPressed: _continueAsGuest,
                      child: Text(
                        'Continue as Guest Explorer →',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoAccountsCard(List<UserModel> users) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.vpn_key_rounded, size: 16, color: AppColors.gold),
                  const SizedBox(width: 6),
                  Text(
                    'Predefined Demo Accounts (4 Users)',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                'Tap to autofill',
                style: AppTextStyles.caption.copyWith(color: AppColors.textMuted, fontSize: 10.5),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 4 User Cards
          ...List.generate(users.length, (idx) {
            final u = users[idx];
            final isSelected = _selectedDemoIndex == idx;

            return GestureDetector(
              onTap: () => _fillPredefinedUser(idx),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
                    width: isSelected ? 1.2 : 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: isSelected ? AppColors.primary : AppColors.surfaceBorder,
                      child: Text(
                        '${idx + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                u.name,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '• ${u.city}',
                                style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'Email: ${u.email}  |  Pass: ${u.password}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primary),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
