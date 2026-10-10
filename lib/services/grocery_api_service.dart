import 'dart:convert';

import 'package:groceries_app/services/dto/grocery_item_dto.dart';
import 'package:http/http.dart' as http;

/// Base URL of the groceries API. Override at build/run time with
/// `--dart-define=API_URL=http://192.168.1.10:3000`.
/// The default is the host machine as seen from the Android emulator.
const _apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://10.0.2.2:3000',
);

class GroceryApiException implements Exception {
  GroceryApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Raw HTTP access to the backend. Sends and receives DTOs only, no domain models.
class GroceryApiService {
  GroceryApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _headers = {'Content-Type': 'application/json'};

  Uri _uri([String path = '']) => Uri.parse('$_apiUrl/$path');

  void _check(http.Response response) {
    if (response.statusCode >= 400) {
      throw GroceryApiException('Request failed (${response.statusCode}).');
    }
  }

  /// Read.
  Future<List<GroceryItemDto>> getItems() async {
    final response = await _client.get(_uri());
    _check(response);
    final body = json.decode(response.body) as List<Object?>;
    return [
      for (final item in body)
        GroceryItemDto.fromJson(Map<String, Object?>.from(item as Map)),
    ];
  }

  /// Create: returns the item as stored by the API, including its id.
  Future<GroceryItemDto> createItem(GroceryItemDto item) async {
    final response = await _client.post(
      _uri(),
      headers: _headers,
      body: json.encode(item.toJson()),
    );
    _check(response);
    return GroceryItemDto.fromJson(
      Map<String, Object?>.from(json.decode(response.body) as Map),
    );
  }

  /// Update: replaces the item stored under its id (also used to restore).
  Future<void> updateItem(GroceryItemDto item) async {
    final response = await _client.put(
      _uri(item.id),
      headers: _headers,
      body: json.encode(item.toJson()),
    );
    _check(response);
  }

  /// Delete.
  Future<void> deleteItem(String id) async {
    _check(await _client.delete(_uri(id)));
  }
}
