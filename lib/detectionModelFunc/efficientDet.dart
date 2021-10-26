import 'dart:io';
import 'dart:convert';
import 'package:image/image.dart' as crop;

File? targetImage;
crop.Image? convertedImage;

void setTargetImage(image) {
  targetImage = image;
}

List convertOutput(predict) {
  List boxData = [];

  for (var i=0;i<((predict.length)/7).toInt();i++) {
    var predictArr = predict.sublist(0 + (i * 7), 7 + (i * 7));
    if (predictArr[5] < 0.3) break;
    boxData.add({
      'class': predictArr[6].toInt(),
      'x': predictArr[2] / convertedImage!.width,
      'y': predictArr[1] / convertedImage!.height,
      'w': (predictArr[4] - predictArr[2]) / convertedImage!.width,
      'h': (predictArr[3] - predictArr[1]) / convertedImage!.height,
    });
  }

  return boxData;
}

Future<List<int>> getImageBytes() async {
  var bytes = targetImage!.readAsBytesSync().buffer.asUint8List();
  crop.Image? image = await crop.decodeImage(bytes);

  var resizeImage = crop.copyResize(image!, width: 1280, height: 1280);
  convertedImage = resizeImage;

  var decodeBytes = resizeImage.getBytes(format: crop.Format.rgb);

  return decodeBytes;
}

dynamic getRequestBody(data) {
  return jsonEncode({
    "inputs": [
      {
        "name": "image_arrays:0",
        "datatype": "UINT8",
        "shape": [1, convertedImage!.height, convertedImage!.width, 3],
        "data": data
      }
    ],

    "parameters":{
      "binary_data_output": false
    }
  });
}