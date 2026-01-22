import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vdc_store/app/data/models/product_model.dart';
import 'package:vdc_store/app/data/providers/graphql_provider.dart';

class ProductDetailController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final selectedImageIndex = 0.obs;
  final productDetail = Rxn<Product>();
  final isLoading = true.obs;
  final ScrollController scrollController = ScrollController();
  final isDescriptionExpanded = false.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 7, vsync: this);
    final Product product = Get.arguments as Product;
    loadProductDetail(product.sku);
  }

  Future<void> loadProductDetail(String sku) async {
    try {
      isLoading.value = true;
      final detail = await GraphqlProvider.getProductDetail(sku);
      productDetail.value = detail;
    } on TimeoutException {
      Get.snackbar('Timeout', 'Request timed out. Please try again.');
    } on FormatException {
      Get.snackbar(
        'Error',
        'Invalid response from server. Please try again later.',
      );
    } catch (e) {
      print('Failed to load product details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProduct() async {
    final product = productDetail.value;
    if (product != null) {
      await loadProductDetail(product.sku);
    }
  }

  void selectImage(int index) {
    selectedImageIndex.value = index;
  }

  void scrollUp() {
    scrollController.animateTo(
      scrollController.offset - 100,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void scrollDown() {
    scrollController.animateTo(
      scrollController.offset + 100,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void toggleDescription() => isDescriptionExpanded.toggle();

  @override
  void onClose() {
    scrollController.dispose();
    tabController.dispose();
    super.onClose();
  }
}
