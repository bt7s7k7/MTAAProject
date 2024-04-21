import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mtaa_project/app/debug_page.dart';
import 'package:mtaa_project/recording/activity_tracker.dart';
import 'package:mtaa_project/services/permission_service.dart';
import 'package:mtaa_project/settings/locale_manager.dart';

final _defaultLocation = GeoPoint(latitude: 0, longitude: 0);
final mapGlobalKey = GlobalKey(debugLabel: "map-view");

class MapView extends StatefulWidget {
  const MapView({super.key, this.onLocationUpdate, this.tracker});

  final void Function(GeoPoint location)? onLocationUpdate;
  final ActivityTracker? tracker;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  bool _ready = false;

  late bool _locationEnabled;
  late MapController _mapController;

  StreamSubscription<Position>? _positionSubscription;
  ActivityTracker? _tracker;

  void _handleLocationChange(GeoPoint position) {
    _mapController.changeLocation(position);
    if (widget.onLocationUpdate != null) widget.onLocationUpdate!(position);
  }

  Future<void> _handleLocationPermissionChanged() async {
    if (!_locationEnabled) {
      debugMessage("[Map] Disabled location");
      return;
    }

    debugMessage("[Map] Enabled location");

    var serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugMessage("[Map] Location service not enabled");
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugMessage("[Map] Location permission reports denied");
      return;
    }

    if (_positionSubscription != null) {
      _positionSubscription!.cancel();
      _positionSubscription = null;
    }

    _positionSubscription =
        Geolocator.getPositionStream().listen((currentLocation) {
      _handleLocationChange(GeoPoint(
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
      ));
    });

    var currentLocation = await Geolocator.getCurrentPosition();
    _handleLocationChange(GeoPoint(
      latitude: currentLocation.latitude,
      longitude: currentLocation.longitude,
    ));
    _mapController.setZoom(zoomLevel: 19);
  }

  void _onPermissionChanged() {
    var newLocationEnabled = PermissionService.instance.location.isGranted;
    if (newLocationEnabled == _locationEnabled) return;
    _handleLocationPermissionChanged();
  }

  Future<void> _handleTrackerUpdate() async {
    await _mapController.clearAllRoads();
    if (_tracker!.path.length < 2) return;
    _mapController.drawRoadManually(_tracker!.path, const RoadOption.empty());
  }

  @override
  void initState() {
    super.initState();

    _locationEnabled = PermissionService.instance.location.isGranted;
    PermissionService.instance.addListener(_onPermissionChanged);

    _mapController = MapController(
      initPosition: _defaultLocation,
    );
    _handleLocationPermissionChanged();

    if (widget.tracker != null) {
      widget.tracker!.addListener(_handleTrackerUpdate);
      _tracker = widget.tracker;
    }
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_tracker != null) {
      _tracker!.removeListener(_handleTrackerUpdate);
      _tracker = null;
    }

    if (widget.tracker != null) {
      debugMessage("[Map] Tracker bound in map");
      widget.tracker!.addListener(_handleTrackerUpdate);
      _tracker = widget.tracker;
    }
  }

  @override
  void dispose() {
    PermissionService.instance.removeListener(_onPermissionChanged);
    _positionSubscription?.cancel();
    _mapController.dispose();
    _tracker?.removeListener(_handleTrackerUpdate);

    super.dispose();
  }

  void _setReady() {
    setState(() {
      _ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    var map = OSMFlutter(
      controller: _mapController,
      onMapIsReady: (ready) {
        if (ready) _setReady();
      },
      osmOption: const OSMOption(
        showContributorBadgeForOSM: true,
        zoomOption: ZoomOption(
          initZoom: 3,
          minZoomLevel: 3,
          maxZoomLevel: 19,
          stepZoom: 1.0,
        ),
        enableRotationByGesture: false,
        roadConfiguration: RoadOption(
          roadColor: Colors.yellowAccent,
        ),
      ),
    );

    return Stack(
      children: switch (_ready) {
        true => [map],
        false => [
            map,
            Container(
              decoration: BoxDecoration(color: theme.colorScheme.background),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    value: null,
                  ),
                  const SizedBox(height: 10),
                  ListenableBuilder(
                    listenable: LanguageManager.instance,
                    builder: (_, __) =>
                        Text(LanguageManager.instance.language.loadingMap()),
                  ),
                ],
              ),
            )
          ],
      },
    );
  }
}
