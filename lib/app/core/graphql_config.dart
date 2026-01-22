import 'package:graphql_flutter/graphql_flutter.dart';

class GraphqlConfig {
  static const String _baseUrl =
      'http://38.242.130.88/php83/vdcstore_hyva/pub/graphql';

  static GraphQLClient get client {
    final HttpLink httpLink = HttpLink(
      _baseUrl,
      defaultHeaders: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    final Link link = httpLink.concat(
      HttpLink(_baseUrl).concat(
        ErrorLink(
          onException: (request, forward, exception) {
            print('GraphQL Error: ${exception.toString()}');
          },
        ),
      ),
    );

    return GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
      defaultPolicies: DefaultPolicies(
        query: Policies(fetch: FetchPolicy.networkOnly, error: ErrorPolicy.all),
      ),
    );
  }
}
