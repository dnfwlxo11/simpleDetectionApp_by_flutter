// import 'dart:convert';
//
// import 'package:mysql1/mysql1.dart';
//
// String initDb(conn) async {
//   var mysqlSetting = new ConnectionSettings(
//       host: 'namuintell.iptime.org',
//       port: 16003,
//       user: 'root',
//       password: 'root',
//       db: 'detections'
//   );
//
//   conn = await MySqlConnection.connect(mysqlSetting);
//   return jsonDecode(getDetectBox(conn));
// }
//
// Future<String> getDetectBox(conn) async {
//   var results = (await conn.query('SELECT position FROM images where img_path = ?', ['${_image!.path}'])).toList();
//   return results[0]['position'].toString();
// }