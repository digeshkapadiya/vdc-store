import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vdc_store/app/data/models/csv_product_model.dart';
import 'package:vdc_store/app/shared/utils/app_colors.dart';
import 'package:vdc_store/app/shared/utils/app_fonts.dart';

class CsvProductDetailView extends StatelessWidget {
  const CsvProductDetailView({super.key});

  static const _primaryKeys = {
    'sku',
    'name',
    'price',
    'special_price',
    'base_image',
    'categories',
    'short_description',
    'description',
    'qty',
    'is_in_stock',
    'product_type',
    'attribute_set_code',
    'store_view_code',
    'url_key',
  };

  @override
  Widget build(BuildContext context) {
    final product = Get.arguments as CsvProduct?;
    if (product == null) {
      return const Scaffold(body: Center(child: Text('Product not found')));
    }

    final categories = _splitValues(product.categories);
    final additionalDetails = product.attributes.entries
        .where((entry) => entry.value.trim().isNotEmpty && !_primaryKeys.contains(entry.key))
        .toList();
    final width = MediaQuery.of(context).size.width;
    final contentWidth = width > 980 ? 960.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3EC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 82,
            backgroundColor: const Color(0xFFF6F3EC),
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              onPressed: Get.back,
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.black),
            ),
            title: Text(
              'Product Detail',
              style: TextStyle(
                color: AppColors.black,
                fontFamily: AppFonts.spaceGrotesk,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroCard(product: product, categories: categories),
                      const SizedBox(height: 20),
                      _OverviewSection(product: product, categories: categories),
                      const SizedBox(height: 20),
                      _InfoGrid(product: product),
                      const SizedBox(height: 20),
                      if (additionalDetails.isNotEmpty)
                        _SectionCard(
                          title: 'Additional Catalog Details',
                          subtitle: 'Imported directly from the CSV for this product.',
                          child: Column(
                            children: additionalDetails
                                .map((entry) => _DetailRow(
                                      label: _toTitle(entry.key),
                                      value: _cleanHtml(entry.value),
                                    ))
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final CsvProduct product;
  final List<String> categories;

  const _HeroCard({required this.product, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF111111), Color(0xFF2A2A2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 760;
            return Flex(
              direction: stacked ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: stacked ? 0 : 5,
                  child: Container(
                    height: stacked ? 260 : 340,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F0E7),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: product.imageUrl?.isNotEmpty == true
                          ? CachedNetworkImage(
                              imageUrl: product.imageUrl!,
                              fit: BoxFit.contain,
                              placeholder: (_, __) => const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              errorWidget: (_, __, ___) => _ImageFallback(name: product.name),
                            )
                          : _ImageFallback(name: product.name),
                    ),
                  ),
                ),
                SizedBox(width: stacked ? 0 : 20, height: stacked ? 20 : 0),
                Expanded(
                  flex: stacked ? 0 : 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _Badge(
                            text: product.isInStock ? 'In Stock' : 'Out of Stock',
                            background: product.isInStock
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEE2E2),
                            foreground: product.isInStock
                                ? const Color(0xFF166534)
                                : const Color(0xFF991B1B),
                          ),
                          if (product.productType.isNotEmpty)
                            _Badge(
                              text: _toTitle(product.productType),
                              background: const Color(0xFFECFCCB),
                              foreground: const Color(0xFF3F6212),
                            ),
                          if (product.attributeSetCode.isNotEmpty)
                            _Badge(
                              text: product.attributeSetCode,
                              background: Colors.white.withValues(alpha: 0.12),
                              foreground: Colors.white,
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        product.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          height: 1.1,
                          fontFamily: AppFonts.spaceGrotesk,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'SKU: ${product.sku}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 14,
                          fontFamily: AppFonts.openSans,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${(product.specialPrice ?? product.price).toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontFamily: AppFonts.spaceGrotesk,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (product.specialPrice != null) ...[
                            const SizedBox(width: 12),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 16,
                                  fontFamily: AppFonts.openSans,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _cleanHtml(
                          product.shortDescription.isNotEmpty
                              ? product.shortDescription
                              : product.description,
                        ),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontSize: 15,
                          height: 1.6,
                          fontFamily: AppFonts.openSans,
                        ),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _StatPill(label: 'Quantity', value: '${product.qty}'),
                          if (categories.isNotEmpty)
                            _StatPill(label: 'Categories', value: '${categories.length}'),
                          if (product.urlKey.isNotEmpty)
                            _StatPill(label: 'URL Key', value: product.urlKey),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  final CsvProduct product;
  final List<String> categories;

  const _OverviewSection({required this.product, required this.categories});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Overview',
      subtitle: 'A fuller look at the imported CSV product information.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_cleanHtml(product.shortDescription).isNotEmpty)
            _TextBlock(
              title: 'Short Description',
              body: _cleanHtml(product.shortDescription),
            ),
          if (_cleanHtml(product.description).isNotEmpty) ...[
            if (_cleanHtml(product.shortDescription).isNotEmpty) const SizedBox(height: 18),
            _TextBlock(
              title: 'Description',
              body: _cleanHtml(product.description),
            ),
          ],
          if (categories.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              'Categories',
              style: TextStyle(
                color: AppColors.black,
                fontSize: 16,
                fontFamily: AppFonts.spaceGrotesk,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: categories
                  .map(
                    (category) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F9E8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: const Color(0xFF365314),
                          fontSize: 13,
                          fontFamily: AppFonts.openSans,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final CsvProduct product;

  const _InfoGrid({required this.product});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Product Information',
      subtitle: 'Core data points mapped from the CSV file.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth > 760 ? 2 : 1;
          final items = [
            ('SKU', product.sku),
            ('Store View', product.storeViewCode.isEmpty ? 'Default' : product.storeViewCode),
            ('Attribute Set', product.attributeSetCode.isEmpty ? 'N/A' : product.attributeSetCode),
            ('Product Type', product.productType.isEmpty ? 'N/A' : _toTitle(product.productType)),
            ('Regular Price', '\$${product.price.toStringAsFixed(2)}'),
            (
              'Special Price',
              product.specialPrice != null
                  ? '\$${product.specialPrice!.toStringAsFixed(2)}'
                  : 'Not set',
            ),
            ('Availability', product.isInStock ? 'In stock' : 'Out of stock'),
            ('Quantity', '${product.qty}'),
            ('URL Key', product.urlKey.isEmpty ? 'N/A' : product.urlKey),
          ];

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: columns == 2 ? 2.9 : 3.4,
            ),
            itemBuilder: (_, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F7F3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE9E4D9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.$1,
                      style: TextStyle(
                        color: AppColors.lightGrey,
                        fontSize: 12,
                        fontFamily: AppFonts.openSans,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.$2,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 16,
                        height: 1.3,
                        fontFamily: AppFonts.spaceGrotesk,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.black,
              fontSize: 22,
              fontFamily: AppFonts.spaceGrotesk,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.lightGrey,
              fontSize: 14,
              height: 1.5,
              fontFamily: AppFonts.openSans,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  final String title;
  final String body;

  const _TextBlock({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontFamily: AppFonts.spaceGrotesk,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          body,
          style: TextStyle(
            color: AppColors.lightGrey,
            fontSize: 14,
            height: 1.7,
            fontFamily: AppFonts.openSans,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F7F3),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE9E4D9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.black,
                fontSize: 13,
                fontFamily: AppFonts.openSans,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            SelectableText(
              value,
              style: TextStyle(
                color: AppColors.lightGrey,
                fontSize: 14,
                height: 1.6,
                fontFamily: AppFonts.openSans,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;

  const _Badge({
    required this.text,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontFamily: AppFonts.openSans,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;

  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 110),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.68),
              fontSize: 11,
              fontFamily: AppFonts.openSans,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: AppFonts.spaceGrotesk,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  final String name;

  const _ImageFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF3F0E9), Color(0xFFE8E0D0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 70, color: Color(0xFF7C6F5E)),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF4B4237),
                  fontSize: 16,
                  fontFamily: AppFonts.spaceGrotesk,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<String> _splitValues(String raw) {
  return raw
      .split(',')
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList();
}

String _cleanHtml(String raw) {
  if (raw.isEmpty) return '';

  return raw
      .replaceAll(RegExp(r'<\s*br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n\n')
      .replaceAll(RegExp(r'</li\s*>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<li\s*>', caseSensitive: false), '- ')
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
      .trim();
}

String _toTitle(String value) {
  if (value.isEmpty) return '';

  return value
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
