import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_recaptcha_v2_compat/flutter_recaptcha_v2_compat.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  RecaptchaV2Controller recaptchaV2Controller = RecaptchaV2Controller();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isRecaptchaVerified = false;

  // ใช้สีจาก Theme แทนการกำหนดแบบ hardcode
  Color get _backgroundColor => Theme.of(context).scaffoldBackgroundColor;
  Color get _cardColor => Theme.of(context).cardColor;
  Color get _primaryColor => Theme.of(context).colorScheme.primary;
  Color get _textColor => Theme.of(context).colorScheme.onSurface;
  Color get _cyanColor =>
      Theme.of(context).extension<CustomColors>()!.cyanColor;
  Color get _blueColor =>
      Theme.of(context).extension<CustomColors>()!.blueColor;
  Color get _hintColor =>
      Theme.of(context).extension<CustomColors>()!.hintColor;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // ตรวจสอบว่ายืนยัน reCAPTCHA แล้วหรือยัง
      if (!_isRecaptchaVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'กรุณายืนยันตัวตนด้วย reCAPTCHA ก่อน',
              style: GoogleFonts.kanit(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0f172a),
              _backgroundColor,
              const Color(0xFF1e293b),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogoSection(),
                const SizedBox(height: 10),
                _buildLoginCard(),
                const SizedBox(height: 24),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              'เข้าสู่ระบบ',
              style: GoogleFonts.kanit(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'เข้าสู่ระบบเพื่อใช้บริการวิเคราะห์มัลแวร์',
              style: GoogleFonts.kanit(fontSize: 14, color: _hintColor),
            ),
            const SizedBox(height: 32),

            // Email Field
            _buildEmailField(),
            const SizedBox(height: 20),

            // Password Field
            _buildPasswordField(),
            const SizedBox(height: 20),

            // Remember Me & Forgot Password
            _buildRememberForgotSection(),
            const SizedBox(height: 24),

            // reCAPTCHA Placeholder
            _buildRecaptchaSection(),
            const SizedBox(height: 24),

            // Login Button
            _buildLoginButton(),
            const SizedBox(height: 32),

            // Register Link
            _buildRegisterLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: GoogleFonts.kanit(
            color: _textColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextFormField(
            controller: _emailController,
            style: GoogleFonts.kanit(color: _textColor),
            decoration: InputDecoration(
              hintText: 'analyst@rampart.security',
              hintStyle: GoogleFonts.kanit(color: _hintColor),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.email_outlined, color: _cyanColor),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'กรุณากรอกอีเมล';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'กรุณากรอกอีเมลให้ถูกต้อง';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Password',
                style: GoogleFonts.kanit(
                  color: _textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to forgot password
              },
              child: Text(
                'Forgot Password?',
                style: GoogleFonts.kanit(
                  color: _cyanColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: GoogleFonts.kanit(color: _textColor),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: GoogleFonts.kanit(color: _hintColor),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.lock_outline, color: _cyanColor),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: _cyanColor.withOpacity(0.7),
                ),
                onPressed: _togglePasswordVisibility,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'กรุณากรอกรหัสผ่าน';
              }
              if (value.length < 6) {
                return 'รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRememberForgotSection() {
    return Row(
      children: [
        // Remember Me Checkbox
        SizedBox(
          height: 24,
          width: 24,
          child: Theme(
            data: ThemeData(unselectedWidgetColor: _hintColor),
            child: Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
              checkColor: _primaryColor,
              fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.selected)) {
                  return _cyanColor;
                }
                return Colors.transparent;
              }),
              side: BorderSide(color: _hintColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'จดจำฉัน',
          style: GoogleFonts.kanit(color: _textColor, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildRecaptchaSection() {
    return Container(
      decoration: BoxDecoration(
        color: _isRecaptchaVerified
            ? Colors.green.withOpacity(0.1)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isRecaptchaVerified
              ? Colors.green
              : Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  _isRecaptchaVerified
                      ? Icons.check_circle
                      : Icons.verified_user_outlined,
                  color: _isRecaptchaVerified ? Colors.green : _cyanColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isRecaptchaVerified
                        ? 'ยืนยันตัวตนสำเร็จ ✓'
                        : 'กรุณายืนยันว่าคุณไม่ใช่บอท',
                    style: GoogleFonts.kanit(
                      color: _isRecaptchaVerified ? Colors.green : _textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_isRecaptchaVerified)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isRecaptchaVerified = false;
                      });
                    },
                    child: Text(
                      'รีเซ็ต',
                      style: GoogleFonts.kanit(color: _cyanColor, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),

          // reCAPTCHA Widget
          if (!_isRecaptchaVerified)
            Container(
              height: 450,
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: RecaptchaV2(
                  apiKey: "6LdhIt0rAAAAACD9j6QUdMZALFZgLIrnufqGfX9g",
                  apiSecret: "6LdhIt0rAAAAAKwSNAcmGbaVpeSEp3OA2L8ncWcB",
                  controller: recaptchaV2Controller,
                  onVerifiedError: (err) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'เกิดข้อผิดพลาด: $err',
                          style: GoogleFonts.kanit(),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  onVerifiedSuccessfully: (success) {
                    setState(() {
                      _isRecaptchaVerified = success;
                    });
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'ยืนยันตัวตนสำเร็จ! ✓',
                            style: GoogleFonts.kanit(),
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  pluginURL:
                      'https://recaptcha-flutter-plugin.firebaseapp.com/',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: _textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: _cyanColor.withOpacity(0.3),
        ),
        child: Stack(
          children: [
            if (_isLoading)
              Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(_textColor),
                  ),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login_outlined, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Login',
                    style: GoogleFonts.kanit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'New to RAMPART? ',
          style: GoogleFonts.kanit(color: _hintColor, fontSize: 14),
        ),
        GestureDetector(
          onTap: () {
            // Navigate to register screen
          },
          child: Text(
            'Create Account',
            style: GoogleFonts.kanit(
              color: _cyanColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.security_outlined, color: _cyanColor, size: 16),
          const SizedBox(width: 8),
          Text(
            'Enterprise Grade Security',
            style: GoogleFonts.kanit(color: _hintColor, fontSize: 12),
          ),
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _hintColor,
              shape: BoxShape.circle,
            ),
          ),
          Icon(Icons.bolt_outlined, color: _cyanColor, size: 16),
          const SizedBox(width: 8),
          Text(
            'CAPEv2 & MobSF',
            style: GoogleFonts.kanit(color: _hintColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // Animated Logo Container
        _buildAnimatedLogo(),
        const SizedBox(height: 10),

        // Title Section
        _buildTitleSection(),
        // const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildAnimatedLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing Background Effect
        TweenAnimationBuilder(
          duration: const Duration(seconds: 2),
          tween: Tween<double>(begin: 0.8, end: 1.2),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_cyanColor.withOpacity(0.1), Colors.transparent],
                  ),
                ),
              ),
            );
          },
        ),

        // Main Logo Container
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            color: _cardColor,
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              // Outer Glow
              BoxShadow(
                color: _cyanColor.withOpacity(0.25),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 0),
              ),
              // Inner Shadow
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
              // Soft Background Shadow
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 40,
                spreadRadius: 10,
                offset: const Offset(0, 10),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _cardColor,
                _cardColor.withOpacity(0.9),
                _cardColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Animated Background Glow
              TweenAnimationBuilder(
                duration: const Duration(seconds: 4),
                tween: Tween<double>(begin: 0, end: 2 * pi),
                builder: (context, value, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      gradient: RadialGradient(
                        colors: [
                          _cyanColor.withOpacity(0.1),
                          _blueColor.withOpacity(0.05),
                          Colors.transparent,
                        ],
                        stops: const [0.1, 0.3, 0.8],
                        center: Alignment(
                          0.5 + 0.3 * cos(value),
                          0.5 + 0.3 * sin(value),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Shimmer Effect Overlay
              TweenAnimationBuilder(
                duration: const Duration(seconds: 3),
                tween: Tween<double>(begin: -1, end: 1),
                builder: (context, value, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: Transform.translate(
                      offset: Offset(value * 200, value * 200),
                      child: Container(
                        width: 200,
                        height: 300,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.2, 0.8, 1.0],
                          ),
                          borderRadius: BorderRadius.circular(35),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Main Logo
              Center(
                child: Container(
                  width: 100,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/RAMPART-LOGO.png',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),

              // Animated Border
              TweenAnimationBuilder(
                duration: const Duration(seconds: 2),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(
                        color: _cyanColor.withOpacity(0.3 * value),
                        width: 1,
                      ),
                    ),
                  );
                },
              ),

              // Floating Particles
              ..._buildFloatingParticles(),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method for floating particles
  List<Widget> _buildFloatingParticles() {
    return [
      _buildParticle(20, 25, _cyanColor, 2, 0),
      _buildParticle(110, 35, _blueColor, 1.5, 1000),
      _buildParticle(30, 100, _cyanColor, 1, 2000),
      _buildParticle(100, 110, _blueColor, 2, 1500),
    ];
  }

  Widget _buildParticle(
    double x,
    double y,
    Color color,
    double size,
    int delay,
  ) {
    return Positioned(
      left: x,
      top: y,
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 3000),
        tween: Tween<double>(begin: 0, end: 2 * pi),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 2 * sin(value)),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color.withOpacity(0.6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        // Main Title
        ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [Colors.white, _cyanColor, _blueColor],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: Text(
            'RAMPART',
            style: GoogleFonts.kanit(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              height: 1.0,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 4),

        // Subtitle with Icon
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, color: _cyanColor, size: 18),
            const SizedBox(width: 8),
            Text(
              'Threat Analysis Platform',
              style: GoogleFonts.kanit(
                fontSize: 16,
                color: _textColor.withOpacity(0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
