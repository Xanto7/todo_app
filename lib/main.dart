import 'package:flutter/material.dart';
import 'package:todo_app/database_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final TextEditingController itemTextController = TextEditingController();
  int? selectedId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('ToDo App'),
        ),
        body: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: TextField(
                    controller: itemTextController,
                    cursorColor: Colors.black,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.blueAccent,
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(50)),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                      onPressed: () async {
                        await DatabaseManager.instance.insertItem(
                            Item(title: itemTextController.text, done: false));
                        setState(() {
                          itemTextController.clear();
                        });
                      },
                      child: const Text('Save')),
                ),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                      onPressed: () async {
                        if (selectedId != null) {
                          await DatabaseManager.instance
                              .deleteItem(selectedId!);
                        }
                        setState(() {
                          itemTextController.clear();
                        });
                      },
                      child: const Text('Del')),
                ),
              ],
            ),
            FutureBuilder<List<Item>>(
                future: DatabaseManager.instance.getAllItems(),
                builder:
                    (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: Text('Loading...'));
                  }
                  return snapshot.data!.isEmpty
                      ? Center(child: Text('No items found'))
                      : ListView(
                          shrinkWrap: true,
                          children: snapshot.data!.map((item) {
                            return Center(
                              child: ListTile(
                                leading: Checkbox(
                                  value: item.done,
                                  onChanged: (bool? value) {
                                    DatabaseManager.instance.updateItem(Item(
                                        id: item.id,
                                        title: item.title,
                                        done: value!));
                                    setState(() {});
                                  },
                                  activeColor: Colors.white,
                                  checkColor: Colors.blue,
                                ),
                                title: Text(item.title),
                                onTap: () {
                                  setState(() {
                                    selectedId = item.id;
                                  });
                                },
                              ),
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
