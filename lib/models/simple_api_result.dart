class SimpleApiResult<T> {
  final bool isSuccess;
  final String? errorMessage;
  final T? result;

  SimpleApiResult({
    required this.isSuccess,
    this.errorMessage,
    required this.result,
  });

  static SimpleApiResult<T> fromJson<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final isSuccess = json['isSuccess'] ?? false;
    return SimpleApiResult(
      isSuccess: isSuccess,
      errorMessage: json['errorMessage'],
      result:
          isSuccess && json['result'] != null
              ? fromJson(json['result'] as Map<String, dynamic>)
              : null,
    );
  }

  factory SimpleApiResult.error(String errorMessage) {
    return SimpleApiResult(
      isSuccess: false,
      errorMessage: errorMessage,
      result: null,
    );
  }
}
