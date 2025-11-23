import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:user_side/view/dashboard/homeDashboard/categoryAndProduct/categoryScreen.dart';
import 'package:user_side/viewModel/provider/getAllProfileAndProductProvider/getAllProfile_provider.dart';
import 'package:user_side/widgets/customsearchbar.dart';
import 'package:user_side/widgets/productContainer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    final provider =
        Provider.of<GetAllProfileProvider>(context, listen: false);

    provider.fetchProfiles();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetAllProfileProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            children: [
              CustomSearchBar(
                hintText: "Search brands...",
                onChanged: (value) {},
              ),

              SizedBox(height: 16.h),

              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())

                    : provider.productData == null ||
                            provider.productData!.profiles == null ||
                            provider.productData!.profiles!.isEmpty
                        ? const Center(
                            child: Text("No Profiles Found"),
                          )

                        : GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount:
                                provider.productData!.profiles!.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisExtent: 260.h,
                              crossAxisSpacing: 14.w,
                              mainAxisSpacing: 5.h,
                            ),
                            itemBuilder: (context, index) {
                              final item = provider
                                  .productData!.profiles![index];

                              return CategoryTile(
                                name: item.name ?? "",
                                image: item.image ?? "",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                           Categoryscreen( profileId: item.sId!,),
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
