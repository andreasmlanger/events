import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// PostgreSQL Connection
Future<Connection> connectToDatabase() async {
  await dotenv.load();
  String sqlName = dotenv.env['SQL_NAME']!;
  String sqlPassword = dotenv.env['SQL_PASSWORD']!;
  String sqlHost = dotenv.env['SQL_HOST']!;

  final conn = await Connection.open(Endpoint(
    host: sqlHost,
    database: sqlName,
    username: sqlName,
    password: sqlPassword,
  ));
  return conn;
}

void executeSqlQuery(int id, String q) async {
  Connection conn = await connectToDatabase();
  await conn.execute(q, parameters: {'id': id});
  await conn.close();
}
