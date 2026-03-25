import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vdc_store/app/data/models/csv_product_model.dart';

class CsvProductsController extends GetxController {
  final products = <CsvProduct>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCsv();
  }

  Future<void> _loadCsv() async {
    try {
      final raw = await rootBundle.loadString('assets/csdf.csv');
      var rows = const CsvToListConverter(
        shouldParseNumbers: false,
        eol: '\n',
      ).convert(raw);
      if (rows.length < 2 && raw.contains('\r\n')) {
        rows = const CsvToListConverter(
          shouldParseNumbers: false,
          eol: '\r\n',
        ).convert(raw);
      }
      if (rows.length < 2) return;

      final headers = rows.first.map((value) => value.toString().trim()).toList();
      products.value = rows
          .skip(1)
          .map(
            (row) => CsvProduct.fromRow(
              headers,
              row.map((value) => value.toString()).toList(),
            ),
          )
          .where((p) => p.sku.isNotEmpty)
          .toList();
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => Get.snackbar('Error', 'Failed to load CSV: $e'),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
