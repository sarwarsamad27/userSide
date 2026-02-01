class Validators {
  static String? required(String? v, {String fieldName = "This field"}) {
    if (v == null || v.trim().isEmpty) return "$fieldName is required";
    return null;
  }

    static String? email(String? v) {
      if (v == null || v.trim().isEmpty) return "Email is required";
      final value = v.trim();
      final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
      if (!emailRegex.hasMatch(value)) return "Enter a valid email address";
      return null;
    }

  static String? minLen(String? v, int len, {String label = "Value"}) {
    if (v == null || v.trim().isEmpty) return "$label is required";
    if (v.trim().length < len) return "$label must be at least $len characters";
    return null;
  }

  static String? phonePK(String? v) {
    if (v == null || v.trim().isEmpty) return "Phone number is required";
    final value = v.trim();
    // Accept: 03xxxxxxxxx or +92xxxxxxxxxx
    final r = RegExp(r'^(03\d{9}|\+92\d{10})$');
    if (!r.hasMatch(value)) return "Enter a valid phone number";
    return null;
  }
}
