// Import required packages
import 'package:path/path.dart';       // For path joining
import 'package:sqflite/sqflite.dart'; // For SQLite database operations
import 'package:sql_db_21/user_model/user_model.dart'; // For UserModel

// Database table and column names (constants)
final String tableName = 'Data';           // Table name in database
final String columnId = 'id';              // Column for unique ID
final String columnTitle = 'title';        // Column for item title
final String columnDescription = 'description'; // Column for item description

/// Database helper class that manages all SQLite operations.
/// Uses singleton pattern to ensure only one database instance exists.
class DbHelper {
  // Singleton instance (private constructor)
  static final DbHelper _instance = DbHelper._internal();
  
  // Public factory constructor to access the instance
  factory DbHelper() => _instance;
  
  // Database instance (nullable until initialized)
  static Database? _database;

  // Private internal constructor for singleton pattern
  DbHelper._internal();

  /// Getter for database instance.
  /// Initializes the database if it hasn't been already.
  Future<Database> get database async {
    if (_database != null) return _database!; // Return if already initialized
    _database = await _initDatabase();        // Initialize if null
    return _database!;
  }

  /// Initializes the database by:
  /// 1. Getting the database path
  /// 2. Opening/Creating the database file
  Future<Database> _initDatabase() async {
    // Get the default databases path (platform-specific)
    final dbPath = await getDatabasesPath();
    // Join with our database filename
    final path = join(dbPath, 'data.db');

    // Open (or create) the database
    return await openDatabase(
      path,
      version: 1, // Database version (for migrations)
      onCreate: _onCreate, // Called when database is first created
    );
  }

  /// Creates the database schema when the database is first created.
  /// Executes SQL to create the table with columns.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT, // Auto-incrementing ID
        $columnTitle TEXT NOT NULL,                 // Required title field
        $columnDescription TEXT NOT NULL            // Required description field
      )
    ''');
  }

  /// Inserts a new UserModel into the database.
  /// Returns the ID of the newly inserted row.
  Future<int> createData(UserModel user) async {
    final db = await database;
    return await db.insert(
      tableName,         // Table to insert into
      user.toMap(),      // Convert UserModel to Map
    );
  }

  /// Retrieves all records from the database.
  /// Returns a List of Maps (each Map represents a row).
  Future<List<Map<String, dynamic>>> readData() async {
    final db = await database;
    return await db.query(tableName); // Query all rows
  }

  /// Updates an existing UserModel in the database.
  /// Returns the number of affected rows (should be 1).
  Future<int> updateData(UserModel user) async {
    final db = await database;
    return await db.update(
      tableName,         // Table to update
      user.toMap(),       // New values
      where: '$columnId = ?', // Where clause (update by ID)
      whereArgs: [user.id],   // ID value for where clause
    );
  }

  /// Deletes a record by its ID.
  /// Returns the number of affected rows (should be 1).
  Future<int> deleteData(int id) async {
    final db = await database;
    return await db.delete(
      tableName,         // Table to delete from
      where: '$columnId = ?', // Where clause (delete by ID)
      whereArgs: [id],        // ID value for where clause
    );
  }

  /// Closes the database connection.
  /// Important to call when the app is terminated.
  Future close() async {
    final db = await database;
    db.close();
  }
}