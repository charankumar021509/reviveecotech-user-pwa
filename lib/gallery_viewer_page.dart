import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryViewerPage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const GalleryViewerPage({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<GalleryViewerPage> createState() => _GalleryViewerPageState();
}

class _GalleryViewerPageState extends State<GalleryViewerPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We use a black background for a better gallery feel
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // --- The Main Swipable Gallery ---
          PhotoViewGallery.builder(
            pageController: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: onPageChanged,
            builder: (context, index) {
              final imageUrl = widget.imageUrls[index];
              return PhotoViewGalleryPageOptions(
                imageProvider: AssetImage(imageUrl),
                // This enables the zoom
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                // This connects the Hero animation
                heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
              );
            },
            // Show a loading spinner while images load
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),

          // --- Close Button (Top Left) ---
          Positioned(
            top: 40,
            left: 16,
            child: SafeArea(
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // --- Image Counter (Bottom Center) ---
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '${_currentIndex + 1} / ${widget.imageUrls.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  shadows: [Shadow(blurRadius: 4)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
