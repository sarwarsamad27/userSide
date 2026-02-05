// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps

class Global {
  static var imageUrl = "http://192.168.100.49:5000";

  static var BaseUrl = "http://192.168.100.49:5000/api/auth";
  // static var BaseUrl = "http://10.0.2.2:5000/api/auth";

  // static var imageUrl = "http://10.0.2.2:5000";

  static var SignUp = "${BaseUrl}/buyer/signup";
  static var Login = "${BaseUrl}/buyer/login";
  static var GoogleLogin = "${BaseUrl}/buyer/google/login";
  static var ForgotPassword = "${BaseUrl}/buyer/forgot-password";
  static var VerifyCode = "${BaseUrl}/buyer/verifycode";
  static var UpdatePassword = "${BaseUrl}/buyer/reset/password";
  static var GetAllProfile = "${BaseUrl}/buyer/company/profiles";
  static var GetAllCategoryProfileWise = "${BaseUrl}/buyer/get/categories";
  static var GetAllProductCategoryWise = "${BaseUrl}/buyer/get/products";
  static var GetSingleProduct = "${BaseUrl}/buyer/get/single/product";
  static var CreateOrder = "${BaseUrl}/buyer/create/order";
  static var AddToFavourite = "${BaseUrl}/buyer/add/to/favourite";
  static var GetFavourite = "${BaseUrl}/buyer/get/favourites";
  static var DeleteFavourite = "${BaseUrl}/buyer/delete";
  static var GetPopularProduct = "${BaseUrl}/buyer/popular/products";
  static var GetPopularCategory = "${BaseUrl}/buyer/popular/category";
  static var GetAllProduct = "${BaseUrl}/buyer/get/all/products";
  static var CreateReview = "${BaseUrl}/buyer/create/reviews";
  static var EditReview = "${BaseUrl}/buyer/edit/review";
  static var DeleteReview = "${BaseUrl}/buyer/delete/review";
  static var RelatedProduct = "${BaseUrl}/buyer/related/product";
  static var OtherProduct = "${BaseUrl}/buyer/other/product";
  static var GetMyOrder = "${BaseUrl}/buyer/my/orders";
  static var CategoryWiseProduct = "${BaseUrl}/buyer/category";
  static var RecommendedProducts = "${BaseUrl}/buyer/recommended/products";
  static var TrackProduct = "${BaseUrl}/buyer/track/product";
  static var ShareLink = "${BaseUrl}/buyer/share/link";
  static var ToggleFollow = "${BaseUrl}/buyer/toggle/follow";
  static var GetFollowStatus = "${BaseUrl}/buyer/follow/status";
  static var getBuyerNotifications = "${BaseUrl}/buyer/get/notifications";
  static var markNotificationRead = "${BaseUrl}/buyer/notifications/mark/read";
  static var getExchangePdf = "${BaseUrl}/buyer/get/exchange"; 
  static var getExchangeRequests = "${BaseUrl}/buyer/get/exchange/requests";
  static var createExchangeRequest = "${BaseUrl}/buyer/create/exchange/request";
  static var ChatMessages = "${BaseUrl}/buyer/chat/messages";
  static var ChatThreads = "${BaseUrl}/buyer/chat/threads";
}
