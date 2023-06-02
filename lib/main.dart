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
                                        updated_at: DateTime.now(),
                                        done: value!));
                                    setState(() {});
                                  },
                                  activeColor: Colors.white,
                                  checkColor: Colors.blue,
                                ),
                                trailing: ElevatedButton(
                                    onPressed: () async {
                                      await DatabaseManager.instance
                                          .deleteItem(item.id!);
                                      setState(() {});
                                    },
                                    child: const Text('Del')),
                                title: Row(children: [
                                  Expanded(flex: 3, child: Text(item.title)),
                                  Expanded(
                                      flex: 2,
                                      child: Text(item.created_at.toString())),
                                  Expanded(
                                      flex: 2,
                                      child: Text(item.updated_at.toString())),
                                ]),
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
