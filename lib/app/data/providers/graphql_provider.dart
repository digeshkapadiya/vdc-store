// lib/app/data/providers/graphql_provider.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:vdc_store/app/core/graphql_config.dart';
import 'package:vdc_store/app/data/models/product_model.dart';

class GraphqlProvider {
  static const String _getProductsQuery = '''
  query GetProducts(\$search: String, \$pageSize: Int) {
    products(search: \$search, pageSize: \$pageSize) {
      items {
        name
        sku
        price_range {
          minimum_price {
            final_price {
              value
              currency
            }
          }
        }
        image {
          url
        }
      }
    }
  }
''';

  static const String _getProductDetailQuery = '''
    query GetProductDetail(\$sku: String!) {
      products(filter: {sku: {eq: \$sku}}) {
        items {
          name
          sku
          description {
            html
          }
          short_description {
            html
          }
          price_range {
            minimum_price {
              final_price {
                value
                currency
              }
            }
          }
          media_gallery {
            url
            label
          }
          rating_summary
          review_count
          categories {
            name
          }
          feature_highlights
        }
      }
    }
  ''';
  static Future<List<Product>> getProducts({
    String search = "",
    int pageSize = 10,
  }) async {
    final client = GraphqlConfig.client;

    final QueryOptions options = QueryOptions(
      document: gql(_getProductsQuery),
      variables: {'search': search, 'pageSize': pageSize},
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception('GraphQL Error: ${result.exception.toString()}');
    }

    final List<dynamic> items = result.data?['products']?['items'] ?? [];
    return items.map((item) => Product.fromJson(item)).toList();
  }

  static Future<Product> getProductDetail(String sku) async {
    final client = GraphqlConfig.client;

    final QueryOptions options = QueryOptions(
      document: gql(_getProductDetailQuery),
      variables: {'sku': sku},
      fetchPolicy: FetchPolicy.networkOnly,
      errorPolicy: ErrorPolicy.all,
    );

    try {
      final QueryResult result = await client
          .query(options)
          .timeout(
            Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout - please check your internet connection',
              );
            },
          );

      if (result.hasException) {
        if (result.exception?.linkException != null) {
          throw Exception(
            'Network Error: ${result.exception?.linkException.toString()}',
          );
        }
        if (result.exception?.graphqlErrors.isNotEmpty == true) {
          throw Exception(
            'GraphQL Error: ${result.exception?.graphqlErrors.first.message}',
          );
        }
        throw Exception(
          'Unknown GraphQL Error: ${result.exception.toString()}',
        );
      }

      if (result.data == null) {
        throw Exception('No data received from server');
      }

      final List<dynamic> items = result.data?['products']?['items'] ?? [];
      if (items.isEmpty) {
        throw Exception('Product not found');
      }

      return Product.fromDetailJson(items.first);
    } catch (e) {
      print('Error in getProductDetail: $e');
      rethrow;
    }
  }
}
