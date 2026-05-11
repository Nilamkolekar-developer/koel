import 'package:autopeepal/logic/controller/appFeature/gdImageController.dart';
import 'package:autopeepal/models/gd_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GdImagePage extends StatelessWidget {
  const GdImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller  = Get.put(GdImageController());
    final bool isTablet =
        MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,

      // ── NavigationPage.TitleView ──────────────────────────
      appBar: AppBar(
        title: Row(
          children: [
            // ── Label (empty text, matches MAUI) ───────────
            Expanded(
              child: Text(
                '',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: isTablet ? 24 : 16,
                ),
              ),
            ),
            // ── ic_iKonnect logo ───────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Image.asset(
                'assets/new/ic_iKonnect.jpg',
                height: isTablet ? 44 : 30,
                width:  isTablet ? 44 : 30,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),

      // ── Body ──────────────────────────────────────────────
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 0, 40),
        child: controller.gdImages.isEmpty
            ? const Center(child: Text("No images available"))
            : GridView.builder(
                itemCount: controller.gdImages.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,       // Span="2"
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  childAspectRatio: 1,     // adjusted below per idiom
                ),
                itemBuilder: (context, index) {
                  final GdImageGD item = controller.gdImages[index];
                  return _ImageCard(
                    item:      item,
                    isTablet:  isTablet,
                    onTapped:  () => controller.onImageTapped(index),
                  );
                },
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Image Card  ← DataTemplate item
// ─────────────────────────────────────────────────────────────
class _ImageCard extends StatelessWidget {
  final GdImageGD item;
  final bool isTablet;
  final VoidCallback onTapped;

  const _ImageCard({
    required this.item,
    required this.isTablet,
    required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    // HeightRequest: Phone=185, Tablet=260
    final double cardHeight = isTablet ? 260 : 185;

    // Label height: Phone=18, Tablet=25
    final double labelHeight = isTablet ? 25 : 18;

    return SizedBox(
      height: cardHeight,
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 15, 15, 0), // Margin="0,15,15,0"
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),         // BorderColor="Gray"
          borderRadius: BorderRadius.zero,                // CornerRadius="0"
        ),
        child: Column(
          children: [
            // ── Image (Height="*") ─────────────────────────
            Expanded(
              child: GestureDetector(
                onTap: onTapped,
                child: _buildImage(item.gdImage),
              ),
            ),

            // ── image_name label ───────────────────────────
            SizedBox(
              height: labelHeight,
              child: Container(
                color: Colors.white,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  item.imageName ?? '',
                  style: TextStyle(
                    fontSize: isTablet ? 13 : 11,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty) {
      return const Center(
        child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
      );
    }

    // ── Network image with loading / error states ──────────
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Full Screen Image Dialog  ← TapGestureRecognizer_Tapped
// ─────────────────────────────────────────────────────────────
// ignore: unused_element
class _FullScreenImageDialog extends StatelessWidget {
  final String imageUrl;

  const _FullScreenImageDialog({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          // ── Full screen image ────────────────────────────
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 60,
                      ),
                    )
                  : const Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
                      size: 60,
                    ),
            ),
          ),

          // ── Close button ─────────────────────────────────
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }
}