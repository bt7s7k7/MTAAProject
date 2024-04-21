import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:mtaa_project/settings/locale_manager.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  bool _ready = false;

  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController(
      initPosition:
          GeoPoint(latitude: 48.11977120843681, longitude: 17.118147610953137),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
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
