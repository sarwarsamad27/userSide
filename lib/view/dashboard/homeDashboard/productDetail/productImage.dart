import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/full_imageScreen.dart';

class ProductImage extends StatefulWidget {
  final List<String> imageUrls;
  final Function(int)? onImageChange;

  const ProductImage({super.key, required this.imageUrls, this.onImageChange});

  @override
  State<ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<ProductImage> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  String getValidImageUrl(String url) {
    if (url.startsWith('http')) return url;
    if (!url.startsWith('/')) url = '/$url';
    return Global.imageUrl + url;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        child: Image.asset(
          "assets/images/shookoo_image.png",
          fit: BoxFit.cover,
          width: double.infinity,
          height: 0.45.sh,
        ),
      );
    }

    final processedUrls = widget.imageUrls.map(getValidImageUrl).toList();
    int imageCount = processedUrls.length;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullScreenImageGallery(
              images: processedUrls,
              initialIndex: currentIndex,
            ),
          ),
        );
      },
      child: SizedBox(
        height: 0.45.sh,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: imageCount,
              onPageChanged: (index) {
                setState(() => currentIndex = index);
                if (widget.onImageChange != null) widget.onImageChange!(index);
              },
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24.r),
                    bottomRight: Radius.circular(24.r),
                  ),
                  child: Image.network(
                    processedUrls[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                );
              },
            ),
            if (imageCount > 1)
              Positioned(
                bottom: 16.h,
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: widget.imageUrls.isNotEmpty
                      ? widget.imageUrls.length
                      : 1,
                  effect: ExpandingDotsEffect(
                    activeDotColor: Colors.black,
                    dotColor: Colors.grey[400]!,
                    dotHeight: 8.h,   
                    dotWidth: 8.w,
                    spacing: 6.w,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
