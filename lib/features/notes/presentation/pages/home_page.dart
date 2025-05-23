import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_card.dart';
import '../widgets/empty_notes_widget.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final notesAsync = ref.watch(userNotesProvider);

    ref.listen<AsyncValue<void>>(notesNotifierProvider, (previous, next) {
      next.when(
        data: (_) {
          // Success handled by stream updates
        },
        error: (error, _) {
          SnackbarHelper.showError(context, error.toString());
        },
        loading: () {},
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.myNotes,
              style: AppTextStyles.headline2,
            ),
            if (user != null)
              Text(
                'Hello, ${user.name}',
                style: AppTextStyles.caption,
              ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await ref.read(authNotifierProvider.notifier).signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
      body: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return const EmptyNotesWidget();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userNotesProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return NoteCard(
                  note: note,
                  onTap: () {
                    context.push('/add-note', extra: note);
                  },
                  onDelete: () async {
                    await ref
                        .read(notesNotifierProvider.notifier)
                        .deleteNote(note.id);
                    if (context.mounted) {
                      SnackbarHelper.showSuccess(
                        context,
                        AppStrings.noteDeleted,
                      );
                    }
                  },
                );
              },
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, stackTrace) => CustomErrorWidget(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(userNotesProvider);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-note'),
        backgroundColor: AppColors.primary,
        child: const Icon(
          Icons.add,
          color: AppColors.onPrimary,
        ),
      ),
    );
  }
}