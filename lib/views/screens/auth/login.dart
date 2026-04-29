import 'package:autopeepal/logic/controller/auth/loginController.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);
  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800; // desktop/web breakpoint

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: isWide ? _buildWideLayout() : _buildMobileLayout(),
    );
  }

  // ── Desktop/Web Layout (two columns) ─────────────────────────────
  Widget _buildWideLayout() {
    return Row(
      children: [
        // Left Panel — branding
        Expanded(
          flex: 5,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF309F93), Color(0xFF1A6B62)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/new/autopeepal(1).png',
                  height: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Sign in to continue to Autopeepal',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 48),
                // Decorative circles
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == 0 ? 12 : 8,
                    height: i == 0 ? 12 : 8,
                    decoration: BoxDecoration(
                      color: i == 0
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                  )),
                ),
              ],
            ),
          ),
        ),

        // Right Panel — form
        Expanded(
          flex: 4,
          child: Container(
            color: Colors.white,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 48, vertical: 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: _buildForm(isWide: true),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Mobile Layout (single column) ────────────────────────────────
  Widget _buildMobileLayout() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Image.asset('assets/new/autopeepal(1).png', height: 60),
            const SizedBox(height: 48),
            _buildForm(isWide: false),
          ],
        ),
      ),
    );
  }

  // ── Shared Form ───────────────────────────────────────────────────
  Widget _buildForm({required bool isWide}) {
    const Color themeColor = Color(0xFF309F93);
    //const Color accentColor = Color(0xFFFF7A18);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isWide) ...[
          const Text(
            'Sign In',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your credentials to access your account',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 36),
        ],

        // Username Field
        _fieldLabel('User ID'),
        const SizedBox(height: 6),
        TextField(
          controller: controller.usernameController.value,
          cursorColor: themeColor,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: _inputDecoration(
            'Enter your registered User ID',
            prefixIcon: Icons.person_outline,
            themeColor: themeColor,
          ),
        ),

        const SizedBox(height: 20),

        // Password Field
        _fieldLabel('Password'),
        const SizedBox(height: 6),
        Obx(() => TextField(
              controller: controller.passwordController.value,
              obscureText: controller.hidePassword.value,
              cursorColor: themeColor,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: _inputDecoration(
                'Enter your password',
                prefixIcon: Icons.lock_outline,
                themeColor: themeColor,
                suffix: IconButton(
                  icon: Icon(
                    controller.hidePassword.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey,
                    size: 22,
                  ),
                  onPressed: controller.hidePassword.toggle,
                ),
              ),
            )),

        const SizedBox(height: 12),

        // Remember Me + Register
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() => Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: controller.isRememberMeChecked.value,
                        onChanged: (v) =>
                            controller.isRememberMeChecked.value = v ?? false,
                        activeColor: themeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Remember me',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                )),
            TextButton(
              onPressed: () => Get.offAllNamed(Routes.registerScreen),
              style: TextButton.styleFrom(
                foregroundColor: themeColor,
                padding: EdgeInsets.zero,
              ),
              child: const Text(
                'Register',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Login Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: (){
              Get.offAllNamed(Routes.esnScreen);
            },
            child: const Text(
              'LOG IN',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),

        const SizedBox(height: 40),

        // Powered by
        Center(
          child: Column(
            children: [
              const Text(
                'Powered by',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
              const SizedBox(height: 4),
              Image.asset(
                'assets/new/autopeepal(1).png',
                height: 24,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A2E),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint, {
    required IconData prefixIcon,
    required Color themeColor,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      prefixIcon: Icon(prefixIcon, color: Colors.grey, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8F9FC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: themeColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }
}