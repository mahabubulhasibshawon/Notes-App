import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../auth/presentation/widgets/custom_button.dart';
import '../providers/notes_provider.dart';
import '../../data/models/note_model.dart';

class AddNotePage extends HookConsumerWidget {
  final NoteModel? note;

  const AddNotePage({Key? key, this.note}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final titleController = useTextEditingController(text: note?.title ?? '');
    final descriptionController = useTextEditingController(text: note?.description ?? '');
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isEditing = note != null;

    ref.listen<AsyncValue<void>>(notesNotifierProvider, (previous, next) {
      next.when(
        data: (_) {
          SnackbarHelper.showSuccess(
            context,
            AppStrings.noteSaved,
          );
          context.pop();
        },
        error: (error, _) {
          SnackbarHelper.showError(context, error.toString());
        },
        loading: () {},
      );
    });

    final notesState = ref.watch(notesNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isEditing ? AppStrings.editNote : AppStrings.addNote,
          style: AppTextStyles.headline3,
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: () {
                _showDeleteDialog(context, ref, note!.id);
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(
                        label: AppStrings.title,
                        hintText: 'Enter note title',
                        controller: titleController,
                        validator: Validators.validateTitle,
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        label: AppStrings.description,
                        hintText: 'Enter note description',
                        controller: descriptionController,
                        validator: Validators.validateDescription,
                        maxLines: 10,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(color: Colors.grey, width: 0.2),
                  ),
                ),
                child: CustomButton(
                  text: AppStrings.save,
                  isLoading: notesState.isLoading,
                  onPressed: () async {
                    if (formKey.currentState!.validate() && user != null) {
                      if (isEditing) {
                        await ref.read(notesNotifierProvider.notifier).updateNote(
                          noteId: note!.id,
                          title: titleController.text.trim(),
                          description: descriptionController.text.trim(),
                        );
                      } else {
                        await ref.read(notesNotifierProvider.notifier).addNote(
                          title: titleController.text.trim(),
                          description: descriptionController.text.trim(),
                          userId: user.id,
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String noteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text(
          'Are you sure you want to delete this note? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(notesNotifierProvider.notifier).deleteNote(noteId);
              if (context.mounted) {
                SnackbarHelper.showSuccess(context, AppStrings.noteDeleted);
                context.pop();
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}