import 'package:flutter/material.dart';
import 'package:todo_app/database_manager.dart';

class ItemInputField extends StatefulWidget {
  final TextEditingController itemTextController;

  final Function refreshItemList;

  const ItemInputField(
      {Key? key,
      required this.itemTextController,
      required this.refreshItemList})
      : super(key: key);

  @override
  _ItemInputFieldState createState() => _ItemInputFieldState();
}

class _ItemInputFieldState extends State<ItemInputField> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 4,
          child: TextField(
            controller: widget.itemTextController,
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
                    title: widget.itemTextController.text,
                    done: false,
                    created_at: DateTime.now(),
                    updated_at: DateTime.now()));
                widget.itemTextController.clear();
                widget.refreshItemList();
              },
              child: const Text('Save')),
        ),
      ],
    );
  }
}
