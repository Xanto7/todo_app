import 'package:flutter/material.dart';
import 'package:todo_app/item_input_field.dart';
import 'package:todo_app/item_list.dart';

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

  void refreshItemList() {
    setState(() {});
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
              child: ItemInputField(
                itemTextController: itemTextController,
                refreshItemList: refreshItemList,
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
            ItemList(
              updateController: updateController,
              searchString: searchString,
            ),
          ],
        ),
      ),
    );
  }
}
