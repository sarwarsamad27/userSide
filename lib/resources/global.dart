// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps

class Global {
  static var BaseUrl = "http://10.0.2.2:5000/api/auth";
  static var SignUp = "${BaseUrl}/buyer/signup";
  static var Login = "${BaseUrl}/buyer/login";
  static var ForgotPassword = "${BaseUrl}/buyer/forgot-password";
  static var VerifyCode = "${BaseUrl}/buyer/verifycode";
  static var UpdatePassword = "${BaseUrl}/buyer/reset/password";
  static var GetAllProfile = "${BaseUrl}/buyer/company/profiles";
  static var GetAllCategoryProfileWise = "${BaseUrl}/buyer/get/categories";
  static var GetAllProductCategoryWise = "${BaseUrl}/buyer/get/products";
  static var GetSingleProduct = "${BaseUrl}/buyer/get/single/product";
}
