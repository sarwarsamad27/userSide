import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/network/network_api_services.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/resources/utiles.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/followUnFollow_provider.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/otherProduct.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/relatedPoduct.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/widgets/bottomActionBar.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/widgets/productMainCard.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getSingleProduct_provider.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/otherProduct_provider.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/productDetailUI_provider.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/relatedProduct_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  // Optional — historically came from the share link's query params, but
  // both are stored on the product itself, so the backend (and this screen)
  // resolve them via productId alone once the product fetch completes.
  // Kept accepting them for any caller that still has them on hand, but
  // never relied upon directly.
  final String? profileId;
  final String? categoryId;
  final String productId;

  const ProductDetailScreen({
    super.key,
    this.profileId,
    this.categoryId,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      /// ───────── Fetch the product first — profileId/categoryId for the
      /// follow-status + tracking calls below are resolved from its
      /// response, never required up front. ─────────
      final provider = context.read<GetSingleProductProvider>();
      await provider.fetchSingleProduct(widget.productId);
      if (!mounted) return;

      final resolvedProfileId =
          provider.productData?.product?.profileId ?? widget.profileId ?? '';
      final resolvedCategoryId =
          provider.productData?.product?.categoryId ?? widget.categoryId ?? '';

      context.read<RelatedProductProvider>().fetchRelatedProducts(
        widget.productId,
      );

      context.read<OtherProductProvider>().fetchOtherProducts(widget.productId);

      /// ───────── Fetch Follow status for Follower count ─────────
      if (resolvedProfileId.isNotEmpty) {
        context.read<FollowProvider>().getFollowStatus(resolvedProfileId);
      }

      /// ───────── Track product view ─────────
      _trackProductView(resolvedProfileId, resolvedCategoryId);
    });
  }

  /// 🔥 PRODUCT VIEW TRACKING (login required nahi)
  Future<void> _trackProductView(String profileId, String categoryId) async {
    try {
      final deviceId = await LocalStorage.getOrCreateDeviceId();

      await NetworkApiServices().postApi(Global.TrackProduct, {
        "deviceId": deviceId,
        "productId": widget.productId,
        "categoryId": categoryId,
        "profileId": profileId,
      });
    } catch (e) {
      debugPrint("Product tracking failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GetSingleProductProvider>();

    /// ───────── Loading State ─────────
    if (provider.loading || provider.productData == null) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: const Color(0xFFF6F7F9),
          body: Utils.shoppingLoadingLottie(size: 180),
        ),
      );
    }

    final data = provider.productData!;
    if (data.product == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Utils.notFound(size: 300.sp),
              Text("No product Found"),
            ],
          ),
        ),
      );
    }

    final product = data.product!;

    /// 🔥 IMPORTANT FLAGS (API based)
    final bool productHasColors =
        product.color != null && product.color!.isNotEmpty;
    final bool productHasSizes =
        product.size != null && product.size!.isNotEmpty;
    final String stockStatus = (product.stock ?? "In Stock").trim();

    return ChangeNotifierProvider<ProductDetailUiProvider>(
      create: (_) =>
          ProductDetailUiProvider(initialImages: product.images ?? <String>[]),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        body: Stack(
          children: [
            /// ───────── Scroll Content ─────────
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 100.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Main product card
                  ProductMainCard(data: data),

                  SizedBox(height: 14.h),

                  /// Related products
                  const RelatedProductsSection(),

                  SizedBox(height: 14.h),

                  /// Other products
                  const OtherProductsSection(),
                ],
              ),
            ),

            /// ───────── Bottom Action Bar ─────────
            BottomActionBar(
              productId: product.sId ?? '',
              imageUrls: product.images ?? <String>[],
              name: product.name ?? '',
              description: product.description ?? '',
              price: '${product.afterDiscountPrice ?? 0}',
              brandName: data.profileName ?? '',
              productHasColors: productHasColors,
              productHasSizes: productHasSizes,
              stockStatus: stockStatus,
              quantity: product.quantity,
            ),
          ],
        ),
      ),
    );
  }
}
