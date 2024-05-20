library flutter_map_location_picker;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

/// Change the Map Tiles for OSM
enum MapType { normal, satelite }

/// Location Result contains:
/// * [latitude] as [double]
/// * [longitude] as [double]
/// * [completeAddress] as [String]
/// * [placemark] as [Placemark]
class LocationResult {
  /// the latitude of the picked location
  double? latitude;

  /// the longitude of the picked location
  double? longitude;

  /// the complete address of the picked location
  String? completeAddress;

  /// the placemark infomation of the picked location
  Placemark? placemark;

  LocationResult(
      {required this.latitude,
      required this.longitude,
      required this.completeAddress,
      required this.placemark});
}

class MapLocationPicker extends StatefulWidget {
  /// The initial longitude
  final double? initialLongitude;

  /// The initial latitude
  final double? initialLatitude;

  /// callback when location is picked
  final Function(LocationResult onPicked) onPicked;
  final Color? backgroundColor;

  final Color? indicatorColor;
  final Color? sideButtonsColor;
  final Color? sideButtonsIconColor;

  final TextStyle? addressTextStyle;
  final TextStyle? searchTextStyle;
  final TextStyle? buttonTextStyle;
  final Widget? centerWidget;
  final double? initialZoom;
  final Color? buttonColor;
  final String? buttonText;
  final Widget? leadingIcon;
  final InputDecoration? searchBarDecoration;
  final bool myLocationButtonEnabled;
  final bool zoomButtonEnabled;
  final bool searchBarEnabled;
  final bool switchMapTypeEnabled;
  final MapType? mapType;
  final Widget Function(LocationResult locationResult)? customButton;
  final Widget Function(
      LocationResult locationResult, MapController mapController)? customFooter;
  final Widget Function(
      LocationResult locationResult, MapController mapController)? sideWidget;

  /// [onPicked] action on click select Location
  /// [initialLatitude] the latitude of the initial location
  /// [initialLongitude] the longitude of the initial location
  const MapLocationPicker(
      {super.key,
      required this.initialLatitude,
      required this.initialLongitude,
      required this.onPicked,
      this.backgroundColor,
      this.indicatorColor,
      this.addressTextStyle,
      this.searchTextStyle,
      this.centerWidget,
      this.buttonColor,
      this.buttonText,
      this.leadingIcon,
      this.searchBarDecoration,
      this.myLocationButtonEnabled = true,
      this.searchBarEnabled = true,
      this.sideWidget,
      this.customButton,
      this.customFooter,
      this.buttonTextStyle,
      this.zoomButtonEnabled = true,
      this.initialZoom,
      this.switchMapTypeEnabled = true,
      this.mapType,
      this.sideButtonsColor,
      this.sideButtonsIconColor});

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  bool _error = false;
  bool _move = false;
  Timer? _timer;
  final MapController _controller = MapController();
  final List<Location> _locationList = [];
  MapType _mapType = MapType.normal;

  late LocationResult _locationResult;

  double _latitude = -6.984072660841485;
  double _longitude = 110.40950678599624;

  @override
  void initState() {
    super.initState();
    _latitude = widget.initialLatitude ?? -6.984072660841485;
    _longitude = widget.initialLongitude ?? 110.40950678599624;

    if (widget.mapType != null) {
      _mapType = widget.mapType!;
    }
    _locationResult = LocationResult(
        latitude: _latitude,
        longitude: _longitude,
        completeAddress: null,
        placemark: null);
    _getLocationName();
  }

  _getLocationName() async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(_latitude, _longitude);
      if (placemarks.isNotEmpty) {
        final completeAddress =
            "${placemarks.first.street}, ${placemarks.first.name}, ${placemarks.first.locality}, ${placemarks.first.subAdministrativeArea}";
        _locationResult = LocationResult(
            latitude: _latitude,
            longitude: _longitude,
            completeAddress: completeAddress,
            placemark: placemarks.first);
      } else {
        _locationResult = LocationResult(
            latitude: _latitude,
            longitude: _longitude,
            completeAddress: null,
            placemark: null);
      }
    } catch (e) {
      _locationResult = LocationResult(
          latitude: _latitude,
          longitude: _longitude,
          completeAddress: null,
          placemark: null);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget searchBar() {
      return widget.searchBarEnabled
          ? Column(
              children: [
                TextField(
                  style: widget.searchTextStyle,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) async {
                    _error = false;
                    setState(() {});
                    try {
                      _locationList.clear();
                      _locationList.addAll(await locationFromAddress(value));

                      if (_locationList.isNotEmpty) {
                      } else {
                        _error = true;
                      }
                    } catch (e) {
                      _error = true;
                    }
                    setState(() {});
                  },
                  decoration: widget.searchBarDecoration ??
                      InputDecoration(
                        prefixIcon: Icon(
                          Icons.search,
                          color: widget.indicatorColor,
                        ),
                        fillColor: widget.backgroundColor ?? Colors.white,
                        filled: true,
                      ),
                ),
                _locationList.isNotEmpty
                    ? ListView.builder(
                        itemBuilder: (context, index) {
                          return InkWell(
                              onTap: () {
                                _move = true;
                                _latitude = _locationList[index].latitude;
                                _longitude = _locationList[index].longitude;
                                _controller.move(
                                    LatLng(_locationList[index].latitude,
                                        _locationList[index].longitude),
                                    16);
                                _getLocationName();
                                _locationList.clear();
                                setState(() {});
                              },
                              child: LocationItem(
                                data: _locationList[index],
                                backgroundColor: widget.backgroundColor,
                                textStyle: widget.searchTextStyle,
                              ));
                        },
                        itemCount: _locationList.length,
                        shrinkWrap: true,
                      )
                    : Container(),
                _error
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        color: widget.backgroundColor ?? Colors.white,
                        child: Text(
                          "Location not found",
                          style: widget.searchTextStyle,
                        ),
                      )
                    : Container()
              ],
            )
          : Container();
    }

    Widget viewLocationName() {
      return widget.customFooter != null
          ? widget.customFooter!(_locationResult, _controller)
          : Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                color: widget.backgroundColor ?? Colors.white,
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    children: [
                      widget.leadingIcon ??
                          Icon(
                            Icons.location_city,
                            color: widget.indicatorColor,
                          ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: Text(
                        _locationResult.completeAddress ?? "Location not found",
                        style: widget.addressTextStyle,
                      ))
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  widget.customButton != null
                      ? widget.customButton!(_locationResult)
                      : ElevatedButton(
                          onPressed: () {
                            widget.onPicked(_locationResult);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: widget.buttonColor),
                          child: Text(widget.buttonText != null
                              ? widget.buttonText!
                              : "Select Location"),
                        )
                ],
              ),
            );
    }

    Widget sideButton() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Visibility(
            visible: widget.switchMapTypeEnabled,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextButton(
                onPressed: () {
                  if (_mapType == MapType.normal) {
                    _mapType = MapType.satelite;
                  } else {
                    _mapType = MapType.normal;
                  }
                  setState(() {});
                },
                style: TextButton.styleFrom(
                    backgroundColor: widget.sideButtonsColor ??
                        Theme.of(context).primaryColor,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10)),
                child: Icon(Icons.layers,
                    color: widget.sideButtonsIconColor ?? Colors.white),
              ),
            ),
          ),
          Visibility(
            visible: widget.zoomButtonEnabled,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextButton(
                onPressed: () {
                  if (_controller.camera.zoom < 17) {
                    _controller.move(LatLng(_latitude, _longitude),
                        _controller.camera.zoom + 1);
                  }
                },
                style: TextButton.styleFrom(
                    backgroundColor: widget.sideButtonsColor ??
                        Theme.of(context).primaryColor,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10)),
                child: Icon(Icons.zoom_in_map,
                    color: widget.sideButtonsIconColor ?? Colors.white),
              ),
            ),
          ),
          Visibility(
            visible: widget.zoomButtonEnabled,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextButton(
                onPressed: () {
                  if (_controller.camera.zoom > 0) {
                    _controller.move(LatLng(_latitude, _longitude),
                        _controller.camera.zoom - 1);
                  }
                },
                style: TextButton.styleFrom(
                    backgroundColor: widget.sideButtonsColor ??
                        Theme.of(context).primaryColor,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10)),
                child: Icon(Icons.zoom_out_map,
                    color: widget.sideButtonsIconColor ?? Colors.white),
              ),
            ),
          ),
          Visibility(
            visible: widget.myLocationButtonEnabled,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextButton(
                onPressed: () {
                  _move = true;
                  _latitude = widget.initialLatitude ?? -6.970136294118362;
                  _longitude = widget.initialLongitude ?? 110.40326425161746;
                  setState(() {});
                  _controller.move(LatLng(_latitude, _longitude), 16);
                  _timer?.cancel();
                  _getLocationName();
                },
                style: TextButton.styleFrom(
                    backgroundColor: widget.sideButtonsColor ??
                        Theme.of(context).primaryColor,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10)),
                child: Icon(Icons.my_location,
                    color: widget.sideButtonsIconColor ?? Colors.white),
              ),
            ),
          ),
          widget.sideWidget != null
              ? widget.sideWidget!(_locationResult, _controller)
              : Container(),
        ],
      );
    }

    return FlutterMap(
      mapController: _controller,
      options: MapOptions(
        initialCenter: LatLng(_latitude, _longitude),
        initialZoom: 16,
        maxZoom: 18,
        onMapReady: () {
          _controller.mapEventStream.listen((evt) async {
            _timer?.cancel();
            if (!_move) {
              _timer = Timer(const Duration(milliseconds: 200), () {
                _latitude = evt.camera.center.latitude;
                _longitude = evt.camera.center.longitude;
                _getLocationName();
              });
            } else {
              _move = false;
            }

            setState(() {});
          });
        },
      ),
      children: [
        TileLayer(
          urlTemplate: _mapType == MapType.normal
              ? "http://tile.openstreetmap.org/{z}/{x}/{y}.png"
              : 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}.jpg',
          userAgentPackageName: 'com.example.app',
        ),
        Stack(
          children: [
            Positioned(top: 10, left: 10, right: 10, child: searchBar()),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: sideButton(),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    viewLocationName(),
                  ],
                )),
            Center(
                child: widget.centerWidget != null
                    ? widget.centerWidget!
                    : Icon(
                        Icons.location_on_rounded,
                        size: 60,
                        color: widget.indicatorColor != null
                            ? widget.indicatorColor!
                            : Theme.of(context).colorScheme.primary,
                      ))
          ],
        )
      ],
    );
  }
}

/// Widget for showing the picked location address
class LocationItem extends StatefulWidget {
  /// Background color for the container
  final Color? backgroundColor;

  /// Indicator color for the container
  final Color? indicatorColor;

  /// Text Style for the address text
  final TextStyle? textStyle;

  /// The location data for the picked location
  final Location data;

  const LocationItem(
      {super.key,
      required this.data,
      this.backgroundColor,
      this.textStyle,
      this.indicatorColor});

  @override
  State<LocationItem> createState() => _LocationItemState();
}

class _LocationItemState extends State<LocationItem> {
  String? locationName;

  _getLocationName() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          widget.data.latitude, widget.data.longitude);
      if (placemarks.isNotEmpty) {
        locationName =
            "${placemarks.first.street}, ${placemarks.first.name}, ${placemarks.first.locality}, ${placemarks.first.subAdministrativeArea}";
      } else {
        locationName = "Location not found";
      }
    } catch (e) {
      locationName = "Location not found";
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getLocationName();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor ?? Colors.white,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(
            Icons.location_on_rounded,
            color: widget.indicatorColor,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
              child: Text(
            locationName ?? "Searching location...",
            style: widget.textStyle,
          ))
        ],
      ),
    );
  }
}
