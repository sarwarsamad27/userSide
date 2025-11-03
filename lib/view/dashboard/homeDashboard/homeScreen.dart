import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/view/dashboard/homeDashboard/categoryScreen.dart';
import 'package:user_side/widgets/customsearchbar.dart';
import 'package:user_side/widgets/productContainer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> categories = [
    {
      "name": "J.",
      "image":
          "https://d1csarkz8obe9u.cloudfront.net/posterpreviews/letter-j-logo-%7C-j-letter-logo-design-template-7d7db1be7bf87982e10790ba69da4579_screen.jpg?ts=1646676358",
    },
    {
      "name": "MTJ",
      "image":
          "https://upload.wikimedia.org/wikipedia/commons/6/64/MTJ_logo.jpg",
    },
    {
      "name": "outfitters",
      "image":
          "https://nishatemporium.com/wp-content/uploads/2019/07/outfitters.png",
    },
    {
      "name": "saya",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTQQDdYu9UCZwW1wjyIqLgIef7k5G0lmvvc-w&s",
    },
    {
      "name": "saeed ghani",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQV2vYdJXY__BPSlFK8WP7qZEXGHin3DI41fA&s",
    },
    {
      "name": "ethnic",
      "image": "https://thegigamall.com/wp-content/uploads/2021/05/Ethnic.png",
    },
    {
      "name": "satrangi",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT_ScPbhiMMbdzJYod_K3iZh2stAttPXjWPCw&s",
    },
    {
      "name": "edenrobe",
      "image":
          "https://nishatemporium.com/wp-content/uploads/2022/03/edenrobe.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            children: [
              /// 👇 yahan tumhara custom search bar show hoga
              CustomSearchBar(
                hintText: "Search brands...",
                onChanged: (value) {},
              ),
              SizedBox(height: 16.h),

              /// 👇 niche grid view scrollable hoga
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: categories.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 260.h,
                    crossAxisSpacing: 14.w,
                    mainAxisSpacing: 5.h,
                  ),
                  itemBuilder: (context, index) {
                    final item = categories[index];
                    return CategoryTile(
                      name: item["name"]!,
                      image: item["image"]!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Categoryscreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
