import 'package:get/get.dart';
import 'package:vdc_store/app/modules/csv_product_detail/csv_product_detail_view.dart';
import 'package:vdc_store/app/modules/home/home_controller.dart';
import 'package:vdc_store/app/modules/home/home_view.dart';
import 'package:vdc_store/app/modules/product_detail/product_detail_controller.dart';
import 'package:vdc_store/app/modules/product_detail/product_detail_view.dart';
import 'package:vdc_store/app/modules/csv_products/csv_products_controller.dart';
import 'package:vdc_store/app/modules/csv_products/csv_products_view.dart';
import 'package:vdc_store/app/modules/splash/splash_view.dart';
import 'package:vdc_store/app/modules/subscription/subscription_controller.dart';
import 'package:vdc_store/app/modules/subscription/subscription_view.dart';

class AppRoutes {
  static const spalsh = "/";
  static const subscription = "/subscription";
  static const home = "/home";
  static const productDetail = "/product-detail";
  static const csvProducts = "/csv-products";
  static const csvProductDetail = "/csv-product-detail";

  static List<GetPage> routes = [
    GetPage(name: spalsh, page: () => SplashView()),
    GetPage(
      name: subscription,
      page: () => SubscriptionView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SubscriptionController>(() => SubscriptionController());
      }),
    ),
    GetPage(
      name: home,
      page: () => HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),

    GetPage(
      name: csvProducts,
      page: () => const CsvProductsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CsvProductsController>(() => CsvProductsController());
      }),
    ),
    GetPage(name: csvProductDetail, page: () => const CsvProductDetailView()),
    GetPage(
      name: productDetail,
      page: () => ProductDetailView(),
      binding: BindingsBuilder<ProductDetailView>(() {
        Get.lazyPut<ProductDetailController>(() => ProductDetailController());
      }),
    ),
  ];
}
