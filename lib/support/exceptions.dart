class UserException implements Exception {
  const UserException(this.msg);

  final String msg;

  @override
  String toString() => 'ClientException: $msg';
}

class APIError implements Exception {
  const APIError(this.msg);

  final String msg;

  @override
  String toString() => 'APIError: $msg';
}
