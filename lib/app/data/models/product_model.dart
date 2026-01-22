// lib/app/data/models/product_model.dart
class Product {
  final String name;
  final String sku;
  final double price;
  final String currency;
  final String? imageUrl;
  final List<String> mediaGallery;
  final String? description;
  final String? shortDescription;
  final double? ratingSummary;
  final int? reviewCount;
  final List<String> categories;
  final Map<String, dynamic> customAttributes;
  final List<String>? featureHighlights;
  final Map<String, dynamic>? specifications;
  final String? installationGuide;
  final List<String>? supportFeatures;

  Product({
    required this.name,
    required this.sku,
    required this.price,
    required this.currency,
    this.imageUrl,
    this.mediaGallery = const [],
    this.description,
    this.shortDescription,
    this.ratingSummary,
    this.reviewCount,
    this.categories = const [],
    this.customAttributes = const {},
    this.featureHighlights,
    this.specifications,
    this.installationGuide,
    this.supportFeatures,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final priceData = json['price_range']['minimum_price']['final_price'];
    return Product(
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      price: (priceData['value'] ?? 0.0).toDouble(),
      currency: priceData['currency'] ?? 'USD',
      imageUrl: json['image']?['url'],
    );
  }

  factory Product.fromDetailJson(Map<String, dynamic> json) {
    final priceData = json['price_range']['minimum_price']['final_price'];
    final mediaGallery =
        (json['media_gallery'] as List?)
            ?.map((item) => item['url'] as String)
            .toList() ??
        [];

    final categories =
        (json['categories'] as List?)
            ?.map((item) => item['name'] as String)
            .toList() ??
        [];

    final customAttributes = <String, dynamic>{};
    if (json['custom_attributes'] != null) {
      for (var attr in json['custom_attributes']) {
        customAttributes[attr['attribute_code']] = attr['value'];
      }
    }

    return Product(
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      price: (priceData['value'] ?? 0.0).toDouble(),
      currency: priceData['currency'] ?? 'USD',
      imageUrl: mediaGallery.isNotEmpty ? mediaGallery.first : null,
      mediaGallery: mediaGallery,
      description: json['description']?['html'],
      shortDescription: json['short_description']?['html'],
      ratingSummary: json['rating_summary']?.toDouble(),
      reviewCount: json['review_count'],
      categories: categories,
      customAttributes: customAttributes,
    );
  }
}
