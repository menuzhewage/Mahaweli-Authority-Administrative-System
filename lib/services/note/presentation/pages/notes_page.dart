import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';

import '../data/notes.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> with SingleTickerProviderStateMixin {
  late Box<Note> _noteBox;
  int? _selectedNoteIndex;
  bool _isLoading = true;
  late AnimationController _emptyStateController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _noteBox = Hive.box<Note>('notes');
    _emptyStateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _loadNotes();
  }

  @override
  void dispose() {
    _emptyStateController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading
    setState(() {
      _isLoading = false;
      if (_noteBox.isEmpty) {
        _emptyStateController.forward();
      }
    });
  }

  void _addNote() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add New Note',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Title',
                prefixIcon: const Icon(Iconsax.note),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                hintText: 'Content',
                prefixIcon: const Icon(Iconsax.document_text),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final title = titleController.text.trim();
                  final content = contentController.text.trim();

                  if (title.isNotEmpty && content.isNotEmpty) {
                    final newNote = Note(
                      title: title,
                      content: content,
                      createdAt: DateTime.now(),
                    );
                    _noteBox.add(newNote);
                    Navigator.pop(context);
                    _loadNotes();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Please fill in all fields'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Add Note'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _editNote(Note note) {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Edit Note',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Title',
                prefixIcon: const Icon(Iconsax.note),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                hintText: 'Content',
                prefixIcon: const Icon(Iconsax.document_text),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final title = titleController.text.trim();
                  final content = contentController.text.trim();

                  if (title.isNotEmpty && content.isNotEmpty) {
                    note.title = title;
                    note.content = content;
                    note.save();
                    Navigator.pop(context);
                    _loadNotes();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Please fill in all fields'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Update Note'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('This action cannot be undone. Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      note.delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Note deleted successfully'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      _loadNotes();
    }
  }

  Future<void> _clearAllNotes() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notes'),
        content: const Text('This will permanently delete all your notes. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _noteBox.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('All notes cleared successfully'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      _loadNotes();
    }
  }

  Future<void> _showNoteOptions(Note note) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Iconsax.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _editNote(note);
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // Implement share functionality
              },
            ),
            ListTile(
              leading: Icon(Iconsax.trash, color: Colors.red[400]),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteNote(note);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Iconsax.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _noteBox.isEmpty
              ? _buildEmptyState()
              : CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverAppBar(
                      title: const Text('My Notes'),
                      floating: true,
                      snap: true,
                      actions: [
                        IconButton(
                          icon: const Icon(Iconsax.search_normal),
                          onPressed: () {}, // Implement search
                        ),
                        IconButton(
                          icon: const Icon(Iconsax.filter),
                          onPressed: () {}, // Implement filter
                        ),
                        IconButton(
                          icon: const Icon(Iconsax.trash),
                          onPressed: _clearAllNotes,
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Text(
                          '${_noteBox.length} note${_noteBox.length != 1 ? 's' : ''}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final note = _noteBox.getAt(index) as Note;
                            return _buildNoteCard(note, index);
                          },
                          childCount: _noteBox.length,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildNoteCard(Note note, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.surfaceVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() {
          _selectedNoteIndex = _selectedNoteIndex == index ? null : index;
        }),
        onLongPress: () => _showNoteOptions(note),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Iconsax.note_text,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${note.content.split(' ').length} words',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Iconsax.more,
                      size: 20,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                    onPressed: () => _showNoteOptions(note),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                note.content,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: _selectedNoteIndex == index ? null : 2,
                overflow: _selectedNoteIndex == index ? null : TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Iconsax.calendar,
                    size: 16,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM dd, yyyy - hh:mm a').format(note.createdAt),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.note_text,
                size: 60,
                color: colorScheme.primary.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Notes Found',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first note to get started',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _addNote,
              icon: const Icon(Iconsax.add, size: 18),
              label: const Text('Create Note'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}