import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as crop;
import 'dart:math';

File? targetImage;
int? targetWidth;
int? targetHeight;
crop.Image? convertedImage;

/*
 * 25200개의 예측 클래스의 값중에서 가장 높은 값들만 가져오는 메서드
 */
List<int> classFilter(List<List<double>> classData) {
  List<int> classes = [];

  for (var i=0;i<classData.length;i++) {
    classes.add(classData[i].indexOf(classData[i].reduce(max)));
  }

  return classes;
}

/*
 * 1차원 형태로 온 output 배열을 적절히 처리하기 위해
 * 2차원 배열로 변환해주는 메서드
 * [width * height * channel] => [1, 25200 (640*640 이미지 기준), (클래스개수 + 좌표4개 + 정확도]
 */
List<List> convert2dArr(List<double> array) {
  List<List<double>> boxes = [];
  List<double> scores = [];
  List<List<double>> classes = [];

  for (var i=0;i<25200;i++) {
    var tmpList = array.sublist(i*155, (i+1)*155);
    boxes.add(tmpList.sublist(0, 4));
    scores.add(tmpList.sublist(4, 5)[0]);
    classes.add(tmpList.sublist(5, 155));
  }

  return [boxes, scores, classes];
}

/*
 * Tensorflow에서 사용하는 이미지 배열을
 * Pytorch에서 사용하는 이미지 배열의 형태로 변환하는 메서드
 * [width, height, 3] => [3, width, height]
 */
List<int> convertTorchArr(List<int> arr) {
  List<int> outputArr = [];

  for (var i=0;i<arr.length;i+=3) {
    outputArr.add(arr[i]);
  }

  for (var i=1;i<arr.length;i+=3) {
    outputArr.add(arr[i]);
  }

  for (var i=2;i<arr.length;i+=3) {
    outputArr.add(arr[i]);
  }

  return outputArr;
}

/*
 * 각 역할을 하는 함수들을 이용해 yolo 모델이
 * 보내주는 배열을 변환하기 쉽게 변경해주는 메서드
 */
List<List> convertYoloV5type(List<double> outputData) {
  List<List> arr2D = convert2dArr(outputData);

  List<int> classFiltered = classFilter(arr2D[2].cast<List<double>>());

  return [arr2D[0], arr2D[1], classFiltered];
}

/*
 * yolo 모델이 받아야하는 float32 형태의 배열로 바뀌주는 메서드
 * int 배열 => float32 배열
 */
List<double> convertFP32TypeArr(arr) {
  List<double> doubleList = [];
  for (var i=0;i<arr.length;i++) {
    doubleList.add(arr[i]/255.0);
  }

  return doubleList;
}

/*
 * 박스를 그리기위한 각 예측 결과 객체 배열을 만드는 메서드
 * (이때 픽셀 단위가 아닌 퍼센트 단위로 하여 사이즈가 변경되도 대처되도록 저장)
 */
List convertOutput(predict) {
  List boxData = [];

  var output = convertYoloV5type(predict.cast<double>());

  for (var i=0;i<output[1].length;i++) {
    if (output[1][i] >= 0.25) {
      double x = output[0][i][0] / convertedImage!.width;
      double y = output[0][i][1] / convertedImage!.height;
      double w = output[0][i][2] / convertedImage!.width;
      double h = output[0][i][3] / convertedImage!.height;

      boxData.add({
        'class': output[2][i].toString(),
        'x': x - (w / 2),
        'y': y - (h / 2),
        'w': w,
        'h': h,
      });
    }
  }

  return iouUnit(boxData);
}

/*
 * 겹치는 예측 박스들을 제거하기 위한 iou 계산 및 처리 메서드
 */
List iouUnit(List arr) {
  List drawIndex = [];
  List<int> deleteIndex = [];

  for (var i=0;i<arr.length;i++) {
    if (deleteIndex.indexOf(i) != -1) continue;

    List<double> box1 = [arr[i]['x']*targetWidth, arr[i]['y']*targetHeight, (arr[i]['w'] + arr[i]['x'])*targetWidth, (arr[i]['h'] + arr[i]['y'])*targetHeight];

    double box1_area = (box1[2] - box1[0] + 1) * (box1[3] - box1[1] + 1);

    for (var j=i;j<arr.length;j++) {
      if (deleteIndex.indexOf(j) != -1 || i == j) continue;

      List<double> box2 = [arr[j]['x']*targetWidth, arr[j]['y']*targetHeight, (arr[j]['w'] + arr[j]['x'])*targetWidth, (arr[j]['h'] + arr[j]['y'])*targetHeight];
      double box2_area = (box2[2] - box2[0] + 1) * (box2[3] - box2[1] + 1);

      double x1 = box1[0] > box2[0] ? box1[0] : box2[0];
      double y1 = box1[1] > box2[1] ? box1[1] : box2[1];
      double x2 = box1[2] < box2[2] ? box1[2] : box2[2];
      double y2 = box1[3] < box2[3] ? box1[3] : box2[3];

      double w = 0 > (x2 - x1 + 1) ? 0 : (x2 - x1 + 1);
      double h = 0 > (y2 - y1 + 1) ? 0 : (y2 - y1 + 1);

      double inter = w * h;

      double iou = inter / (box1_area + box2_area - inter);

      if (iou > 0.45 && arr[i]['class'] == arr[j]['class']) deleteIndex.add(j);
    }
  }

  for (var i=0;i<arr.length;i++) {
    if (deleteIndex.indexOf(i) == -1) drawIndex.add(arr[i]);
  }

  return drawIndex;
}

void setTargetImage(image) async {
  targetImage = image;

  var bytes = targetImage!.readAsBytesSync().buffer.asUint8List();
  crop.Image? targetBytes = await crop.decodeImage(bytes);
  targetWidth = targetBytes!.width;
  targetHeight = targetBytes.height;
}

Future<List<double>> getImageBytes() async {
  var bytes = targetImage!.readAsBytesSync().buffer.asUint8List();
  crop.Image? image = await crop.decodeImage(bytes);

  var resizeImage = crop.copyResize(image!, width: 640, height: 640);
  convertedImage = resizeImage;

  var decodeBytes = resizeImage.getBytes(format: crop.Format.rgb);
  var torchTypeArr = convertTorchArr(decodeBytes);
  var FP32TypeArr = convertFP32TypeArr(torchTypeArr);

  return Float32List.fromList(FP32TypeArr);
}

dynamic getRequestBody(data) {
  return jsonEncode({
    "inputs": [
      {
        "name": "images",
        "datatype": "FP32",
        "shape": [1, 3, convertedImage!.height, convertedImage!.width],
        "data": data
      }
    ],

    "parameters":{
      "binary_data_output": false
    }
  });
}