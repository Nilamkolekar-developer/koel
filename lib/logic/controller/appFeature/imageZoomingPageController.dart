
import 'package:get/get.dart';
import 'package:autopeepal/models/gd_model.dart';

// ─────────────────────────────────────────────────────────────
// Controller
// ─────────────────────────────────────────────────────────────
class ImageZoomingController extends GetxController {

  late GdImageGD gdImage;
  late String code;

  // ── Matches C#: Title = gdImage.image_name ────────────────
  String get pageTitle => gdImage.imageName ?? '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      gdImage = args['image'] as GdImageGD;
      code    = args['code']  as String? ?? '';
    }
  }
}