import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/database_manager.dart';

class ItemList extends StatefulWidget {
  final TextEditingController updateController;
  final String searchString;

  const ItemList(
      {Key? key, required this.updateController, required this.searchString})
      : super(key: key);

  @override
  _ItemListState createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Item>>(
      future: DatabaseManager.instance.getAllItems(),
      builder: (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        List<Item> filteredList = snapshot.data!
            .where((item) =>
                item.title.toLowerCase().contains(widget.searchString))
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
                          await DatabaseManager.instance.deleteItem(item.id!);
                          setState(() {});
                        }),
                    title: Text(item.title),
                    subtitle: Text(
                        "Last update: ${item.updated_at != null ? formatter.format(item.updated_at!) : 'Not updated yet'}"),
                    onTap: () {
                      widget.updateController.text = item.title;
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Edit task'),
                              content: TextField(
                                controller: widget.updateController,
                                decoration: InputDecoration(
                                    hintText: "Enter new task name"),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Save'),
                                  onPressed: () {
                                    DatabaseManager.instance.updateItem(Item(
                                        id: item.id,
                                        title: widget.updateController.text,
                                        updated_at: DateTime.now(),
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
      },
    );
  }
}
