import 'package:example/ui/location_picker_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_location_picker/flutter_map_location_picker.dart';
import 'package:latlong2/latlong.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? location;
  double? latitude;
  double? longitude;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Example"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(location ?? "You haven't picked a location yet"),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => const LocationPickerPage()))
                      .then((result) {
                    if (result != null) {
                      final locationResult = result as LocationResult;
                      location = locationResult.completeAddress;
                      latitude = locationResult.latitude;
                      longitude = locationResult.longitude;
                      setState(() {});
                    }
                  });
                },
                child: const Text("Open Map Screen")),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)),
                      ),
                      context: context,
                      builder: (context) {
                        return SizedBox(
                          height: 500,
                          child: MapLocationPicker(
                            initialLatitude: latitude,
                            initialLongitude: longitude,
                            onPicked: (result) {
                              Navigator.pop(context);
                              location = result.completeAddress;
                              latitude = result.latitude;
                              longitude = result.longitude;
                            },
                            backgroundColor: Colors.white,
                            centerWidget: const Icon(
                              Icons.add,
                              size: 40,
                              color: Colors.blue,
                            ),
                            sideButtonsColor: Colors.blue,
                            customFooter: (result, controller) {
                              return Container(
                                padding: const EdgeInsets.all(10),
                                color: Colors.lightBlue,
                                child: Text(
                                  result.completeAddress ??
                                      "Location not found",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(color: Colors.white),
                                ),
                              );
                            },
                            myLocationButtonEnabled: true,
                            zoomButtonEnabled: false,
                            switchMapTypeEnabled: false,
                            mapType: MapType.satelite,
                            sideWidget: (result, controller) {
                              return TextButton.icon(
                                onPressed: () {
                                  location = result.completeAddress;
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                                label: const Text("Select Location"),
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.yellow)),
                                icon: const Icon(Icons.check),
                              );
                            },
                          ),
                        );
                      });
                },
                child: const Text("Open Map Sheet")),
          ],
        ),
      ),
    );
  }
}
