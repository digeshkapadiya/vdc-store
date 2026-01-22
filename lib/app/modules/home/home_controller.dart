// lib/app/modules/home/home_controller.dart
import 'package:get/get.dart';
import 'package:vdc_store/app/data/models/product_model.dart';
import 'package:vdc_store/app/data/providers/graphql_provider.dart';

class HomeController extends GetxController {
  final products = <Product>[].obs;
  final isLoading = false.obs;
  final searchText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  void fetchProducts({String search = "Magento 2 LLMs TXT Generator"}) async {
    try {
      isLoading.value = true;
      final result = await GraphqlProvider.getProducts(
        search: search,
        pageSize: 1,
      );
      products.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load products: $e');
    } finally {
      isLoading.value = false;
    }
  }

}
