import 'package:flutter/material.dart';
import 'add_notes_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final logger = Logger();
  /*
  //final List<String> dummyNotes = [
    'Einkaufsliste schreiben',
    'Projektbesprechung am Montag',
    'Flutter ausprobieren'
  ];  // Platzhalter-Daten, später ersetzen mit Cloud Firestore
  */

  void logout() {
    //print("Aktuelle UID: ${FirebaseAuth.instance.currentUser?.uid}");
    HomeScreen.logger.i(
      "Aktuelle UID: ${FirebaseAuth.instance.currentUser?.uid}",
    );
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'Unbekannt';
    //final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("My Notes"),
        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Welcome, $userEmail',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('notes')
                      .where(
                        'userId',
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                      )
                      .orderBy('timestamp', descending: true)
                      .snapshots(),

              builder: (context, snapshot) {
                // Ladeanzeige, wenn Daten geladen werden
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                // Leerer Zustand
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No Notes there'));
                }

                // Zugriff auf die Dokumente aus Firestore
                final notes = snapshot.data!.docs;
                // Liste aller Notizen anzeigen
                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final noteId = note.id;
                    final noteData = note.data() as Map<String, dynamic>;
                    final noteText = noteData['text'] ?? 'Not found the note';

                    return Dismissible(
                      key: Key(noteId),
                      direction: DismissDirection.horizontal,
                      onDismissed: (_) async {
                        await FirebaseFirestore.instance
                            .collection('notes')
                            .doc(noteId)
                            .delete();

                        if (!context.mounted)
                          return; //schützt vor ungültigem Kontext, d.h. wenn Context null ist
                        // z.b Scaffoldmessage anzeigen von context der null ist führt zum Absturz

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('note deleted')));
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),

                      child: ListTile(
                        title: Text(noteText),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => AddNoteScreen(
                                      existingNoteId: note.id,
                                      initialText: noteData['text'],
                                    ),
                              ),
                            );
                          },
                        ),
                        // Wenn ich will noch mehr Informationen anzeigen wie timestamp??
                      ),
                    );
                  }, //Itembuilder
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddNoteScreen(),
            ), // Wechselt zur Eingabemaske
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
