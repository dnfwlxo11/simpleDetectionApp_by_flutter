import 'package:mysql1/mysql1.dart';

/*
 * sample code
 * Fill in your settings!!!
 */

class Database {
  MySqlConnection? conn;

  Database._privateConstructor() {}
  static final Database instance = Database._privateConstructor();

  var mysqlSetting = ConnectionSettings(
      host: 'user url',
      port: {{user port (int type)}},
      user: 'user db id',
      password: 'user db pass',
      db: 'user db name'
  );

  Future<void> connection() async {
    this.conn = await MySqlConnection.connect(mysqlSetting);
  }

  // example
  dynamic selectData(dataId) async {
    await this.connection();
    var result = await this.conn!.query('SELECT * FROM data where dataId = ?', ['${dataId}']);
    await this.conn != null ? this.conn!.close() : this.conn = null;

    return result;
  }
}

String getURL() {
  return 'http://{{user url}}/{{api}}';
}
