import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../core/constants/app_constants.dart';
import '../models/dish_result.dart';
import '../services/location_service.dart';

/// A Google Map rendering one marker per [DishResult], with an optional
/// tap callback (used to surface a bottom-sheet preview).
///
/// Requires a Maps API key per platform — see README → Google Maps setup.
/// Without a key the map tiles render blank but markers/logic still work.
class ResultsMap extends StatefulWidget {
  final List<DishResult> results;
  final LatLngPoint origin;
  final ValueChanged<DishResult>? onMarkerTap;
  final ValueChanged<LatLngBounds>? onCameraIdleBounds;

  const ResultsMap({
    super.key,
    required this.results,
    required this.origin,
    this.onMarkerTap,
    this.onCameraIdleBounds,
  });

  @override
  State<ResultsMap> createState() => _ResultsMapState();
}

class _ResultsMapState extends State<ResultsMap> {
  GoogleMapController? _controller;

  Set<Marker> _buildMarkers() {
    return widget.results.map((r) {
      return Marker(
        markerId: MarkerId(r.dish.id),
        position: LatLng(r.restaurant.latitude, r.restaurant.longitude),
        infoWindow: InfoWindow(
          title: r.dish.name,
          snippet: '${r.restaurant.name} · \$${r.dish.price.toStringAsFixed(2)}',
        ),
        onTap: () => widget.onMarkerTap?.call(r),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(widget.origin.latitude, widget.origin.longitude),
        zoom: AppConstants.defaultMapZoom,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      markers: _buildMarkers(),
      onMapCreated: (c) => _controller = c,
      onCameraIdle: () async {
        if (widget.onCameraIdleBounds == null || _controller == null) return;
        final bounds = await _controller!.getVisibleRegion();
        widget.onCameraIdleBounds!(bounds);
      },
    );
  }
}
