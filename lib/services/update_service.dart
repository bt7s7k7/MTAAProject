import 'dart:async';

import 'package:mtaa_project/app/debug_page.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/constants.dart';
import 'package:mtaa_project/offline_mode/offline_service.dart';
import 'package:mtaa_project/support/exceptions.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class UpdateEvent {
  UpdateEvent({required this.type, required this.id, required this.value});

  final String type;
  final int id;
  final Map<String, dynamic>? value;

  factory UpdateEvent.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "type": String type,
        "id": int id,
        "value": Map<String, dynamic>? value
      } =>
        UpdateEvent(type: type, id: id, value: value),
      _ => throw APIError("Invalid fields for update event: $json")
    };
  }
}

class UpdateService {
  UpdateService._();
  static final instance = UpdateService._();

  io.Socket? _socket;
  String? _lastToken;

  final _streamController = StreamController<UpdateEvent>.broadcast();

  StreamSubscription<UpdateEvent> addListener(
    void Function(UpdateEvent) listener,
  ) {
    return _streamController.stream.listen(listener);
  }

  void submitUpdate(UpdateEvent event) {
    _streamController.add(event);
  }

  Future<void> updateConnection() {
    var token = AuthAdapter.instance.token;

    if (token == _lastToken) return Future.value();
    _lastToken = token;

    if (_socket != null) {
      _socket!.dispose();
      _socket = null;
    }

    if (token == null) {
      return Future.value();
    }

    Completer<void>? completer = Completer<void>();

    _socket = io.io(
      backendURL.toString(),
      io.OptionBuilder().setAuth({
        "token": AuthAdapter.instance.token,
      }).setTransports(["websocket"]).build(),
    );

    debugMessage("[WS] Connecting to the server...");
    _socket!.onConnect((_) {
      if (completer == null) {
        debugMessage("[WS] Reconnected to server");
        OfflineService.instance.setOnlineState(true);
        return;
      }

      debugMessage("[WS] Connected to server");
      OfflineService.instance.setOnlineState(true);
      completer?.complete();
      completer = null;
    });

    _socket!.onDisconnect((_) {
      debugMessage("[WS] Disconnected from the server");
      OfflineService.instance.setOnlineState(false);
    });

    _socket!.onError((data) {
      debugMessage("[WS] Error $data");
    });

    _socket!.on("debug", (data) {
      debugMessage("[WS] Debug: $data");
    });

    _socket!.on("update", (data) {
      debugMessage("[WS] Update: $data");
      _streamController.add(UpdateEvent.fromJson(data));
    });

    return completer!.future;
  }
}
