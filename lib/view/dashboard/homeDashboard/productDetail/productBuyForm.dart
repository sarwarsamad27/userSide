import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/resources/global.dart';
import 'package:user_side/resources/utiles.dart';
import 'package:user_side/resources/premium_toast.dart';
import 'package:user_side/view/auth/AuthLoginGate.dart';
import 'package:user_side/viewModel/provider/favouriteProvider/getFavourite_provider.dart';
import 'package:user_side/viewModel/provider/orderProvider/createOrder_provider.dart';
import 'package:user_side/viewModel/provider/walletProvider/walletProvider.dart';
import 'package:user_side/viewModel/provider/deliveryProvider/delivery_settings_provider.dart';
import 'package:user_side/resources/authSession.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/widgets/customBgContainer.dart';
import 'package:user_side/widgets/customButton.dart';
import 'package:user_side/widgets/customContainer.dart';
import 'package:user_side/widgets/customTextFeld.dart';

/// Payment method enum
enum PaymentMethod { cod, wallet }

class ProductBuyForm extends StatefulWidget {
  final String? imageUrl;
  final String? name;
  final String? price;
  final List<String>? colors;
  final List<String>? sizes;
  final List<String> productId;
  final List<dynamic>? favouriteItems;
  final int? initialStock;

  const ProductBuyForm({
    super.key,
    this.imageUrl,
    this.name,
    this.price,
    this.colors,
    this.sizes,
    this.favouriteItems,
    required this.productId,
    this.initialStock,
  });

  @override
  State<ProductBuyForm> createState() => _ProductBuyFormState();
}

class _ProductBuyFormState extends State<ProductBuyForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _additionalNoteController =
      TextEditingController();
  final TextEditingController _walletPhoneController = TextEditingController();
  final TextEditingController _jazzcashPhoneController =
      TextEditingController();

  final ValueNotifier<bool> _loadingNotifier = ValueNotifier(false);
  final ValueNotifier<int> _quantityNotifier = ValueNotifier(1);

  PaymentMethod _selectedPayment = PaymentMethod.cod;

  @override
  void initState() {
    super.initState();
    _loadPersistedData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final buyerId = context.read<AuthSession>().userId;
      if (buyerId != null) {
        context.read<WalletProvider>().fetchBalance(buyerId);
      }
      context.read<DeliverySettingsProvider>().fetchSettings();
    });
  }

  Future<void> _loadPersistedData() async {
    _emailController.text = AuthSession.instance.userEmail ?? '';
    _nameController.text = await LocalStorage.getUserName() ?? '';
    _phoneController.text = await LocalStorage.getUserPhone() ?? '';
    _addressController.text = await LocalStorage.getUserAddress() ?? '';
    _cityController.text = await LocalStorage.getUserCity() ?? '';
    _cityController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _saveFormData() async {
    await LocalStorage.saveUserName(_nameController.text.trim());
    await LocalStorage.saveUserPhone(_phoneController.text.trim());
    await LocalStorage.saveUserAddress(_addressController.text.trim());
    await LocalStorage.saveUserCity(_cityController.text.trim());
  }

  @override
  void dispose() {
    _loadingNotifier.dispose();
    _quantityNotifier.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _additionalNoteController.dispose();
    _walletPhoneController.dispose();
    _jazzcashPhoneController.dispose();
    super.dispose();
  }

  // ── Build product list ────────────────────────────────────────────────────
  List<Map<String, dynamic>> _buildProductList() {
    if (widget.favouriteItems != null && widget.favouriteItems!.isNotEmpty) {
      return widget.favouriteItems!
          .map(
            (item) => {
              'productId': item['productId'] ?? '',
              'quantity': item['quantity'] ?? 1,
              'selectedColor': item['colors'] ?? [],
              'selectedSize': item['sizes'] ?? [],
            },
          )
          .toList();
    }
    return [
      {
        'productId': widget.productId,
        'quantity': _quantityNotifier.value,
        'selectedColor': widget.colors ?? [],
        'selectedSize': widget.sizes ?? [],
      },
    ];
  }

  double _getProductsTotal() {
    final isFromFavourite =
        widget.favouriteItems != null && widget.favouriteItems!.isNotEmpty;
    return isFromFavourite
        ? _calculateFavouriteTotal()
        : (double.tryParse(widget.price ?? '0') ?? 0) * _quantityNotifier.value;
  }

  DeliverySettingsProvider get _delivery =>
      context.read<DeliverySettingsProvider>();

  // ── Grand total ───────────────────────────────────────────────────────────
  double _getCurrentShipping() {
    final productTotal = _getProductsTotal();
    final deliveryCfg = _delivery;

    // Check if free delivery applies
    if (deliveryCfg.freeDeliveryEnabled &&
        productTotal >= deliveryCfg.freeDeliveryThreshold) {
      return 0;
    }

    final city = _cityController.text.trim().toLowerCase();
    if (city.isEmpty) return 200;

    // Most sellers likely Karachi (Self/Local)
    // In a real app, we'd compare with specific seller cities if available
    // For now, Karachi is same city (200), Others (300)
    if (city == 'karachi') return 200;

    return 300;
  }

  double _getGrandTotal() {
    final productTotal = _getProductsTotal();
    return productTotal + _getCurrentShipping();
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  MAIN: Place order button tapped
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> _onPlaceOrderTapped() async {
    // Validate form fields first
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty) {
      PremiumToast.error(context, 'Please fill in all required fields');
      return;
    }

    // ── Stock Check ───────────────────────────────────────────────────────────
    _loadingNotifier.value = true;
    final bool isStockAvailable = await _checkStockBeforeOrder();
    _loadingNotifier.value = false;

    if (!isStockAvailable) return;

    switch (_selectedPayment) {
      case PaymentMethod.cod:
        await _placeOrderCod();
        break;
      case PaymentMethod.wallet:
        await _startWalletOtpFlow();
        break;
    }
  }

  Future<bool> _checkStockBeforeOrder() async {
    try {
      final isFromFavourite =
          widget.favouriteItems != null && widget.favouriteItems!.isNotEmpty;

      if (!isFromFavourite) {
        final currentQty = _quantityNotifier.value;
        final available = widget.initialStock ?? 999;

        if (available <= 0) {
          _showOutOfStockDialog();
          return false;
        }

        if (currentQty > available) {
          _showLowStockDialog(available);
          return false;
        }
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  void _showOutOfStockDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Out of Stock',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        content: Text(
          'We apologize, but this item is currently unavailable. Why not explore our other premium products while you wait?',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Gallery'),
          ),
        ],
      ),
    );
  }

  void _showLowStockDialog(int available) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Low Stock Alert',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        content: Text(
          'Only $available items are left in stock. Would you like to adjust your quantity and proceed?',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Adjust Quantity'),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // COD: Place order directly
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> _placeOrderCod() async {
    _loadingNotifier.value = true;
    final provider = context.read<CreateOrderProvider>();

    final productTotal = _getProductsTotal();
    await provider.placeOrder(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      buyerCity: _cityController.text.trim(),
      additionalNote: _additionalNoteController.text.trim(),
      products: _buildProductList(),
      shipmentCharges: _delivery.getShipmentCharges(productTotal).toInt(),
      paymentMethod: 'cod',
    );

    _loadingNotifier.value = false;
    _handleOrderResult(provider);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // WALLET: Show phone sheet → OTP sheet → place order
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> _startWalletOtpFlow() async {
    final grandTotal = _getGrandTotal();
    final provider = context.read<CreateOrderProvider>();

    // ── Check wallet balance first ────────────────────────────────────────────
    final walletProvider = context.read<WalletProvider>();
    final buyerId = context.read<AuthSession>().userId ?? '';
    await walletProvider.fetchBalance(buyerId);

    if (walletProvider.balance < grandTotal) {
      if (!mounted) return;
      PremiumToast.error(
        context,
        'Insufficient wallet balance. You need Rs ${grandTotal.toStringAsFixed(0)}, '
        'but your balance is Rs ${walletProvider.balance.toStringAsFixed(0)}.',
      );
      return;
    }

    // ── Step 1: Ask phone number and send OTP ─────────────────────────────────
    _walletPhoneController.text = _phoneController.text.trim();
    final phoneSent = await _showWalletPhoneSheet(grandTotal, provider);
    if (!phoneSent) return;

    // ── Step 2: OTP entry sheet ───────────────────────────────────────────────
    final otpVerified = await _showWalletOtpSheet(provider);
    if (!otpVerified) return;

    // ── Step 3: Place order (wallet debit already done) ───────────────────────
    _loadingNotifier.value = true;
    final productTotalW = _getProductsTotal();
    await provider.placeOrder(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      buyerCity: _cityController.text.trim(),
      additionalNote: _additionalNoteController.text.trim(),
      products: _buildProductList(),
      shipmentCharges: _delivery.getShipmentCharges(productTotalW).toInt(),
      paymentMethod: 'wallet',
    );
    _loadingNotifier.value = false;
    _handleOrderResult(provider);
  }

  // ── Wallet: Phone number bottom sheet ────────────────────────────────────
  Future<bool> _showWalletPhoneSheet(
    double amount,
    CreateOrderProvider provider,
  ) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WalletPhoneSheet(
        amount: amount,
        controller: _walletPhoneController,
        provider: provider,
        onOtpSent: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );
    return result ?? false;
  }

  // ── Wallet: OTP entry bottom sheet ───────────────────────────────────────
  Future<bool> _showWalletOtpSheet(CreateOrderProvider provider) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WalletOtpSheet(
        provider: provider,
        onVerified: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );
    return result ?? false;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Handle order result
  // ──────────────────────────────────────────────────────────────────────────
  void _handleOrderResult(CreateOrderProvider provider) {
    final data = provider.orderData;
    if (data != null &&
        (data.order != null ||
            (data.orders != null && data.orders!.isNotEmpty))) {
      _saveFormData(); // Save form data for next time

      // SHOW LOTTIE FIRST
      if (mounted) Utils.showOrderSuccessLottie(context);

      // CLEAR ONLY ORDERED ITEMS FROM FAVOURITES
      final List<String> orderedProductIds = [];
      if (data.order != null && data.order!.products != null) {
        for (var p in data.order!.products!) {
          if (p.productId != null) orderedProductIds.add(p.productId!);
        }
      } else if (data.orders != null) {
        for (var o in data.orders!) {
          if (o.products != null) {
            for (var p in o.products!) {
              if (p.productId != null) orderedProductIds.add(p.productId!);
            }
          }
        }
      }

      // If for some reason the response is empty but we have product IDs from widget
      if (orderedProductIds.isEmpty) {
        orderedProductIds.addAll(widget.productId);
      }

      context.read<FavouriteProvider>().deleteOrderedFavourites(
        orderedProductIds,
      );
    } else {
      if (mounted) {
        PremiumToast.error(
          context,
          provider.errorMessage ?? 'Failed to place order',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGate(child: _buildScaffold(context));
  }

  Widget _buildScaffold(BuildContext context) {
    final isFromFavourite =
        widget.favouriteItems != null && widget.favouriteItems!.isNotEmpty;
    final singlePrice = double.tryParse(widget.price ?? '0') ?? 0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: AppColor.appimagecolor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(
                'Confirm Order',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                child: CustomButton(
                  text: 'Place Order',
                  onTap: _onPlaceOrderTapped,
                ),
              ),
            ),
            body: CustomBgContainer(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 20.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Product info ─────────────────────────────────────────
                      if (isFromFavourite)
                        SizedBox(
                          height: 110.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.favouriteItems!.length,
                            itemBuilder: (context, index) {
                              final item = widget.favouriteItems![index];
                              return Container(
                                margin: EdgeInsets.only(right: 10.w),
                                padding: EdgeInsets.all(8.w),
                                width: 180.w,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: Image.network(
                                        Global.getImageUrl(item['imageUrl']),
                                        height: 60.h,
                                        width: 60.w,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13.sp,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'Rs: ${item["price"]}',
                                            style: TextStyle(fontSize: 12.sp),
                                          ),
                                          if (item['colors'] != null &&
                                              item['colors'].isNotEmpty)
                                            Text(
                                              'Colors: ${item["colors"].join(", ")}',
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          if (item['sizes'] != null &&
                                              item['sizes'].isNotEmpty)
                                            Text(
                                              'Sizes: ${item["sizes"].join(", ")}',
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          Text(
                                            'Qty: ${item["quantity"]}',
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: Image.network(
                                widget.imageUrl!,
                                height: 60.h,
                                width: 60.w,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.name ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  Text(
                                    widget.price ?? '',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  if (widget.colors != null &&
                                      widget.colors!.isNotEmpty)
                                    Text(
                                      'Colors: ${widget.colors!.join(", ")}',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  if (widget.sizes != null &&
                                      widget.sizes!.isNotEmpty)
                                    Text(
                                      'Sizes: ${widget.sizes!.join(", ")}',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),

                      SizedBox(height: 16.h),

                      // ── Quantity ─────────────────────────────────────────────
                      if (!isFromFavourite)
                        ValueListenableBuilder<int>(
                          valueListenable: _quantityNotifier,
                          builder: (_, quantity, __) => Row(
                            children: [
                              _qtyBtn(Icons.remove, () {
                                if (quantity > 1) _quantityNotifier.value--;
                              }),
                              SizedBox(width: 20.w),
                              Text(
                                '$quantity',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 20.w),
                              _qtyBtn(
                                Icons.add,
                                () => _quantityNotifier.value++,
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: 16.h),

                      // ══════════════════════════════════════════════════════
                      //  PAYMENT METHOD SELECTOR
                      // ══════════════════════════════════════════════════════
                      Consumer<WalletProvider>(
                        builder: (_, walletProvider, __) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment Method',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: _PaymentOptionCard(
                                      icon: Icons.delivery_dining_rounded,
                                      label: 'Cash on\nDelivery',
                                      color: const Color(0xFF4CAF50),
                                      selected:
                                          _selectedPayment == PaymentMethod.cod,
                                      onTap: () => setState(
                                        () => _selectedPayment =
                                            PaymentMethod.cod,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: _PaymentOptionCard(
                                      icon:
                                          Icons.account_balance_wallet_rounded,
                                      label:
                                          'Wallet\n(Rs ${walletProvider.balance.toStringAsFixed(0)})',
                                      color: const Color(0xFF2979FF),
                                      selected:
                                          _selectedPayment ==
                                          PaymentMethod.wallet,
                                      onTap: () => setState(
                                        () => _selectedPayment =
                                            PaymentMethod.wallet,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Show wallet balance warning
                              if (_selectedPayment == PaymentMethod.wallet &&
                                  walletProvider.balance < _getGrandTotal())
                                Padding(
                                  padding: EdgeInsets.only(top: 8.h),
                                  child: Text(
                                    '⚠️ Insufficient balance. Please add Rs '
                                    '${(_getGrandTotal() - walletProvider.balance).toStringAsFixed(0)} more.',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.red.shade600,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),

                      SizedBox(height: 24.h),

                      // ── Form fields ─────────────────────────────────────────
                      CustomAppContainer(
                        width: double.infinity,
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: _nameController,
                              hintText: 'Enter your name',
                              headerText: 'Full Name',
                              validator: (val) {
                                if (val == null || val.isEmpty)
                                  return "Name is required";
                                return null;
                              },
                            ),
                            SizedBox(height: 20.h),
                            CustomTextField(
                              controller: _emailController,
                              hintText: 'Enter your email',
                              headerText: 'Email Address',
                              validator: (val) {
                                if (val == null || val.isEmpty)
                                  return "Email is required";
                                final reg = RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                );
                                if (!reg.hasMatch(val))
                                  return "Invalid email format";
                                return null;
                              },
                            ),
                            SizedBox(height: 20.h),
                            CustomTextField(
                              controller: _phoneController,
                              hintText: 'Enter your phone (03XXXXXXXXX)',
                              headerText: 'Phone Number',
                              keyboardType: TextInputType.phone,
                              validator: (val) {
                                if (val == null || val.isEmpty)
                                  return "Phone is required";
                                final reg = RegExp(r'^03[0-9]{9}$');
                                if (!reg.hasMatch(val))
                                  return "Invalid phone (11 digits, starts with 03)";
                                return null;
                              },
                            ),
                            SizedBox(height: 20.h),
                            CustomTextField(
                              controller: _addressController,
                              hintText: 'Enter your address',
                              headerText: 'Address',
                              validator: (val) {
                                if (val == null || val.isEmpty)
                                  return "Address is required";
                                return null;
                              },
                            ),
                            SizedBox(height: 20.h),
                            CustomTextField(
                              controller: _cityController,
                              hintText: 'Enter your city (e.g. Karachi)',
                              headerText: 'City',
                              validator: (val) {
                                if (val == null || val.trim().isEmpty)
                                  return "City is required";
                                return null;
                              },
                            ),
                            SizedBox(height: 20.h),
                            CustomTextField(
                              controller: _additionalNoteController,
                              hintText: 'Write additional notes',
                              headerText: 'Order Notes (optional)',
                              height: 120.h,
                            ),
                            SizedBox(height: 20.h),

                            // ── Price summary ───────────────────────────
                            ValueListenableBuilder<int>(
                              valueListenable: _quantityNotifier,
                              builder: (_, quantity, __) {
                                final productTotal = isFromFavourite
                                    ? _calculateFavouriteTotal()
                                    : singlePrice * quantity;
                                final shipment = _getCurrentShipping();
                                final grandTotal = productTotal + shipment;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Price: Rs ${productTotal.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'Shipment Charges: Rs ${shipment.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'Grand Total: Rs ${grandTotal.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _paymentColor().withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                          20.r,
                                        ),
                                      ),
                                      child: Text(
                                        _paymentLabel(),
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: _paymentColor(),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Loading overlay
          ValueListenableBuilder<bool>(
            valueListenable: _loadingNotifier,
            builder: (_, loading, __) {
              if (!loading) return const SizedBox.shrink();
              return Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: SpinKitThreeBounce(
                    color: AppColor.primaryColor,
                    size: 40,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 35.h,
        width: 35.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColor.primaryColor),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  String _paymentLabel() {
    switch (_selectedPayment) {
      case PaymentMethod.cod:
        return '💵 Cash on Delivery';
      case PaymentMethod.wallet:
        return '💳 Pay from Wallet';
    }
  }

  Color _paymentColor() {
    switch (_selectedPayment) {
      case PaymentMethod.cod:
        return const Color(0xFF4CAF50);
      case PaymentMethod.wallet:
        return const Color(0xFF2979FF);
    }
  }

  double _calculateFavouriteTotal() {
    double total = 0;
    if (widget.favouriteItems != null) {
      for (var item in widget.favouriteItems!) {
        final price = double.tryParse(item['price'].toString()) ?? 0;
        final qty = int.tryParse(item['quantity'].toString()) ?? 1;
        total += price * qty;
      }
    }
    return total;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Payment Option Card Widget
// ─────────────────────────────────────────────────────────────────────────────
class _PaymentOptionCard extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOptionCard({
    this.icon,
    this.imagePath,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? color : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: Image.asset(
                  imagePath!,
                  width: 24.w,
                  height: 24.h,
                  fit: BoxFit.cover,
                ),
              )
            else
              Icon(icon, color: selected ? color : Colors.grey, size: 22.r),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? color : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Wallet Phone Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _WalletPhoneSheet extends StatelessWidget {
  final double amount;
  final TextEditingController controller;
  final CreateOrderProvider provider;
  final VoidCallback onOtpSent;
  final VoidCallback onCancel;

  const _WalletPhoneSheet({
    required this.amount,
    required this.controller,
    required this.provider,
    required this.onOtpSent,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24.w,
        20.h,
        24.w,
        MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Wallet Payment',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6.h),
          Text(
            'Rs ${amount.toStringAsFixed(0)} will be deducted from your wallet.',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
          ),
          SizedBox(height: 20.h),
          TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '03XXXXXXXXX',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Consumer<CreateOrderProvider>(
            builder: (_, prov, __) => SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Send OTP',
                onTap: prov.walletOtpLoading
                    ? null
                    : () async {
                        final phone = controller.text.trim();
                        if (phone.isEmpty ||
                            !RegExp(r'^03[0-9]{9}$').hasMatch(phone)) {
                          PremiumToast.error(
                            context,
                            'Enter valid phone number',
                          );
                          return;
                        }
                        final ok = await prov.sendWalletOtp(
                          amount: amount,
                          phoneNumber: phone,
                        );
                        if (ok) onOtpSent();
                      },
              ),
            ),
          ),
          TextButton(
            onPressed: onCancel,
            child: const Center(
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Wallet OTP Sheet — enter OTP to verify
// ─────────────────────────────────────────────────────────────────────────────
class _WalletOtpSheet extends StatefulWidget {
  final CreateOrderProvider provider;
  final VoidCallback onVerified;
  final VoidCallback onCancel;

  const _WalletOtpSheet({
    required this.provider,
    required this.onVerified,
    required this.onCancel,
  });

  @override
  State<_WalletOtpSheet> createState() => _WalletOtpSheetState();
}

class _WalletOtpSheetState extends State<_WalletOtpSheet> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24.w,
        20.h,
        24.w,
        MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Enter OTP',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6.h),
          Text(
            'Enter the 6-digit OTP sent to your number.',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
          ),
          SizedBox(height: 20.h),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              counterText: '',
              hintText: '------',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Consumer<CreateOrderProvider>(
            builder: (_, provider, __) => SizedBox(
              width: double.infinity,
              height: 50.h,
              child: CustomButton(
                text: 'Verify & Pay',
                onTap: provider.walletVerifyLoading
                    ? null
                    : () async {
                        final otp = _otpController.text.trim();
                        if (otp.length != 6) {
                          PremiumToast.error(context, 'Enter 6-digit OTP');
                          return;
                        }
                        final verified = await provider.verifyWalletOtp(
                          otp: otp,
                        );
                        if (verified) {
                          widget.onVerified();
                        } else if (provider.errorMessage != null) {
                          PremiumToast.error(context, provider.errorMessage!);
                        }
                      },
              ),
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: widget.onCancel,
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
