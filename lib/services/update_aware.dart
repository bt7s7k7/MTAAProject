import 'package:mtaa_project/services/update_service.dart';

/// Allows an representation of a backend entity to change data in an [UpdateEvent] before being replaced by them
abstract mixin class UpdateAware {
  void patchUpdate(Map<String, dynamic> json);
}
