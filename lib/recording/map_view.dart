import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mtaa_project/app/debug_page.dart';
import 'package:mtaa_project/recording/activity_tracker.dart';
import 'package:mtaa_project/recording/recording_page.dart';
import 'package:mtaa_project/recording/recording_setup_page.dart';
import 'package:mtaa_project/services/permission_service.dart';
import 'package:mtaa_project/settings/locale_manager.dart';

/// Location to show on the map before the real user location can be determined
final _defaultLocation = GeoPoint(latitude: 0, longitude: 0);

/// Key to preserve map state when going from [RecordingSetupPage] to [RecordingPage]
final mapGlobalKey = GlobalKey(debugLabel: "map-view");

/// Shows a map
class MapView extends StatefulWidget {
  const MapView({super.key, this.onLocationUpdate, this.tracker, this.path});

  /// Callback when a user location changes
  final void Function(GeoPoint location)? onLocationUpdate;

  /// The activity tracker to show a path for
  final ActivityTracker? tracker;

  /// Static path to display
  final List<GeoPoint>? path;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  bool _ready = false;

  /// Is location tracking enabled
  late bool _locationEnabled;

  /// Map controller used by the [OSMFlutter] widget
  late MapController _mapController;

  /// Subscription to the location tracker
  StreamSubscription<Position>? _positionSubscription;

  /// Reference to the current [ActivityTracker]
  ActivityTracker? _tracker;

  /// Last position found by the location tracker
  GeoPoint? _lastPosition;

  /// Handler for a new location found by the location tracker
  void _handleLocationChange(GeoPoint position) {
    _mapController.changeLocation(position);
    _lastPosition = position;
    if (widget.onLocationUpdate != null) widget.onLocationUpdate!(position);
  }

  /// Handler when the location permission is changed
  Future<void> _handleLocationPermissionChanged() async {
    if (widget.path != null) return;

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

  /// Callback after [PermissionService] update, calls [_handleLocationPermissionChanged] if the location permission changes
  void _onPermissionChanged() {
    var newLocationEnabled = PermissionService.instance.location.isGranted;
    if (newLocationEnabled == _locationEnabled) return;
    _handleLocationPermissionChanged();
  }

  /// Handler for when the current [_tracker] updates its path
  Future<void> _handleTrackerUpdate() async {
    await _mapController.clearAllRoads();
    if (_tracker!.path.length < 2) return;
    _mapController.drawRoadManually(_tracker!.path, const RoadOption.empty());
  }

  /// Draws a static path based, zooms into it and locks the camera into the path bounding box
  void _drawPath() async {
    var path = widget.path!;
    debugMessage("[Map] Drawing path $path");
    await _mapController.clearAllRoads();
    if (path.length < 2) return;
    var lat1 = path[0].latitude;
    var lat2 = path[0].latitude;
    var lng1 = path[0].longitude;
    var lng2 = path[0].longitude;

    for (final point in path.skip(1)) {
      lat1 = min(point.latitude, lat1);
      lng1 = min(point.longitude, lng1);
      lat2 = max(point.latitude, lat2);
      lng2 = max(point.longitude, lng2);
    }

    var latBuffer = (lat1 - lat2).abs() * 0.3;
    var lngBuffer = (lng1 - lng2).abs() * 0.3;

    lat1 -= latBuffer;
    lat2 += latBuffer;
    lng1 -= lngBuffer;
    lng2 += lngBuffer;

    var bounds = BoundingBox(
      north: lat2,
      south: lat1,
      west: lng1,
      east: lng2,
    );
    _mapController.limitAreaMap(bounds).then((_) {
      _mapController.zoomToBoundingBox(bounds);
    });

    _mapController.drawRoadManually(widget.path!, const RoadOption.empty());
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
      if (_lastPosition != null) {
        _tracker!.appendLocation(_lastPosition!);
      }
    }

    if (widget.path != null) {
      _drawPath();
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

  /// Handles when the [OSMFlutter] is initialized
  void _setReady() {
    if (widget.path != null) {
      _drawPath();
    }

    if (_lastPosition != null) {
      _mapController.setZoom(zoomLevel: 19);
      _handleLocationChange(_lastPosition!);
    }

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
