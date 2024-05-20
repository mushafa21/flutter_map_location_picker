# flutter_map_location_picker

[![Flutter Package](https://img.shields.io/pub/v/flutter_map_location_picker.svg)](https://pub.dev/packages/flutter_map_location_picker)
[![Pub Points](https://img.shields.io/pub/points/flutter_map_location_picker)](https://pub.dev/packages/flutter_map_location_picker/score)
[![Popularity](https://img.shields.io/pub/popularity/flutter_map_location_picker)](https://pub.dev/packages/flutter_map_location_picker/score)

**A flutter plugin for picking location by using flutter_map and geocoding. Completely free and highly customizable**

[github](https://github.com/mushafa21/flutter_map_location_picker)

## Demo

![](https://github.com/mushafa21/flutter_map_location_picker/blob/main/example.gif)

## Usage

### Add dependency

Please check the latest version before installation.
If there is any problem with the new version, please use the previous version

```yaml
dependencies:
  flutter:
    sdk: flutter
  # add flutter_map_location_picker
  flutter_map_location_picker: ^0.0.4
```

### How To Use

Add the following imports to your Dart code

```dart
import 'package:flutter_map_location_picker/flutter_map_location_picker.dart';
```
You can now add a `MapLocationPicker` widget to your widget tree. You can process the picked location by using the `onPicked` parameter.

```dart
MapLocationPicker(onPicked: (result){
    // you can get the location result here
    print(result.completeAddress);
    print(result.latitude);
    print(result.longitude);
})
```





