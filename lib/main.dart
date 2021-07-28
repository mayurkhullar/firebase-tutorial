import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final db = FirebaseFirestore.instance;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late String tasks;

  void showdialog(bool isUpdate, DocumentSnapshot? ds) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: isUpdate ? Text("Edit Data") : Text("Add Data"),
          content: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.always,
              child: TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "Task"),
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Can't be empty";
                  } else
                    return null;
                },
                onChanged: (val) {
                  tasks = val;
                },
              )),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (isUpdate) {
                  db
                      .collection('tasks')
                      .doc(ds!.id)
                      .update({'task': tasks, 'time': DateTime.now()});
                } else {
                  db
                      .collection("tasks")
                      .add({"task": tasks, 'time': DateTime.now()});
                }
                Navigator.pop(context);
              },
              child: Text("Submit"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showdialog(false, null),
        child: Icon(Icons.add),
      ),
      appBar: AppBar(title: Text("Sample App"), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection('tasks').orderBy('time').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data!.docs[index];
                return ListTile(
                  title: Text(ds['task']),
                  leading: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      showdialog(true, ds);
                    },
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      db.collection('tasks').doc(ds.id).delete();
                    },
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text("Some error occurred");
          } else
            return CircularProgressIndicator();
        },
      ),
    );
  }
}
