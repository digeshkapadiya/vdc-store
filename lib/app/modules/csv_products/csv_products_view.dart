import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vdc_store/app/data/models/csv_product_model.dart';
import 'package:vdc_store/app/modules/csv_product_detail/csv_product_detail_view.dart';
import 'package:vdc_store/app/shared/utils/app_fonts.dart';
import 'csv_products_controller.dart';

class CsvProductsView extends GetView<CsvProductsController> {
  const CsvProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3EC),
      appBar: AppBar(
        title: Text(
          'CSV Product Catalog',
          style: TextStyle(
            color: const Color(0xFF111111),
            fontFamily: AppFonts.spaceGrotesk,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFFF6F3EC),
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF111111),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.products.isEmpty) {
          return const Center(child: Text('No products found'));
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 18),
          itemCount: controller.products.length,
          itemBuilder: (_, i) => _ProductCard(product: controller.products[i]),
        );
      }),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final CsvProduct product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        elevation: 1.5,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Get.to(() => const CsvProductDetailView(), arguments: product),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 94,
                  height: 94,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F0E7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: product.imageUrl?.isNotEmpty == true
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrl!,
                            fit: BoxFit.contain,
                            placeholder: (_, __) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.shopping_bag_outlined,
                              size: 40,
                              color: Color(0xFF756A59),
                            ),
                          )
                        : const Icon(
                            Icons.shopping_bag_outlined,
                            size: 40,
                            color: Color(0xFF756A59),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                height: 1.2,
                                fontFamily: AppFonts.spaceGrotesk,
                                color: const Color(0xFF111111),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.arrow_outward_rounded,
                            size: 20,
                            color: Color(0xFF111111),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'SKU: ${product.sku}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                          fontFamily: AppFonts.openSans,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _previewText(product.shortDescription),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          height: 1.5,
                          fontFamily: AppFonts.openSans,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (product.specialPrice != null) ...[
                            Text(
                              '\$${product.specialPrice!.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: const Color(0xFF166534),
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                fontFamily: AppFonts.spaceGrotesk,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                decoration: TextDecoration.lineThrough,
                                fontSize: 13,
                                fontFamily: AppFonts.openSans,
                              ),
                            ),
                          ] else
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: const Color(0xFF166534),
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                fontFamily: AppFonts.spaceGrotesk,
                              ),
                            ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: product.isInStock
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              product.isInStock ? 'In Stock (${product.qty})' : 'Out of Stock',
                              style: TextStyle(
                                color: product.isInStock
                                    ? const Color(0xFF166534)
                                    : const Color(0xFF991B1B),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                fontFamily: AppFonts.openSans,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _previewText(String raw) {
  return raw
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
