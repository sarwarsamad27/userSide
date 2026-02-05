import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/resources/appColor.dart';
import 'package:user_side/widgets/customBgContainer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ValueNotifier<bool> _isDarkModeNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _notificationsNotifier = ValueNotifier(true);

  @override
  void dispose() {
    _isDarkModeNotifier.dispose();
    _notificationsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Settings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),

      body: CustomBgContainer(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🌓 Dark Mode Toggle
              ValueListenableBuilder<bool>(
                valueListenable: _isDarkModeNotifier,
                builder: (context, isDarkMode, _) {
                  return SwitchListTile(
                    title: const Text("Dark Mode"),
                    subtitle: const Text("Enable dark theme"),
                    value: isDarkMode,
                    onChanged: (v) => _isDarkModeNotifier.value = v,
                    activeColor: AppColor.primaryColor,
                  );
                },
              ),
              const Divider(),

              /// 🔔 Notifications
              ValueListenableBuilder<bool>(
                valueListenable: _notificationsNotifier,
                builder: (context, notifications, _) {
                  return SwitchListTile(
                    title: const Text("Notifications"),
                    subtitle: const Text("Receive app notifications"),
                    value: notifications,
                    onChanged: (v) => _notificationsNotifier.value = v,
                    activeColor: AppColor.primaryColor,
                  );
                },
              ),
              const Divider(),

              /// 🌐 Language Setting
              ListTile(
                leading: const Icon(Icons.language, color: Colors.blueAccent),
                title: const Text("Language"),
                subtitle: const Text("Select your preferred language"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  showModalBottomSheet(
                    backgroundColor: AppColor.bottomSheetColor,
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20.r),
                      ),
                    ),
                    builder: (_) => Container(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Choose Language",
                            style: TextStyle(
                              color: AppColor.appbackgroundcolor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(color: AppColor.appbackgroundcolor),
                          ListTile(
                            title: const Text(
                              "English",
                              style: TextStyle(
                                color: AppColor.appbackgroundcolor,
                              ),
                            ),
                            onTap: () => Navigator.pop(context),
                          ),

                          ListTile(
                            title: const Text(
                              "Urdu",
                              style: TextStyle(
                                color: AppColor.appbackgroundcolor,
                              ),
                            ),
                            onTap: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const Divider(),

              /// 🔒 Privacy Policy
              ListTile(
                leading: const Icon(Icons.privacy_tip, color: Colors.teal),
                title: const Text("Privacy Policy"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // navigate to privacy screen (if any)
                },
              ),
              const Divider(),

              /// 📄 About App
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.orange),
                title: const Text("About App"),
                subtitle: const Text("Version 1.0.0"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
