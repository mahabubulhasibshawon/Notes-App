import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/note_model.dart';

class NotesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  Stream<List<NoteModel>> getUserNotes(String userId) {
    try {
      return _firestore
          .collection('notes')
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return NoteModel.fromJson(data);
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to fetch notes: $e');
    }
  }

  Future<List<NoteModel>> getUserNotesOnce(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return NoteModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch notes: $e');
    }
  }

  Future<NoteModel> addNote({
    required String title,
    required String description,
    required String userId,
  }) async {
    try {
      final noteId = _uuid.v4();
      final now = DateTime.now();

      final note = NoteModel(
        id: noteId,
        title: title,
        description: description,
        userId: userId,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore.collection('notes').doc(noteId).set(note.toJson());

      return note;
    } catch (e) {
      throw Exception('Failed to add note: $e');
    }
  }

  Future<NoteModel> updateNote({
    required String noteId,
    required String title,
    required String description,
  }) async {
    try {
      final noteRef = _firestore.collection('notes').doc(noteId);
      final noteDoc = await noteRef.get();

      if (!noteDoc.exists) {
        throw Exception('Note not found');
      }

      final existingNote = NoteModel.fromJson(noteDoc.data()!);
      final updatedNote = existingNote.copyWith(
        title: title,
        description: description,
        updatedAt: DateTime.now(),
      );

      await noteRef.update(updatedNote.toJson());

      return updatedNote;
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _firestore.collection('notes').doc(noteId).delete();
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  Future<NoteModel?> getNoteById(String noteId) async {
    try {
      final doc = await _firestore.collection('notes').doc(noteId).get();

      if (!doc.exists) {
        return null;
      }

      return NoteModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch note: $e');
    }
  }
}