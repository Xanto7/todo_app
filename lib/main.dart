import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/database_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final TextEditingController itemTextController = TextEditingController();
  final TextEditingController updateController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  String searchString = "";
  int? selectedId;
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        searchString = searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('ToDo App', textAlign: TextAlign.center),
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: TextField(
                      controller: itemTextController,
                      cursorColor: Colors.black,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.5),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.circular(30)),
                        hintText: 'Enter task',
                        hintStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                        onPressed: () async {
                          await DatabaseManager.instance.insertItem(Item(
                              title: itemTextController.text,
                              done: false,
                              created_at: DateTime.now(),
                              updated_at: DateTime.now()));
                          setState(() {
                            itemTextController.clear();
                          });
                        },
                        child: const Text('Save')),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Search',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            FutureBuilder<List<Item>>(
                future: DatabaseManager.instance.getAllItems(),
                builder:
                    (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  List<Item> filteredList = snapshot.data!
                      .where((item) =>
                          item.title.toLowerCase().contains(searchString))
                      .toList();

                  return filteredList.isEmpty
                      ? Center(child: Text('No items found'))
                      : ListView(
                          shrinkWrap: true,
                          children: filteredList.map((item) {
                            return ListTile(
                              leading: Checkbox(
                                value: item.done,
                                onChanged: (bool? value) {
                                  DatabaseManager.instance.updateItem(Item(
                                      id: item.id,
                                      title: item.title,
                                      updated_at: DateTime.now(),
                                      done: value!));
                                  setState(() {});
                                },
                                activeColor: Colors.blue,
                                checkColor: Colors.white,
                              ),
                              trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await DatabaseManager.instance
                                        .deleteItem(item.id!);
                                    setState(() {});
                                  }),
                              title: Text(item.title),
                              subtitle: Text(
                                  "Last update: ${item.updated_at != null ? formatter.format(item.updated_at!) : 'Not updated yet'}"),
                              onTap: () {
                                updateController.text = item.title;
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Edit task'),
                                        content: TextField(
                                          controller: updateController,
                                          decoration: InputDecoration(
                                              hintText: "Enter new task name"),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('Save'),
                                            onPressed: () {
                                              DatabaseManager.instance
                                                  .updateItem(Item(
                                                      id: item.id,
                                                      title:
                                                          updateController.text,
                                                      updated_at:
                                                          DateTime.now(),
                                                      done: item.done));
                                              setState(() {});
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          )
                                        ],
                                      );
                                    });
                              },
                            );
                          }).toList(),
                        );
                }),
          ],
        ),
      ),
    );
  }
}
