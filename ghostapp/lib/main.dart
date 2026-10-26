
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const GhostApp());
}


const ghostPurple = Color(0xFFAA99FF);
const ghostBackground = Color(0xFF0D0D12);
const ghostSurface = Color(0xFF17171F);

class GhostApp extends StatelessWidget {
  const GhostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GhostApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: ghostBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ghostPurple,
          brightness: Brightness.dark,
          surface: ghostSurface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: ghostBackground,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: ghostSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const GhostWelcomeScreen(),
    );
  }
}

class GhostWelcomeScreen extends StatelessWidget {
  const GhostWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: ghostPurple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: ghostPurple.withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Icon(
                    Icons.nights_stay_rounded,
                    size: 52,
                    color: ghostPurple,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'GhostApp',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your thoughts. Your space.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ghostPurple,
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'A calmer place to capture ideas, keep your notes, '
                  'and make sense of your day.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    height: 1.7,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 34),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) => const GhostNotesScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text(
                      'Get started',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: ghostPurple,
                      foregroundColor: const Color(0xFF171323),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'A little space for everything on your mind.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class GhostNote {
  GhostNote({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
    this.isPinned = false,
  });

  final int id;
  final String title;
  final String content;
  final DateTime updatedAt;
  final bool isPinned;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'updatedAt': updatedAt.toIso8601String(),
      'isPinned': isPinned,
    };
  }

  factory GhostNote.fromJson(Map<String, dynamic> json) {
    return GhostNote(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isPinned: (json['isPinned'] as bool?) ?? false,
    );
  }
}


class GhostNotesScreen extends StatefulWidget {
  const GhostNotesScreen({super.key});

  @override
  State<GhostNotesScreen> createState() => _GhostNotesScreenState();
}

class _GhostNotesScreenState extends State<GhostNotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<GhostNote> _notes = [];
  Timer? _clockTimer;
  DateTime _now = DateTime.now();
  int _nextId = 1;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String _timeString(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute:$second $period';
  }

  String _dateString(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${weekdays[date.weekday - 1]}, '
        '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  List<GhostNote> get _visibleNotes {
    final query = _query.trim().toLowerCase();
    final result = _notes.where((note) {
      return query.isEmpty ||
          note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query);
    }).toList();

    result.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return result;
  }

  Future<void> _editNote([GhostNote? existing]) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final contentController = TextEditingController(
      text: existing?.content ?? '',
    );

    final result = await showDialog<GhostNote>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(existing == null ? 'New note' : 'Edit note'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  maxLength: 100,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Give your note a title',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  minLines: 5,
                  maxLines: 12,
                  decoration: const InputDecoration(
                    labelText: 'Your thoughts',
                    hintText: 'Start writing...',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final title = titleController.text.trim();
              final content = contentController.text.trim();

              if (title.isEmpty && content.isEmpty) {
                Navigator.pop(dialogContext);
                return;
              }

              Navigator.pop(
                dialogContext,
                GhostNote(
                  id: existing?.id ?? _nextId++,
                  title: title.isEmpty ? 'Untitled note' : title,
                  content: content,
                  updatedAt: DateTime.now(),
                  isPinned: existing?.isPinned ?? false,
                ),
              );
            },
            child: const Text('Save note'),
          ),
        ],
      ),
    );

    titleController.dispose();
    contentController.dispose();

    if (!mounted || result == null) return;

    setState(() {
      final index = _notes.indexWhere((note) => note.id == result.id);
      if (index == -1) {
        _notes.add(result);
      } else {
        _notes[index] = result;
      }
    });
  }

  void _togglePin(GhostNote note) {
    setState(() {
      final index = _notes.indexWhere((item) => item.id == note.id);
      if (index == -1) return;

      final current = _notes[index];
      _notes[index] = GhostNote(
        id: current.id,
        title: current.title,
        content: current.content,
        updatedAt: DateTime.now(),
        isPinned: !current.isPinned,
      );
    });
  }

  Future<void> _deleteNote(GhostNote note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this note?'),
        content: Text('"${note.title}" will be removed from this session.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _notes.removeWhere((item) => item.id == note.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 850;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.nights_stay_rounded, color: ghostPurple),
            const SizedBox(width: 10),
            const Text(
              'GhostApp',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Center(
              child: Text(
                _timeString(_now),
                style: const TextStyle(
                  color: ghostPurple,
                  fontFeatures: [],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editNote(),
        backgroundColor: ghostPurple,
        foregroundColor: const Color(0xFF171323),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New note'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              wide ? 32 : 18,
              20,
              wide ? 32 : 18,
              90,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dateString(_now),
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your thoughts, in one place.',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_notes.length} ${_notes.length == 1 ? 'note' : 'notes'} in your space',
                  style: const TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                    hintText: 'Search your notes...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: _visibleNotes.isEmpty
                      ? _buildEmptyState()
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: wide ? 330 : 500,
                                mainAxisExtent: 220,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: _visibleNotes.length,
                          itemBuilder: (context, index) {
                            final note = _visibleNotes[index];
                            return _buildNoteCard(note);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final searching = _query.trim().isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            searching ? Icons.search_off_rounded : Icons.note_alt_outlined,
            size: 52,
            color: ghostPurple,
          ),
          const SizedBox(height: 16),
          Text(
            searching ? 'No matching notes' : 'Your space is still quiet.',
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            searching
                ? 'Try another search.'
                : 'Create your first note and get it out of your head.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54),
          ),
          if (!searching) ...[
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () => _editNote(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Write a note'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoteCard(GhostNote note) {
    return Card(
      color: ghostSurface,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: InkWell(
        onTap: () => _editNote(note),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: note.isPinned ? 'Unpin note' : 'Pin note',
                    onPressed: () => _togglePin(note),
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      note.isPinned
                          ? Icons.push_pin_rounded
                          : Icons.push_pin_outlined,
                      color: note.isPinned ? ghostPurple : Colors.white54,
                      size: 19,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete note',
                    onPressed: () => _deleteNote(note),
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white54,
                      size: 19,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    note.content.isEmpty ? 'No additional text.' : note.content,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: note.content.isEmpty
                          ? Colors.white38
                          : Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const Divider(color: Colors.white12),
              Text(
                'Edited ${note.updatedAt.hour.toString().padLeft(2, '0')}:'
                '${note.updatedAt.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
