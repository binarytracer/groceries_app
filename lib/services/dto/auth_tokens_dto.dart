import 'package:groceries_app/services/dto/grocery_item_dto.dart';

/// The token pair exactly as `/auth` and `/auth/refresh` send it.
class AuthTokensDto {
  const AuthTokensDto({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  factory AuthTokensDto.fromJson(Json json) => AuthTokensDto(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
  );
}
