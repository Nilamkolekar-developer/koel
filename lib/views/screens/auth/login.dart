// import 'package:autopeepal/common_widgets/ui_helper_widgets.dart';
// import 'package:autopeepal/logic/controller/auth/loginController.dart';
// import 'package:autopeepal/routes/routes_string.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class LoginScreen extends StatelessWidget {
//   LoginScreen({Key? key}) : super(key: key);
//   final LoginController controller = Get.put(LoginController());

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isWide = size.width > 800; // desktop/web breakpoint

//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6FA),
//       body: isWide ? _buildWideLayout() : _buildMobileLayout(),
//     );
//   }

//   // ── Desktop/Web Layout (two columns) ─────────────────────────────
//   Widget _buildWideLayout() {
//     return Row(
//       children: [
//         // Left Panel — branding
//         Expanded(
//           flex: 5,
//           child: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF309F93), Color(0xFF1A6B62)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.asset(
//                   "assets/new/loginicon.png",
//                   height: 80,
//                 ),
//                 const SizedBox(height: 32),
//                 const Text(
//                   'Welcome Back',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 const Text(
//                   'Sign in to continue to Autopeepal',
//                   style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 48),
//                 // Decorative circles
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: List.generate(
//                       3,
//                       (i) => Container(
//                             margin: const EdgeInsets.symmetric(horizontal: 4),
//                             width: i == 0 ? 12 : 8,
//                             height: i == 0 ? 12 : 8,
//                             decoration: BoxDecoration(
//                               color: i == 0
//                                   ? Colors.white
//                                   : Colors.white.withOpacity(0.4),
//                               shape: BoxShape.circle,
//                             ),
//                           )),
//                 ),
//               ],
//             ),
//           ),
//         ),

//         // Right Panel — form
//         Expanded(
//           flex: 4,
//           child: Container(
//             color: Colors.white,
//             child: Center(
//               child: SingleChildScrollView(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
//                 child: ConstrainedBox(
//                   constraints: const BoxConstraints(maxWidth: 400),
//                   child: _buildForm(isWide: true, context: context),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ── Mobile Layout (single column) ────────────────────────────────
//   Widget _buildMobileLayout(BuildContext context) {
//     return SafeArea(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
//         child: Column(
//           children: [
//             const SizedBox(height: 60),
//             Image.asset('assets/new/autopeepal(1).png', height: 60),
//             const SizedBox(height: 48),
//             _buildForm(isWide: false, context: context),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Shared Form ───────────────────────────────────────────────────
//   Widget _buildForm({
//     required bool isWide,
//     required BuildContext context,
//   }) {
//     const Color themeColor = Color(0xFF309F93);
//     //const Color accentColor = Color(0xFFFF7A18);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (isWide) ...[
//           const Text(
//             'Sign In',
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF1A1A2E),
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Enter your credentials to access your account',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey,
//             ),
//           ),
//           const SizedBox(height: 36),
//         ],

//         // Username Field
//         _fieldLabel('User ID'),
//         const SizedBox(height: 6),
//         TextField(
//           controller: controller.usernameController.value,
//           cursorColor: themeColor,
//           style: const TextStyle(fontSize: 14, color: Colors.black87),
//           decoration: _inputDecoration(
//             'Enter your registered User ID',
//             prefixIcon: Icons.person_outline,
//             themeColor: themeColor,
//           ),
//         ),

//         const SizedBox(height: 20),

//         // Password Field
//         _fieldLabel('Password'),
//         const SizedBox(height: 6),
//         Obx(() => TextField(
//               controller: controller.passwordController.value,
//               obscureText: controller.hidePassword.value,
//               cursorColor: themeColor,
//               style: const TextStyle(fontSize: 14, color: Colors.black87),
//               decoration: _inputDecoration(
//                 'Enter your password',
//                 prefixIcon: Icons.lock_outline,
//                 themeColor: themeColor,
//                 suffix: IconButton(
//                   icon: Icon(
//                     controller.hidePassword.value
//                         ? Icons.visibility_outlined
//                         : Icons.visibility_off_outlined,
//                     color: Colors.grey,
//                     size: 22,
//                   ),
//                   onPressed: controller.hidePassword.toggle,
//                 ),
//               ),
//             )),

//         const SizedBox(height: 12),

//         // Remember Me + Register
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             TextButton(
//               onPressed: () => Get.offAllNamed(Routes.registerScreen),
//               style: TextButton.styleFrom(
//                 foregroundColor: themeColor,
//                 padding: EdgeInsets.zero,
//               ),
//               child: const Text(
//                 'New Account',
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             TextButton(
//               onPressed: () => Get.offAllNamed(Routes.registerScreen),
//               style: TextButton.styleFrom(
//                 foregroundColor: themeColor,
//                 padding: EdgeInsets.zero,
//               ),
//               child: const Text(
//                 'Forgot Password?',
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Obx(() => Row(
//                   children: [
//                     const Text(
//                       'Remember me',
//                       style: TextStyle(fontSize: 13, color: Colors.black54),
//                     ),
//                     const SizedBox(width: 8),
//                     SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: Checkbox(
//                         value: controller.isRememberMeChecked.value,
//                         onChanged: (v) =>
//                             controller.isRememberMeChecked.value = v ?? false,
//                         activeColor: themeColor,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ),
//                     ),
//                   ],
//                 )),
//           ],
//         ),

//         const SizedBox(height: 28),

//         // Login Button
//         SizedBox(
//           width: double.infinity,
//           height: 50,
//           child: ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: themeColor,
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             onPressed: () {
//               Get.offAllNamed(Routes.esnScreen);
//             },
//             child: const Text(
//               'Sign In',
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//                 letterSpacing: 1.2,
//               ),
//             ),
//           ),
//         ),
//         C5(),
//         Center(
//           child: GestureDetector(
//             onTap: () {
//               showHelpDialog(context); // your popup function
//             },
//             child: const Text(
//               'Need Help?',
//               style: TextStyle(
//                 fontSize: 13,
//                 color: Color(0xFF309F93), // themeColor
//                 decoration: TextDecoration.underline, // makes it look clickable
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 40),

//         // Powered by
//         Center(
//           child: Column(
//             children: [
//               // const Text(
//               //   'Powered by',
//               //   style: TextStyle(color: Colors.grey, fontSize: 11),
//               // ),
//               //const SizedBox(height: 4),
//               Image.asset(
//                 "assets/new/ic_ikonnect.jpg",

//                 //'assets/new/autopeepal(1).png',
//                 height: 35,
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   void showHelpDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // 🔹 Header
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: const BoxDecoration(
//                   color: Color(0xFF309F93), // themeColor
//                   borderRadius: BorderRadius.vertical(
//                     top: Radius.circular(12),
//                   ),
//                 ),
//                 child: const Text(
//                   "Help",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),

//               // 🔹 Body
//               Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   children: const [
//                     Text(
//                       "Please reach out to KOEL HO team in case of any assistance with the app (F24134C472C50AAD)",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(fontSize: 14),
//                     ),
//                   ],
//                 ),
//               ),

//               // 🔹 Buttons
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       child: const Text("Cancel"),
//                     ),
//                     const SizedBox(width: 10),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Color(0xFF309F93),
//                       ),
//                       onPressed: () {
//                         Navigator.pop(context);
//                         // TODO: Create Ticket action
//                       },
//                       child: const Text("Create Ticket"),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _fieldLabel(String label) {
//     return Text(
//       label,
//       style: const TextStyle(
//         fontSize: 13,
//         fontWeight: FontWeight.w600,
//         color: Color(0xFF1A1A2E),
//       ),
//     );
//   }

//   InputDecoration _inputDecoration(
//     String hint, {
//     required IconData prefixIcon,
//     required Color themeColor,
//     Widget? suffix,
//   }) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
//       prefixIcon: Icon(prefixIcon, color: Colors.grey, size: 20),
//       suffixIcon: suffix,
//       filled: true,
//       fillColor: const Color(0xFFF8F9FC),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: Colors.grey.shade200),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: Colors.grey.shade200),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: themeColor, width: 1.5),
//       ),
//       contentPadding: const EdgeInsets.symmetric(
//         horizontal: 16,
//         vertical: 14,
//       ),
//     );
//   }
// }
import 'package:autopeepal/common_widgets/ui_helper_widgets.dart';
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
    final isWide = size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: isWide
          ? _buildWideLayout(context)
          : _buildMobileLayout(context),
    );
  }

  // ── Desktop/Web Layout ─────────────────────────────
  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        // Left Panel
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
                Image.asset("assets/new/loginicon.png", height: 80),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == 0 ? 12 : 8,
                      height: i == 0 ? 12 : 8,
                      decoration: BoxDecoration(
                        color: i == 0
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right Panel
        Expanded(
          flex: 4,
          child: Container(
            color: Colors.white,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 40,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: _buildForm(isWide: true, context: context),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Mobile Layout ────────────────────────────────
  Widget _buildMobileLayout(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Image.asset('assets/new/autopeepal(1).png', height: 60),
            const SizedBox(height: 48),
            _buildForm(isWide: false, context: context),
          ],
        ),
      ),
    );
  }

  // ── Shared Form ───────────────────────────────────
  Widget _buildForm({
    required bool isWide,
    required BuildContext context,
  }) {
    const Color themeColor = Color(0xFF309F93);

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
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 36),
        ],

        // User ID
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

        // Password
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

        // Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => Get.offAllNamed(Routes.registerScreen),
              style: TextButton.styleFrom(
                foregroundColor: themeColor,
                padding: EdgeInsets.zero,
              ),
              child: const Text(
                'New Account',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () => Get.offAllNamed(Routes.registerScreen),
              style: TextButton.styleFrom(
                foregroundColor: themeColor,
                padding: EdgeInsets.zero,
              ),
              child: const Text(
                'Forgot Password?',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),

        Row(
          children: [
            Obx(() => Row(
                  children: [
                    Checkbox(
                      value: controller.isRememberMeChecked.value,
                      onChanged: (v) =>
                          controller.isRememberMeChecked.value = v ?? false,
                      activeColor: themeColor,
                    ),
                    const Text(
                      'Remember me',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                )),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Get.offAllNamed(Routes.esnScreen);
            },
            child: const Text(
              'Sign In',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),

        C5(),

        Center(
          child: GestureDetector(
            onTap: () => showHelpDialog(context),
            child: const Text(
              'Need Help?',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF309F93),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),

        const SizedBox(height: 40),

        Center(
          child: Image.asset(
            "assets/new/ic_ikonnect.jpg",
            height: 35,
          ),
        ),
      ],
    );
  }

  // ── Help Dialog ───────────────────────────────
  void showHelpDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        // Shape ensures the dialog corners are rounded
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        // InsetPadding prevents the dialog from touching the screen edges on mobile/Windows
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Container(
          // Limit the width so it doesn't look too wide on your Windows laptop
          constraints: const BoxConstraints(maxWidth: 400), 
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Header Section ---
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFF309F93),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "Help",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // --- Content Section ---
              // --- Content Section ---
const Padding(
  padding: EdgeInsets.fromLTRB(24, 30, 24, 10),
  child: Column(
    children: [
      Text(
        "Please reach out to KOEL HO team in case of any assistance with the app",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
          height: 1.4,
        ),
      ),
      SizedBox(height: 12), // Space for the new line
      Text(
        "(F24134C472C50AAD)",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF309F93), // Using your teal color for the code
          letterSpacing: 1.2,
        ),
      ),
    ],
  ),
),

              // --- Action Buttons Section ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel Button
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Create Ticket Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF309F93),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                    Get.toNamed(Routes.tickitScreen);
                      },
                      child: const Text(
                        "Create Ticket",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
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
      prefixIcon: Icon(prefixIcon, color: Colors.grey),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8F9FC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}