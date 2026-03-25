class CsvProduct {
  final String sku;
  final String name;
  final double price;
  final double? specialPrice;
  final String? imageUrl;
  final String storeViewCode;
  final String attributeSetCode;
  final String productType;
  final String description;
  final String categories;
  final String shortDescription;
  final String urlKey;
  final int qty;
  final bool isInStock;
  final Map<String, String> attributes;

  CsvProduct({
    required this.sku,
    required this.name,
    required this.price,
    this.specialPrice,
    this.imageUrl,
    required this.storeViewCode,
    required this.attributeSetCode,
    required this.productType,
    required this.description,
    required this.categories,
    required this.shortDescription,
    required this.urlKey,
    required this.qty,
    required this.isInStock,
    required this.attributes,
  });

  factory CsvProduct.fromRow(List<String> headers, List<String> values) {
    final attributes = <String, String>{};
    for (int i = 0; i < headers.length; i++) {
      final key = headers[i].trim();
      final value = i < values.length ? values[i].trim() : '';
      attributes[key] = value;
    }

    String get(String key) {
      return attributes[key] ?? '';
    }

    double? parseDouble(String value) {
      if (value.isEmpty) return null;
      return double.tryParse(value.replaceAll(',', ''));
    }

    final imagePath = get('base_image');
    final imageUrl = imagePath.isNotEmpty
        ? 'https://magento.test/pub/media/catalog/product$imagePath'
        : null;
    final specialPrice = parseDouble(get('special_price'));
    final inStockValue = get('is_in_stock').toLowerCase();

    return CsvProduct(
      sku: get('sku'),
      name: get('name'),
      price: parseDouble(get('price')) ?? 0.0,
      specialPrice: specialPrice,
      imageUrl: imageUrl,
      storeViewCode: get('store_view_code'),
      attributeSetCode: get('attribute_set_code'),
      productType: get('product_type'),
      description: get('description'),
      categories: get('categories'),
      shortDescription: get('short_description'),
      urlKey: get('url_key'),
      qty: (parseDouble(get('qty')) ?? 0).round(),
      isInStock:
          inStockValue == '1' ||
          inStockValue == '1.0000' ||
          inStockValue == 'true',
      attributes: attributes,
    );
  }
}
