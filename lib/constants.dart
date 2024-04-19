import 'package:firebase_core/firebase_core.dart';

part "constants.local.dart";

final backendURL = Uri.parse(_backendURL);
final defaultUserIcon = backendURL.resolve("/uploads/icons/default").toString();
const vapidToken = _vapidToken;
const firebaseOptions = _firebaseOptions;
