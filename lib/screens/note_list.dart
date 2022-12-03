import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:note/screens/note_detail.dart';
import 'package:note/screens/onboarding.dart';
import 'package:note/utils/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../models/note.dart';

class NoteList extends StatefulWidget {
  const NoteList({Key? key}) : super(key: key);

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  List<String> quotes = [
    ''' “Smile in the mirror. Do that every morning and you'll start to see a big difference in your life.” — Yoko Ono''',
    ''' "It's not enough to be busy, so are the ants. The question is, what are we busy about?" - Henry David Thoreau''',
    ''' "The key is in not spending time, but in investing it." - Stephen R. Covey''',
    ''' "Time is more valuable than money. You can get more money, but you cannot get more time." - Jim Rohn ''',
    ''' "The shorter way to do many things is to only do one thing at a time." - Mozart''',
    ''' "Yesterday is gone. Tomorrow has not yet come. We have only today. Let us begin." - Mother Teresa''',
    ''' "Give me six hours to chop down a tree and I will spend the first four sharpening the axe." - Abraham Lincoln''',
    ''' "Most of us spend too much time on what is urgent, and not enough time on what is important." - Steven Covey''',
    ''' "Your future is created by what you do today, not tomorrow." - Anonymous''',
    ''' "The bad news is time flies. The good news is you're the pilot." - Michael Altshuler''',
    ''' "The best thing about the future is that it comes one day at a time." - Abraham Lincoln''',
  ];

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note>? noteList;
  String name = '';
  int randNum = 0;
  int count = 0;

  @override
  void initState() {
    super.initState();
    getUserName();
    getGreetings();
    var rand = getRandomNumber();
    randNum = rand;
  }

  @override
  Widget build(BuildContext context) {
    var dateTime = DateTime.now();
    var time = DateFormat('jm').format(DateTime.now());

    if (noteList == null) {
      noteList = <Note>[];
      updateListView();
    }
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            getName(),
            count > 0 ? Expanded(child: getNoteListView()) : ifNoteEmpty(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            navigateToDetail(Note('', '', 2, ''), 'Add Note');
          },
          tooltip: 'Add Note',
          backgroundColor: const Color(0xFF00BCD4),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget getName() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 25.0, right: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getGreetings(),
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFF00BCD4),
                  ),
                ),
                Text(
                  DateFormat('jm').format(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const Onboarding();
                    }));
                  },
                  child: Text(
                    name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Text(DateFormat('E, MMM d').format(DateTime.now())),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              color: const Color(0xFF00BCD4),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  quotes[randNum],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            'To-Do\'s',
            style:
                Theme.of(context).textTheme.headline6?.copyWith(fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget getNoteListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.headline6!;

    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: ListView.builder(
          itemCount: count,
          itemBuilder: (BuildContext context, int position) {
            return Padding(
              padding: const EdgeInsets.only(
                top: 5.0,
                left: 20.0,
                right: 20.0,
                bottom: 5.0,
              ),
              child: InkWell(
                onTap: () {
                  navigateToDetail(noteList![position], 'Edit Note');
                },
                child: Card(
                  color: const Color(0xFFE3E2E2),
                  elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          noteList![position].title,
                          style: titleStyle.copyWith(
                              color: const Color(0xFF00BCD4), fontSize: 14),
                        ),
                        trailing: Text(
                          noteList![position].date,
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          noteList![position].description!,
                          style: const TextStyle(
                            fontSize: 12,
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor:
                              getPriorityColor(noteList![position].priority),
                          child: getPriorityIcon(
                            noteList![position].priority,
                          ),
                        ),
                        trailing: GestureDetector(
                          onTap: () {
                            _delete(context, noteList![position]);
                          },
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 25,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  // Return the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.yellow;
      default:
        return Colors.yellow;
    }
  }

  // Return the priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return const Icon(
          Icons.notifications_active_outlined,
          color: Colors.white,
          size: 20,
        );
      case 2:
        return const Icon(
          Icons.notifications_none_rounded,
          size: 20,
        );
      default:
        return const Icon(
          Icons.notifications_none_rounded,
          size: 20,
        );
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id!);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(
        note: note,
        appBarTitle: title,
      );
    }));
    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          count = noteList.length;
        });
      });
    });
  }

  void getUserName() async {
    var prefs = await SharedPreferences.getInstance();
    name = prefs.getString('name').toString();
  }

  String getGreetings() {
    DateTime timeNow = DateTime.now();
    var hourNow = timeNow.hour;
    if (hourNow >= 5 && hourNow <= 11) {
      return 'GoodMorning';
    } else if (hourNow >= 12 && hourNow <= 16) {
      return 'GoodAfternoon';
    } else if (hourNow >= 17 && hourNow <= 20) {
      return 'GoodEvening';
    }
    return 'GoodNight';
  }

  int getRandomNumber() {
    var num = Random().nextInt(11);
    return num;
  }

  Widget ifNoteEmpty() {
    // return Image(image: AssetImage('assets/images/logo.png'));
    return Padding(
      padding: const EdgeInsets.only(top: 80, bottom: 150.0),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/images/empty.svg',
            width: 300,
          ),
          const Text("No to-do in the list"),
        ],
      ),
    );
  }
}
