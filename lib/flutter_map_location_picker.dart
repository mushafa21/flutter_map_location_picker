library flutter_map_location_picker;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class LocationResult{
  double latitude;
  double longitude;
  String address;

  LocationResult(this.latitude, this.longitude, this.address);


}

class MapLocationPicker extends StatefulWidget {
  final LatLng? initialLocation;
  final Function(LocationResult) onNext;
  const MapLocationPicker({super.key, this.initialLocation, required this.onNext});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  bool error = false;
  bool move = false;
  Timer? _timer;
  final MapController controller = MapController();
  final List<Location> locationList = [];
  String locationName = "";
  double latitude = -6.970136294118362;
  double longitude =  110.40326425161746;

  @override
  void initState() {
    super.initState();
    if(widget.initialLocation != null){
      latitude = widget.initialLocation!.latitude;
      longitude = widget.initialLocation!.longitude;
    }
    getLocationName();
  }


  getLocationName() async{
    try{
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if(placemarks.isNotEmpty){
        locationName = "${placemarks.first.street}, ${placemarks.first.name}, ${placemarks.first.locality}, ${placemarks.first.subAdministrativeArea}";
      } else{
        locationName = "Location not found";
      }
    }catch(e){
      locationName = "Location not found";
    }
    setState(() {
    });
  }




  @override
  Widget build(BuildContext context) {

    Widget searchBar(){
      return Column(
        children: [
          TextField(
            textInputAction: TextInputAction.search,
            onSubmitted: (value) async{

              error = false;
              setState(() {

              });
              try{
                locationList.clear();
                locationList.addAll(await locationFromAddress(value));

                if(locationList.isNotEmpty){
                  locationList.forEach((element) {
                    print(element.latitude.toString() + " , " + element.longitude.toString() );

                  });
                } else{
                  error = true;
                  print("gaada lokasi");
                }


              }catch(e){
                error = true;
              }
              setState(() {

              });

            },
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              fillColor: Colors.white,
              filled: true,

            ),
          ),
          locationList.isNotEmpty ? ListView.builder(itemBuilder: (context,index){
            return InkWell(
                onTap: () {
                  move = true;
                  latitude = locationList[index].latitude;
                  longitude =  locationList[index].longitude;
                  controller.move(LatLng(locationList[index].latitude, locationList[index].longitude), 16);
                  getLocationName();
                  locationList.clear();
                  setState(() {
                  });

                },
                child: LocationItem(data: locationList[index]));
          },itemCount: locationList.length,shrinkWrap: true,) : Container()
          ,
          error ? Container(
            width: double.infinity,
            padding:EdgeInsets.all(10),
            color: Colors.white,
            child: Text("Location not found"),
          ) : Container()
        ],
      );
    }


    Widget viewLocationName(){
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        padding: EdgeInsets.all(10),
        child: Column(children: [
          Row(
            children: [
              Icon(Icons.location_city,),
              SizedBox(width: 10,),
              Expanded(child: Text(locationName))
            ],
          ),
          SizedBox(height: 20,),
          ElevatedButton(onPressed: (){
            widget.onNext(
                LocationResult(latitude, longitude, locationName)
            );
          }, child: Text("Select Location"),)
        ],),
      );
    }

    Widget myLocationButton(){
      return IconButton(onPressed: (){
        move = true;
        latitude = widget.initialLocation?.latitude ?? -6.970136294118362;
        longitude = widget.initialLocation?.longitude ??  110.40326425161746;
        setState(() {
        });
        controller.move(LatLng(latitude, longitude), 16);
        _timer?.cancel();
        getLocationName();
      }, icon: Icon(Icons.my_location),color: Colors.white,style: IconButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),padding: EdgeInsets.all(10),);
    }






    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        center: LatLng(latitude, longitude),
        zoom: 16,
        onMapReady: () {
          controller.mapEventStream.listen((evt) async {
            _timer?.cancel();
            if(!move){
              _timer = Timer(Duration(milliseconds: 200), () {
                latitude = evt.center.latitude;
                longitude = evt.center.longitude;
                getLocationName();
                print(evt.center);

              });
            } else{
              move = false;
            }

            setState(() {

            });



          });
        },
      ),
      nonRotatedChildren: [
        Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: searchBar()),
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Align(
                  child: Padding(
                    padding:  EdgeInsets.only(right: 10),
                    child: myLocationButton(),
                  ),
                  alignment: Alignment.centerRight,),
                SizedBox(height: 10,),
                viewLocationName(),
              ],
            )),
        Center(child: Icon(Icons.location_on_rounded,size: 60,color: Theme.of(context).colorScheme.primary,))
      ],
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
      ],
    );
  }
}


class LocationItem extends StatefulWidget {
  final Location data;
  const LocationItem({super.key, required this.data});

  @override
  State<LocationItem> createState() => _LocationItemState();
}

class _LocationItemState extends State<LocationItem> {
  String? locationName;

  getLocationName() async{
    try{
      List<Placemark> placemarks = await placemarkFromCoordinates(widget.data.latitude, widget.data.longitude);
      if(placemarks.isNotEmpty){
        locationName = "${placemarks.first.street}, ${placemarks.first.name}, ${placemarks.first.locality}, ${placemarks.first.subAdministrativeArea}";
      } else{
        locationName = "Location not found";

      }
    }catch(e){
      locationName = "Location not found";
    }
    setState(() {

    });

  }
  @override
  void initState() {
    super.initState();
    getLocationName();
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(Icons.location_on_rounded),
          SizedBox(width: 10,),
          Expanded(child: Text(locationName ?? "Searching location..."))

        ],
      ),
    );
  }
}