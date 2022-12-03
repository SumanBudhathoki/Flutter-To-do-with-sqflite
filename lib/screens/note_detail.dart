import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note/models/note.dart';
import 'package:note/utils/database_helper.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  const NoteDetail({Key? key, required this.appBarTitle, required this.note})
      : super(key: key);

  @override
  State<NoteDetail> createState() => _NoteDetailState();
}

class _NoteDetailState extends State<NoteDetail> {
  static final _priorities = ['High', 'Low'];

  late DateTime date;

  DatabaseHelper helper = DatabaseHelper();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.titleMedium!;
    titleController.text = widget.note.title;
    descriptionController.text = widget.note.description!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.appBarTitle,
          style: Theme.of(context)
              .textTheme
              .headline6
              ?.copyWith(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 15.0,
          left: 10.0,
          right: 10.0,
        ),
        child: ListView(children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Priority:', style: Theme.of(context).textTheme.headline6),
              const SizedBox(
                width: 200,
              ),
              Expanded(
                child: ListTile(
                  title: DropdownButton(
                    items: _priorities.map((String dropDownStringItem) {
                      return DropdownMenuItem<String>(
                        value: dropDownStringItem,
                        child: Text(dropDownStringItem),
                      );
                    }).toList(),
                    style: textStyle,
                    value: getPriorityAsString(widget.note.priority),
                    onChanged: (valueSelectedByUser) {
                      setState(() {
                        updatePriorityAsInt(valueSelectedByUser.toString());
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          // Second Element
          Padding(
            padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
            child: TextField(
              controller: titleController,
              style: textStyle,
              decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: textStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  )),
              onChanged: ((value) {
                updateTitle();
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
            child: TextField(
              controller: descriptionController,
              style: textStyle,
              decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: textStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  )),
              onChanged: ((value) {
                updateDescription();
              }),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
          //   child: TextField(
          //     controller: dateController,
          //     style: textStyle,
          //     decoration: InputDecoration(
          //         labelText: 'Add a reminder',
          //         labelStyle: textStyle,
          //         border: OutlineInputBorder(
          //           borderRadius: BorderRadius.circular(5.0),
          //         )),
          //     onTap: () {
          //       pickDate(context);
          //     },
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _save();
                        });
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        textScaleFactor: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _delete();
                        });
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.white),
                        textScaleFactor: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }

// Convert the String priority in the form of integer before saving it to Database;
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        widget.note.priority = 1;
        break;
      case 'Low':
        widget.note.priority = 2;
        break;
    }
  }

  // COnvert int priority to String priority and display it to user
  String getPriorityAsString(int value) {
    late String priority;
    switch (value) {
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }

  // Update title of Note object
  void updateTitle() {
    widget.note.title = titleController.text;
  }

  // Update desc field of note object
  void updateDescription() {
    widget.note.description = descriptionController.text;
  }

  // Save data to database
  void _save() async {
    moveToLastScreen();

    widget.note.date = DateFormat.jm().format(DateTime.now());
    int result;
    if (widget.note.id != null) {
      // Case 1 : Update operation
      result = await helper.updateNote(widget.note);
      print('Result = $result');
      // result = await helper.insertNote(widget.note);
      // print('Result is :$result');
    } else {
      // Case 2: Insert Operation
      result = await helper.insertNote(widget.note);
      print('Result is :$result');
    }
    if (result != 0) {
      // Success
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {
      // Failure
      _showAlertDialog('Status', 'Problem Saving note');
    }
  }

  void _delete() async {
    moveToLastScreen();
    // Case 1: if user is trying yo delete new note: he has come to the detail page
    // by pressing the fab of notelist page
    if (widget.note == null) {
      _showAlertDialog('Status', 'No note was deleted');
      return;
    }

    // Case 2: user is trying to delete the old note that already has a valid Id
    int result = await helper.deleteNote(widget.note.id!);
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured while deleting note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  Future pickDateTime(BuildContext context) async {
    final date = await pickDate(context);
  }

  Future pickDate(BuildContext context) async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(
        DateTime.now().year - 5,
      ),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (newDate == null) return;

    setState(() {
      date = newDate;
    });
  }
}
