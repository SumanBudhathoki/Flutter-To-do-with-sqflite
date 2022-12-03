import 'package:flutter/material.dart';
import 'package:note/screens/note_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final _nameController = TextEditingController();
  static const String KEYNAME = 'name';
  String nameValue = 'No name';

  @override
  void initState() {
    super.initState();
    getValue();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Image(
                  image: AssetImage('assets/images/Hello.gif'),
                  fit: BoxFit.fill,
                ),
              ),
              Text(
                'What can I call you?',
                style: Theme.of(context).textTheme.headline6?.copyWith(
                      fontSize: 20,
                    ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 70, right: 70),
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  )),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: 170,
                height: 50,
                child: ElevatedButton(
                    onPressed: () async {
                      String name = _nameController.text.toString();
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString(KEYNAME, name);
                      prefs.setBool('showHome', true);

                      // ignore: use_build_context_synchronously
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return const NoteList();
                      }));
                    },
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  void getValue() async {
    var prefs = await SharedPreferences.getInstance();
    var getName = prefs.getString(KEYNAME)!;

    setState(() {
      nameValue = getName;
    });
  }
}
