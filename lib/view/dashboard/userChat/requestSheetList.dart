// exchange_requests_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/utiles.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/resources/toast.dart';
import 'package:user_side/viewModel/provider/exchangeProvider/exchange_provider.dart';

class ExchangeRequestsScreen extends StatefulWidget {
  const ExchangeRequestsScreen({super.key});

  @override
  State<ExchangeRequestsScreen> createState() => _ExchangeRequestsScreenState();
}

class _ExchangeRequestsScreenState extends State<ExchangeRequestsScreen> {
  String? buyerId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // ✅ buyerId fetch karein (LocalStorage ya kisi aur source se)
    buyerId = await LocalStorage.getUserId(); // Ya jo bhi method ho

    if (buyerId != null) {
      context.read<ExchangeProvider>().fetchMyRequests(buyerId!);
    }
  }

  Future<void> _openPdf(String requestId) async {
    if (buyerId == null) {
      AppToast.error("User ID not found");
      return;
    }

    final provider = context.read<ExchangeProvider>();

    final authHeaders = <String, String>{"Accept": "application/pdf"};

    final baseUrl = Global.BaseUrl;

    final file = await provider.downloadPdf(
      requestId: requestId,
      buyerId: buyerId!, // ✅ buyerId pass kar rahe hain
      authHeaders: authHeaders,
      baseUrl: baseUrl,
    );

    if (file == null) {
      AppToast.error("PDF not available / download failed");
      return;
    }

    await OpenFilex.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ExchangeProvider>();
    final items = p.listModel?.requests ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        title: const Text("My Exchange Requests"),
        centerTitle: true,
      ),
      body: p.loading
          ? Utils.loadingLottie()
          : items.isEmpty
          ? Center(
              child: Text(
                p.listModel?.message ?? "No exchange requests",
                style: TextStyle(fontSize: 14.sp, color: Colors.black54),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                if (buyerId != null) {
                  await context.read<ExchangeProvider>().fetchMyRequests(
                    buyerId!,
                  );
                }
              },
              child: ListView.separated(
                padding: EdgeInsets.all(12.w),
                itemCount: items.length,
                separatorBuilder: (_, __) => Divider(height: 1.h),
                itemBuilder: (_, i) {
                  final r = items[i];
                  final status = (r.status ?? "N/A");
                  final canPdf = status == "Accepted";

                  return ListTile(
                    title: Text("Order: ${r.orderId ?? "-"}"),
                    subtitle: Text(
                      "Product: ${r.productId ?? "-"}\n"
                      "Status: $status\n"
                      "Reason: ${r.reason ?? "-"}",
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    isThreeLine: true,
                    trailing: canPdf
                        ? TextButton(
                            onPressed: () => _openPdf(r.id ?? ""),
                            child: const Text("PDF"),
                          )
                        : null,
                  );
                },
              ),
            ),
    );
  }
}
