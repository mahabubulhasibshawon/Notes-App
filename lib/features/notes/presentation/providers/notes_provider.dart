import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/notes_repository.dart';
import '../../data/models/note_model.dart';

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository();
});

final userNotesProvider = StreamProvider<List<NoteModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  final notesRepository = ref.watch(notesRepositoryProvider);

  if (user == null) {
    return Stream.value(<NoteModel>[]);
  }

  return notesRepository.getUserNotes(user.id);
});

class NotesNotifier extends StateNotifier<AsyncValue<void>> {
  final NotesRepository _notesRepository;

  NotesNotifier(this._notesRepository) : super(const AsyncValue.data(null));

  Future<void> addNote({
    required String title,
    required String description,
    required String userId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _notesRepository.addNote(
        title: title,
        description: description,
        userId: userId,
      );
    });
  }

  Future<void> updateNote({
    required String noteId,
    required String title,
    required String description,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _notesRepository.updateNote(
        noteId: noteId,
        title: title,
        description: description,
      );
    });
  }

  Future<void> deleteNote(String noteId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _notesRepository.deleteNote(noteId);
    });
  }
}

final notesNotifierProvider = StateNotifierProvider<NotesNotifier, AsyncValue<void>>((ref) {
  final notesRepository = ref.watch(notesRepositoryProvider);
  return NotesNotifier(notesRepository);
});
