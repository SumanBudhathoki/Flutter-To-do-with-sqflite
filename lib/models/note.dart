class Note {
  int? _id;
  late String _title;
  late String? _description;
  late String _date;
  late int _priority;

  // Constructor
  Note(this._title, this._date, this._priority, [this._description]);

  Note.withId(this._id, this._title, this._priority, this._date,
      [this._description]);

  int? get id => _id;

  String get title => _title;

  String? get description => _description;

  String get date => _date;

  int get priority => _priority;

  set title(String newTitle) {
    _title = newTitle;
  }

  set description(String? newdesc) {
    _description = newdesc;
  }

  set priority(int newPriority) {
    if (newPriority >= 1 && newPriority <= 2) {
      _priority = newPriority;
    }
  }

  set date(String newDate) {
    _date = newDate;
  }

  // Function to convert note object to Map Object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['title'] = _title;
    map['description'] = _description;
    map['priority'] = _priority;
    map['date'] = _date;
    return map;
  }

  // Function to convert note object from map object
  Note.fromMapObject(Map<String, dynamic> map) {
    _title = map['title'];
    _description = map['description'];
    _priority = map['priority'];
    _date = map['date'];
    _id = map['id'];
  }
}
