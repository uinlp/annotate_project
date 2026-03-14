final amplifyConfig = '''{
  "version": "1",
  "auth": {
    "aws_region": "af-south-1",
    "user_pool_id": "af-south-1_0CMFymkM5",
    "user_pool_client_id": "30b433ts9m3joaapnv59lcfi4m",
    "username_attributes": ["email"],
    "standard_required_attributes": ["email", "name"],
    "user_verification_types": ["email"],
    "password_policy": {
      "min_length": 8,
      "require_lowercase": true,
      "require_uppercase": true,
      "require_numbers": true,
      "require_symbols": true
    }
  }
}''';
