import 'package:flutter/material.dart';

// // Common Text Field Widget - Optimized for Windows & "Bigger" feel
// class CustomFormField extends StatelessWidget {
//   final String label;
//   final String hint;
//   final int maxLines;

//   const CustomFormField({
//     super.key,
//     required this.label,
//     required this.hint,
//     this.maxLines = 1,
//   });

//   @override
//   Widget build(BuildContext context) {
//     const Color themeColor = Color(0xFF309F93);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 15, // Slightly larger label
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 10), // More space between label and field
//         TextFormField(
//           maxLines: maxLines,
//           style: const TextStyle(fontSize: 16), // Larger input text
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
//             // Increased vertical padding makes the field "bigger"
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//             enabledBorder: OutlineInputBorder(
//               borderSide: const BorderSide(color: themeColor, width: 1.2),
//               borderRadius: BorderRadius.circular(4), // Sharper Windows style
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderSide: const BorderSide(color: themeColor, width: 2.2),
//               borderRadius: BorderRadius.circular(4),
//             ),
//             filled: true,
//             fillColor: Colors.white,
//           ),
//         ),
//         const SizedBox(height: 20), // More breathing room between fields
//       ],
//     );
//   }
// }

// // Common Checkbox Widget - Optimized for Windows
// class CustomCheckbox extends StatelessWidget {
//   final String label;
//   final bool value;
//   final Function(bool?) onChanged;

//   const CustomCheckbox({
//     super.key,
//     required this.label,
//     required this.value,
//     required this.onChanged
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () => onChanged(!value),
//       borderRadius: BorderRadius.circular(4),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(
//               height: 24,
//               width: 24,
//               child: Checkbox(
//                 value: value,
//                 onChanged: onChanged,
//                 activeColor: const Color(0xFF309F93),
//                 side: const BorderSide(width: 1.5, color: Colors.grey),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
//               ),
//             ),
//             const SizedBox(width: 12), // More space between check and text
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 15, // Matching larger font
//                 color: Colors.black,
//               )
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
class CustomFormField extends StatelessWidget {
  final String label;
  final String hint;
  final int maxLines;
  final bool enabled;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final VoidCallback? onTap;

  const CustomFormField(
      {super.key,
      required this.label,
      required this.hint,
      this.maxLines = 1,
      this.enabled = true,
      this.controller,
      this.onChanged,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    const Color themeColor = Color(0xFF309F93);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          onTap: onTap,
          readOnly: onTap != null, // optional but recommended
          controller: controller,
          onChanged: onChanged, // ✅ THIS FIXES YOUR ERROR
          enabled: enabled,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: themeColor, width: 1.2),
              borderRadius: BorderRadius.circular(4),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: themeColor, width: 2.2),
              borderRadius: BorderRadius.circular(4),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
