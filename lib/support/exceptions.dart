class UserException implements Exception {
  const UserException(this.msg);

  final String msg;

  @override
  String toString() => 'ClientException: $msg';
}

class NotAuthenticatedException implements Exception {
  @override
  String toString() => "Not Authenticated";
}

class OnlineInitRequired implements Exception {
  @override
  String toString() => "Online initialization required";
}

class APIError implements Exception {
  const APIError(this.msg);

  final String msg;

  @override
  String toString() => 'APIError: $msg';
}
