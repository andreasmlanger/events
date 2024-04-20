import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// PostgreSQL Connection
Future<Connection> connectToDatabase() async {
  await dotenv.load();
  String sqlDBName = dotenv.env['POSTGRESQL_DBNAME']!;
  String sqlHost = dotenv.env['POSTGRESQL_HOST']!;
  int sqlPort = int.parse(dotenv.env['POSTGRESQL_PORT']!);
  String sqlUser = dotenv.env['POSTGRESQL_USER']!;
  String sqlPassword = dotenv.env['POSTGRESQL_PASSWORD']!;

  final conn = await Connection.open(Endpoint(
    database: sqlDBName,
    host: sqlHost,
    port: sqlPort,
    username: sqlUser,
    password: sqlPassword,
  ));
  return conn;
}

void executeSqlQuery(int id, String q) async {
  Connection conn = await connectToDatabase();
  await conn.execute(q, parameters: {'id': id});
  await conn.close();
}
