import 'package:dio/dio.dart';
import 'package:groceries_app/services/api_errors.dart';
import 'package:groceries_app/services/dto/grocery_item_dto.dart';

class GroceryApiException implements Exception {
  GroceryApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Raw HTTP access to the backend. Sends and receives DTOs only, no domain models.
class GroceryApiService {
  GroceryApiService(this._dio);

  final Dio _dio;

  /// Runs a request and converts transport failures to [GroceryApiException].
  Future<T> _send<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      throw GroceryApiException(
        status != null ? 'Request failed ($status).' : transportErrorMessage(e),
      );
    }
  }

  /// Read.
  Future<List<GroceryItemDto>> getItems() => _send(() async {
    final response = await _dio.get<List<Object?>>('/');
    return [
      for (final item in response.data!)
        GroceryItemDto.fromJson(Map<String, Object?>.from(item as Map)),
    ];
  });

  /// Create: returns the item as stored by the API, including its id.
  Future<GroceryItemDto> createItem(GroceryItemDto item) => _send(() async {
    final response = await _dio.post<Map<String, Object?>>(
      '/',
      data: item.toJson(),
    );
    return GroceryItemDto.fromJson(response.data!);
  });

  /// Update: replaces the item stored under its id (also used to restore).
  Future<void> updateItem(GroceryItemDto item) =>
      _send(() => _dio.put<void>('/${item.id}', data: item.toJson()));

  /// Delete.
  Future<void> deleteItem(String id) => _send(() => _dio.delete<void>('/$id'));
}
