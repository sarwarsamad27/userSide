import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/full_imageScreen.dart';

class ProductImage extends StatelessWidget {
  final List<String> imageUrls;
 
    final PageController _pageController = PageController();

   ProductImage({super.key,
    required this.imageUrls,
    
   });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullScreenImageGallery(
                            images: imageUrls,
                            initialIndex: _pageController.page?.round() ?? 0,
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
                            itemCount:imageUrls.length,
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(24.r),
                                  bottomRight: Radius.circular(24.r),
                                ),
                                child: Image.network(
                                  imageUrls[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              );
                            },
                          ),
                          Positioned(
                            bottom: 16.h,
                            child: SmoothPageIndicator(
                              controller: _pageController,
                              count: imageUrls.length,
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