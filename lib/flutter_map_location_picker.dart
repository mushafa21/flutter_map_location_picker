library flutter_map_location_picker;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';



enum MapType{
  normal,satelite
}

/// Location Result contain:
/// * [latitude] as [double]
/// * [longitude] as [double]
/// * [address] as [String]
class LocationResult{
  double latitude;
  double longitude;
  String address;


  LocationResult(this.latitude, this.longitude, this.address);


}

class MapLocationPicker extends StatefulWidget {
  final LatLng? initialLocation;
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
  final Widget Function(LocationResult locationResult, MapController mapController)? customFooter;
  final Widget Function(LocationResult locationResult, MapController mapController)? sideWidget;


  /// [onPicked] action on click select Location
  const MapLocationPicker({super.key, this.initialLocation, required this.onPicked, this.backgroundColor, this.indicatorColor, this.addressTextStyle, this.searchTextStyle, this.centerWidget, this.buttonColor, this.buttonText, this.leadingIcon, this.searchBarDecoration, this.myLocationButtonEnabled = true, this.searchBarEnabled = true, this.sideWidget, this.customButton, this.customFooter, this.buttonTextStyle, this.zoomButtonEnabled = true, this.initialZoom, this.switchMapTypeEnabled = true, this.mapType, this.sideButtonsColor, this.sideButtonsIconColor});


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
  MapType mapType = MapType.normal;

  double latitude = -6.970136294118362;
  double longitude =  110.40326425161746;

  @override
  void initState() {
    super.initState();
    if(widget.initialLocation != null){
      latitude = widget.initialLocation!.latitude;
      longitude = widget.initialLocation!.longitude;
    }
    if(widget.mapType != null){
      mapType = widget.mapType!;
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
      return widget.searchBarEnabled ? Column(
        children: [
          TextField(
            style: widget.searchTextStyle,
            textInputAction: TextInputAction.search,
            onSubmitted: (value) async{

              error = false;
              setState(() {

              });
              try{
                locationList.clear();
                locationList.addAll(await locationFromAddress(value));

                if(locationList.isNotEmpty){
                } else{
                  error = true;
                }


              }catch(e){
                error = true;
              }
              setState(() {

              });

            },
            decoration: widget.searchBarDecoration ??   InputDecoration(
              prefixIcon: Icon(Icons.search,color: widget.indicatorColor,),
              fillColor: widget.backgroundColor ??  Colors.white,
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
                child: LocationItem(data: locationList[index],backgroundColor: widget.backgroundColor,textStyle: widget.searchTextStyle,));
          },itemCount: locationList.length,shrinkWrap: true,) : Container()
          ,
          error ? Container(
            width: double.infinity,
            padding:const EdgeInsets.all(10),
            color: widget.backgroundColor ??  Colors.white,
            child:  Text("Location not found",style: widget.searchTextStyle,),
          ) : Container()
        ],
      ) : Container();
    }


    Widget viewLocationName(){
      return widget.customFooter != null ? widget.customFooter!(LocationResult(latitude, longitude, locationName),controller) :  Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
          color: widget.backgroundColor ?? Colors.white,
        ),
        padding: const EdgeInsets.all(10),
        child: Column(children: [
          Row(
            children: [
              widget.leadingIcon ??  Icon(Icons.location_city,color: widget.indicatorColor,),
              const SizedBox(width: 10,),
              Expanded(child: Text(locationName,style: widget.addressTextStyle,))
            ],
          ),
          const SizedBox(height: 20,),
          widget.customButton != null ? widget.customButton!(LocationResult(latitude, longitude, locationName)) : ElevatedButton(onPressed: (){
            widget.onPicked(
                LocationResult(latitude, longitude, locationName)
            );
          },style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all( widget.buttonColor)
          ), child:  Text(widget.buttonText != null ? widget.buttonText! : "Select Location"),)
        ],),
      );
    }

    Widget sideButton(){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Visibility(
            visible: widget.switchMapTypeEnabled,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextButton(onPressed: (){
                if(mapType == MapType.normal){
                  mapType = MapType.satelite;
                } else{
                  mapType = MapType.normal;
                }
                setState(() {

                });

              }, style: TextButton.styleFrom(
                  backgroundColor:widget.sideButtonsColor ?? Theme.of(context).primaryColor,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10)
              ),child:  Icon(Icons.layers,color: widget.sideButtonsIconColor ??  Colors.white),),
            ),
          ),
          Visibility(
            visible: widget.zoomButtonEnabled,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextButton(onPressed: (){
                if(controller.camera.zoom < 17){
                  controller.move(LatLng(latitude, longitude), controller.camera.zoom + 1);
                }
              },style: TextButton.styleFrom(
                backgroundColor:widget.sideButtonsColor ?? Theme.of(context).primaryColor,
                shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10)
              ), child:  Icon(Icons.zoom_in_map,color: widget.sideButtonsIconColor ??  Colors.white),),
            ),
          ),
          Visibility(
            visible: widget.zoomButtonEnabled,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextButton(onPressed: (){
                if(controller.camera.zoom > 0){
                  controller.move(LatLng(latitude, longitude), controller.camera.zoom - 1);
                }
              },style: TextButton.styleFrom(
                  backgroundColor:widget.sideButtonsColor ?? Theme.of(context).primaryColor,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10)
              ), child:  Icon(Icons.zoom_out_map,color: widget.sideButtonsIconColor ??  Colors.white),),
            ),
          ),
          Visibility(
            visible: widget.myLocationButtonEnabled,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextButton(onPressed: (){
                move = true;
                latitude = widget.initialLocation?.latitude ?? -6.970136294118362;
                longitude = widget.initialLocation?.longitude ??  110.40326425161746;
                setState(() {
                });
                controller.move(LatLng(latitude, longitude), 16);
                _timer?.cancel();
                getLocationName();
              },style: TextButton.styleFrom(
                  backgroundColor:widget.sideButtonsColor ?? Theme.of(context).primaryColor,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10)
              ), child: Icon(Icons.my_location,color: widget.sideButtonsIconColor ??  Colors.white),),
            ),
          ),
          widget.sideWidget != null ? widget.sideWidget!(LocationResult(latitude, longitude, locationName),controller) : Container(),

        ],
      );
    }






    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: LatLng(latitude, longitude),
        initialZoom: 16,
        maxZoom: 18,
        onMapReady: () {
          controller.mapEventStream.listen((evt) async {
            _timer?.cancel();
            if(!move){
              _timer = Timer(const Duration(milliseconds: 200), () {
                latitude = evt.camera.center.latitude;
                longitude = evt.camera.center.longitude;
                getLocationName();

              });
            } else{
              move = false;
            }

            setState(() {
            });
          });
        },
      ),
      children: [
        TileLayer(
          urlTemplate: mapType == MapType.normal ? "http://tile.openstreetmap.org/{z}/{x}/{y}.png" : 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}.jpg',
          userAgentPackageName: 'com.example.app',
        ),
        Stack(
          children: [
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
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding:  const EdgeInsets.only(right: 10),
                        child: sideButton(),
                      ),),
                    const SizedBox(height: 10,),
                    viewLocationName(),
                  ],
                )),
            Center(child: widget.centerWidget != null ? widget.centerWidget! : Icon(Icons.location_on_rounded,size: 60,color: widget.indicatorColor != null ? widget.indicatorColor! : Theme.of(context).colorScheme.primary,))
          ],
        )
      ],
    );
  }
}


class LocationItem extends StatefulWidget {
  final Color? backgroundColor;
  final Color? indicatorColor;

  final TextStyle? textStyle;
  final Location data;
  const LocationItem({super.key, required this.data, this.backgroundColor, this.textStyle, this.indicatorColor});

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
      color: widget.backgroundColor ?? Colors.white,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(Icons.location_on_rounded,color: widget.indicatorColor,),
          const SizedBox(width: 10,),
          Expanded(child: Text(locationName ?? "Searching location...",style: widget.textStyle,))

        ],
      ),
    );
  }
}