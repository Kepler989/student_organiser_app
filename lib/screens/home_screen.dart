import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/subject.dart';
import '../widgets/subject_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Subject> _subjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() => _isLoading = true);
    final subjects = await _dbHelper.getAllSubjects();
    if (mounted) setState(() { _subjects = subjects; _isLoading = false; });
  }

  Future<void> _addSubject() async {
    final nameController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('New Subject',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nameController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'e.g. Mathematics, Physics...',
            prefixIcon: const Icon(Icons.menu_book_rounded),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF5C6BC0), width: 2),
            ),
          ),
          onSubmitted: (_) => Navigator.of(ctx).pop(true),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5C6BC0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (confirmed == true && nameController.text.trim().isNotEmpty) {
      final subject = Subject(name: nameController.text.trim());
      await _dbHelper.insertSubject(subject);
      _loadSubjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.school_rounded, size: 26),
            SizedBox(width: 10),
            Text(
              'Student Organizer',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_subjects.length} Subject${_subjects.length == 1 ? '' : 's'}',
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subjects.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadSubjects,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 16, bottom: 100),
                    itemCount: _subjects.length,
                    itemBuilder: (ctx, index) => SubjectCard(
                      subject: _subjects[index],
                      onSubjectDeleted: _loadSubjects,
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSubject,
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Subject',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 4,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF5C6BC0).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 52,
              color: Color(0xFF5C6BC0),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Subjects Yet',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3D3D3D)),
          ),
          const SizedBox(height: 10),
          Text(
            'Tap the button below to add\nyour first subject!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _addSubject,
            icon: const Icon(Icons.add),
            label: const Text('Add Subject'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5C6BC0),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
