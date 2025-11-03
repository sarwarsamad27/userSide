import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/view/dashboard/homeDashboard/productDetail/productDetailScreen.dart';
import 'package:user_side/widgets/productCard.dart';

class Categoryscreen extends StatefulWidget {
  const Categoryscreen({Key? key}) : super(key: key);

  @override
  State<Categoryscreen> createState() => _CategoryscreenState();
}

class _CategoryscreenState extends State<Categoryscreen> {
  final List<Map<String, String>> categories = [
    {
      'name': 'Shoes',
      'image':
          'https://images.unsplash.com/photo-1600180758890-6b94519a8ba6?w=900',
    },
    {
      'name': 'Shirts',
      'image':
          'https://images.unsplash.com/photo-1603252109303-2751441dd157?w=900',
    },
    {
      'name': 'Pants',
      'image':
          'https://images.unsplash.com/photo-1618354691373-d851c5fbc3f8?w=900',
    },
    {
      'name': 'Trousers',
      'image':
          'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=900',
    },
    {
      'name': 'Jackets',
      'image':
          'https://images.unsplash.com/photo-1592878904946-b3cd8b1b0e4f?w=900',
    },
  ];

  final List<Map<String, String>> products = const [
    {
      'name': 'Running Shoes',
      'price': '₹3,499',
      'image':
          'https://thumbs.dreamstime.com/b/beautiful-rain-forest-ang-ka-nature-trail-doi-inthanon-national-park-thailand-36703721.jpg',
    },
    {
      'name': 'Casual Sneakers',
      'price': '₹2,199',
      'image':
          'https://cdn.pixabay.com/photo/2025/04/28/19/59/female-model-9565629_640.jpg',
    },
    {
      'name': 'Formal Shoes',
      'price': '₹4,999',
      'image':
          'https://bkacontent.com/wp-content/uploads/2016/06/Depositphotos_31146757_l-2015.jpg',
    },
    {
      'name': 'Formal Shoes',
      'price': '₹4,999',
      'image':
          'https://bkacontent.com/wp-content/uploads/2016/06/Depositphotos_31146757_l-2015.jpg',
    },
    {
      'name': 'Formal Shoes',
      'price': '₹4,999',
      'image':
          'https://bkacontent.com/wp-content/uploads/2016/06/Depositphotos_31146757_l-2015.jpg',
    },
    {
      'name': 'Formal Shoes',
      'price': '₹4,999',
      'image':
          'https://bkacontent.com/wp-content/uploads/2016/06/Depositphotos_31146757_l-2015.jpg',
    },
  ];

  int selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final halfHeight = media.height * 0.5;

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: halfHeight,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  categories[selectedCategoryIndex]['image']!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported, size: 48),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                Positioned(
                  left: 16.w,
                  right: 16.w,
                  bottom: 80.h,
                  child: Text(
                    categories[selectedCategoryIndex]['name']!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10.h,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 30.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final isSelected = index == selectedCategoryIndex;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategoryIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: EdgeInsets.symmetric(horizontal: 8.w),
                            padding: EdgeInsets.symmetric(horizontal: 15.w),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            child: Center(
                              child: Text(
                                categories[index]['name']!,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.white.withOpacity(0.8),
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: GridView.builder(
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: media.width < 600 ? 2 : 4,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: media.width < 600 ? 0.72 : 0.8,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return InkWell(
                    onTap: () {},
                    child: ProductCard(
                      name: product['name']!,
                      price: product['price']!,
                      imageUrl: product['image']!,

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(
                              imageUrls: [
                                product['image']!,

                                product['image']!,
                                product['image']!,
                                product['image']!,
                                product['image']!,
                              ],
                              name: product['name']!,
                              description:
                                  'High-quality ${product['name']} perfect for everyday wear. Comfortable, stylish, and durable.',
                              color: 'Black',
                              size: '42',
                              price: product['price']!,
                              brandName: 'Nike Official',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
