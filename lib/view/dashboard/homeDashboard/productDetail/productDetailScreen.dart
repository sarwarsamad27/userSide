import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/otherProduct.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/relatedPoduct.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/widgets/bottomActionBar.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/widgets/productMainCard.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getSingleProduct_provider.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/otherProduct_provider.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/productDetailUI_provider.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/relatedProduct_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final String profileId;
  final String categoryId;
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.profileId,
    required this.categoryId,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 🔹 Existing APIs (NO CHANGE)
      context.read<GetSingleProductProvider>().fetchSingleProduct(
        widget.profileId,
        widget.categoryId,
        widget.productId,
      );

      context.read<RelatedProductProvider>().fetchRelatedProducts(
        widget.productId,
        widget.categoryId,
      );

      context.read<OtherProductProvider>().fetchOtherProducts(
        widget.productId,
      );

      // 🔥 NEW: Track product view
      _trackProductView();
    });
  }
 
  /// 🔥 PRODUCT VIEW TRACKING (LOGIN REQUIRED NAHI)
  Future<void> _trackProductView() async {
    try {
      final deviceId = await LocalStorage.getOrCreateDeviceId();

      await NetworkApiServices().postApi(
        Global.TrackProduct,
        {
          "deviceId": deviceId,
          "productId": widget.productId,
          "categoryId": widget.categoryId,
          "profileId": widget.profileId,
        },
      );
    } catch (e) {
      // UX disturb nahi karna
      debugPrint("Product tracking failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GetSingleProductProvider>();

    if (provider.loading || provider.productData == null) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: const Color(0xFFF6F7F9),
          body: Center(
            child: SpinKitThreeBounce(color: AppColor.primaryColor, size: 30.0),
          ),
        ),
      );
    }

    final data = provider.productData!;
    if (data.product == null) {
      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: const Color(0xFFF6F7F9),
          body: Center(
            child: Text(
              "Product not found",
              style: TextStyle(color: Colors.red, fontSize: 18.sp),
            ),
          ),
        ),
      );
    }

    final product = data.product!;

    return ChangeNotifierProvider<ProductDetailUiProvider>(
      create: (_) =>
          ProductDetailUiProvider(initialImages: product.images ?? <String>[]),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main card includes ProductImage, brand row, description, colors/sizes, reviews
                  ProductMainCard(data: data),

                  SizedBox(height: 14.h),

                  // Related Products
                  const RelatedProductsSection(),

                  SizedBox(height: 14.h),

                  // Other Products
                  const OtherProductsSection(),

                  SizedBox(height: 28.h),
                ],
              ),
            ),

            // Bottom Buttons (same design/placement)
            BottomActionBar(
              productId: product.sId ?? '',
              imageUrls: product.images ?? <String>[],
              name: product.name ?? '',
              
              description: product.description ?? '',
              price: '${product.afterDiscountPrice ?? 0}',
              brandName: data.profileName ?? '',
            ),
          ],
        ),
      ),
    );
  }
}
