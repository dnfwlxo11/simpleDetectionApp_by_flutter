import 'package:mysql1/mysql1.dart';

class Database {
  MySqlConnection? conn;

  Database._privateConstructor() {}
  static final Database instance = Database._privateConstructor();

  var mysqlSetting = ConnectionSettings(
      host: 'namuintell.iptime.org',
      port: 16003,
      user: 'root',
      password: 'root',
      db: 'detections'
  );

  Future<void> connection() async {
    this.conn = await MySqlConnection.connect(mysqlSetting);
  }

  dynamic selectImagePosition(path) async {
    await this.connection();
    var result = await this.conn!.query('SELECT position FROM images where img_path = ?', ['${path}']);
    await this.conn != null ? this.conn!.close() : this.conn = null;

    return result.toList();
  }

  dynamic insertImages(path, data) async {
    await this.connection();
    var results = await this.conn!.query('INSERT INTO images (img_path, position) VALUES (?, ?)', ['${path}', '${data}']);
    await this.conn != null ? this.conn!.close() : this.conn = null;

    return results;
  }
}

String getEfficientURL() {
  return 'http://namuintell.iptime.org:16000/v2/models/detectionModel/versions/1/infer';
}

String getYoloURL() {
  return 'http://namuintell.iptime.org:16000/v2/models/ezfit/versions/1/infer';
}