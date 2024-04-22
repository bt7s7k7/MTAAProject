/// Error in data specified by the user, returned by the backend
class UserException implements Exception {
  const UserException(this.msg);

  final String msg;

  @override
  String toString() => 'ClientException: $msg';
}

/// Error if the user is not authenticated
class NotAuthenticatedException implements Exception {
  @override
  String toString() => "Not Authenticated";
}

/// Error thrown if a component needs online access during first initialization
class OnlineInitRequired implements Exception {
  @override
  String toString() => "Online initialization required";
}

/// Unexpected error during calling of backend API
class APIError implements Exception {
  const APIError(this.msg);

  final String msg;

  @override
  String toString() => 'APIError: $msg';
}
