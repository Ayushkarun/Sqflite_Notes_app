import 'package:flutter/material.dart';
import 'package:sql_db_21/Db_helper/db_helper.dart';
import 'package:sql_db_21/user_model/user_model.dart';

/// The main screen widget that displays and manages CRUD operations
class Homes extends StatefulWidget {
  const Homes({super.key});

  @override
  State<Homes> createState() => _HomesState();
}

class _HomesState extends State<Homes> {
  // Controllers for the input fields
  final titleController = TextEditingController();       // Controls title input
  final descController = TextEditingController();       // Controls description input
  final updateTitleController = TextEditingController(); // Controls title in update dialog
  final updateDescController = TextEditingController();  // Controls description in update dialog

  List<UserModel> items = [];  // Stores the list of items from database
  final DbHelper dbHelper = DbHelper();  // Instance of database helper

  @override
  void initState() {
    super.initState();
    _refreshItems();  // Load data when widget initializes
  }

  /// Fetches all items from database and updates the UI
  Future<void> _refreshItems() async {
    final data = await dbHelper.readData();  // Get raw data from database
    setState(() {
      // Convert each Map item to UserModel and update the list
      items = data.map((item) => UserModel.fromMap(item)).toList();
    });
  }

  /// Adds a new item to the database
  Future<void> _addItem() async {
    // Validate inputs
    if (titleController.text.isEmpty || descController.text.isEmpty) return;
    
    // Insert new item
    await dbHelper.createData(
      UserModel(
        title: titleController.text,
        description: descController.text,
      ),
    );
    
    // Refresh list and clear inputs
    _refreshItems();
    titleController.clear();
    descController.clear();
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item added successfully')),
    );
  }

  /// Updates an existing item
  Future<void> _updateItem(int id) async {
    await dbHelper.updateData(
      UserModel(
        id: id,
        title: updateTitleController.text,
        description: updateDescController.text,
      ),
    );
    
    // Refresh list and clear inputs
    _refreshItems();
    updateTitleController.clear();
    updateDescController.clear();
    
    // Close dialog and show success message
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item updated successfully')),
    );
  }

  /// Deletes an item by its ID
  Future<void> _deleteItem(int id) async {
    await dbHelper.deleteData(id);
    _refreshItems();  // Refresh list after deletion
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item deleted successfully')),
    );
  }

  /// Shows the update dialog with pre-filled values
  void _showUpdateDialog(UserModel item) {
    // Pre-fill the dialog fields with current values
    updateTitleController.text = item.title;
    updateDescController.text = item.description;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: updateTitleController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: updateDescController,
              decoration: const InputDecoration(hintText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _updateItem(item.id!),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Clean up all controllers when widget is disposed
    titleController.dispose();
    descController.dispose();
    updateTitleController.dispose();
    updateDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite CRUD'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Title input field
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Enter Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            
            // Description input field
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                hintText: 'Enter Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            
            // Add button
            ElevatedButton(
              onPressed: _addItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('ADD'),
            ),
            const SizedBox(height: 20),
            const Divider(),
            
            // List of items
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('No data available'))  // Empty state
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          title: Text(item.title),
                          subtitle: Text(item.description),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Edit button
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showUpdateDialog(item),
                              ),
                              // Delete button
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteItem(item.id!),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}