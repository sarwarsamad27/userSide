import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productDetailScreen.dart';
import 'package:user_side/widgets/customBgContainer.dart';
import 'package:user_side/widgets/productCard.dart';

class CompanyProfileScreen extends StatefulWidget {
  final String companyName;
  final String logoUrl;
  final String bannerUrl;

  const CompanyProfileScreen({
    super.key,
    required this.companyName,
    required this.logoUrl,
    required this.bannerUrl,
  });

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  int selectedCategory = 0;
  bool isFollowing = false;
  int followerCount = 1250; // starting followers (example)

  final List<String> categories = [
    "Shoes",
    "Bags",
    "Clothing",
    "Accessories",
    "Beauty",
  ];

  final List<Map<String, String>> products = List.generate(
    10,
    (index) => {
      "name": "Product ${index + 1}",
      "price": "₹${(index + 1) * 299}",
      "imageUrl": "https://picsum.photos/200/200?random=$index",
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomBgContainer(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 200.h,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/shookoo_image.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -45,
                    left: 20.w,
                    child: CircleAvatar(
                      radius: 45.r,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 43.r,
                        backgroundImage: NetworkImage(widget.logoUrl),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 55.h),

              /// 🔹 Company Name + Follow Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.companyName,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFollowing
                            ? Colors.white
                            : AppColor.primaryColor,
                        elevation: 0,
                        side: isFollowing
                            ? BorderSide(color: AppColor.primaryColor)
                            : BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          isFollowing = !isFollowing;
                          followerCount += isFollowing ? 1 : -1;
                        });
                      },
                      icon: Icon(
                        isFollowing ? Icons.favorite : Icons.favorite_border,
                        color: isFollowing
                            ? AppColor.primaryColor
                            : Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        isFollowing ? "Following" : "Follow",
                        style: TextStyle(
                          color: isFollowing
                              ? AppColor.primaryColor
                              : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6.h),

              /// 👥 Follower Count
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  "${(followerCount / 1000).toStringAsFixed(1)}k Followers",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 15.h),

              /// 📍 Contact / Info Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    contactTile(Icons.phone, "Call", Colors.green, () {}),
                    contactTile(Icons.email, "Email", Colors.red, () {}),
                  ],
                ),
              ),

              SizedBox(height: 15.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  "At ${widget.companyName}, we offer high-quality, trend-forward products designed to enhance your lifestyle. "
                  "We prioritize craftsmanship, comfort, and innovation to provide you with a premium shopping experience.",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              /// 🗂 Categories
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10.h),

              SizedBox(
                height: 45.h,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => SizedBox(width: 10.w),
                  itemBuilder: (_, index) {
                    final isSelected = selectedCategory == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedCategory = index);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColor.primaryColor
                              : AppColor.primaryColor.withOpacity(.3),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Center(
                          child: Text(
                            categories[index],
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20.h),

              /// 🛍 Products Grid (using ProductCard)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  "Products",
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    mainAxisExtent: 250.h,
                  ),
                  itemBuilder: (_, index) {
                    final item = products[index];
                    return ProductCard(
                      name: item['name']!,
                      price: item['price']!,
                      imageUrl: item['imageUrl']!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(
                              imageUrls: [
                                item['imageUrl']!,
                                item['imageUrl']!,
                                item['imageUrl']!,
                              ],
                              name: item['name']!,
                              description:
                                  "At ${widget.companyName}, we offer high-quality, trend-forward products designed to enhance your lifestyle. "
                                  "We prioritize craftsmanship, comfort, and innovation to provide you with a premium shopping experience.",
                              price: item['price']!,
                              brandName: widget.companyName,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  /// 📞 Contact Tile
  Widget contactTile(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 70.w,
        height: 70.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withOpacity(.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22.sp),
            SizedBox(height: 5.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
