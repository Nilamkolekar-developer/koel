import 'package:autopeepal/logic/controller/appFeature/imageZoomingPageController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImageZoomingPage extends StatelessWidget {
  const ImageZoomingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ImageZoomingController());
    final bool isTablet =
        MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,

      // ── NavigationPage.TitleView ──────────────────────────
      // ← this.Title = gdImage.image_name
      appBar: AppBar(
        title: Row(
          children: [
            // ── Title = image_name ─────────────────────────
            Expanded(
              child: Text(
                controller.pageTitle,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: isTablet ? 24 : 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // ── ic_iKonnect logo ───────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Image.asset(
                'assets/images/ic_iKonnect.png',
                height: isTablet ? 44 : 30,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),

      // ── Body ──────────────────────────────────────────────
      // ← StackLayout Padding="10,10,10,40"
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 40),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          // ← PinchToZoomContainers BackgroundColor="White"
          color: Colors.white,
          child: _PinchZoomImage(
            // ← img.Source = gdImage.gd_image_dwnld
            imageUrl: controller.gdImage.gdImage,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PinchZoomImage
// ← behaviors:PinchToZoomContainers + Image x:Name="img"
// ─────────────────────────────────────────────────────────────
class _PinchZoomImage extends StatefulWidget {
  final String? imageUrl;

  const _PinchZoomImage({this.imageUrl});

  @override
  State<_PinchZoomImage> createState() => _PinchZoomImageState();
}

class _PinchZoomImageState extends State<_PinchZoomImage> {

  final TransformationController _transformController =
      TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  // ── Double tap toggles zoom ────────────────────────────────
  void _onDoubleTap() {
    if (_transformController.value != Matrix4.identity()) {
      // Reset to original
      _transformController.value = Matrix4.identity();
    } else {
      // Zoom in 2x
      _transformController.value = Matrix4.identity()..scale(2.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformController,
        minScale: 0.5,
        maxScale: 5.0,
        clipBehavior: Clip.none,
        child: Center(
          // ← Image HorizontalOptions="CenterAndExpand"
          //         VerticalOptions="CenterAndExpand"
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final String? url = widget.imageUrl;

    if (url == null || url.isEmpty) {
      return const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
        size: 80,
      );
    }

    return Image.network(
      url,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: progress.expectedTotalBytes != null
                ? progress.cumulativeBytesLoaded /
                    progress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, _) => const Center(
        child: Icon(
          Icons.broken_image,
          color: Colors.grey,
          size: 80,
        ),
      ),
    );
  }
}