import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  PlatformFile? _pickedPdf;
  bool _isUploading = false;
  String? _error;

  Future<void> _pickPdf() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedPdf = result.files.first;
      });
    }
  }

  Future<void> _openPickedPdf() async {
    if (_pickedPdf?.path != null) {
      await OpenFile.open(_pickedPdf!.path!);
    }
  }

  Future<void> _upload() async {
    final String title = _titleController.text.trim();
    final String description = _descriptionController.text.trim();
    final PlatformFile? file = _pickedPdf;
    if (title.isEmpty || file == null || file.bytes == null) {
      setState(() => _error = 'Please provide a title and pick a PDF');
      return;
    }
    setState(() {
      _isUploading = true;
      _error = null;
    });
    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      final String fileId = FirebaseFirestore.instance.collection('tmp').doc().id;
      final String storagePath = 'uploads/$uid/$fileId-${file.name}';
      final Reference ref = FirebaseStorage.instance.ref().child(storagePath);
      final Uint8List bytes = file.bytes!;
      final UploadTask task = ref.putData(bytes, SettableMetadata(contentType: 'application/pdf'));
      final TaskSnapshot snap = await task;
      final String downloadUrl = await snap.ref.getDownloadURL();

      final DocumentReference docRef = FirebaseFirestore.instance.collection('documents').doc(fileId);
      await docRef.set({
        'title': title,
        'description': description,
        'fileName': file.name,
        'size': file.size,
        'storagePath': storagePath,
        'downloadUrl': downloadUrl,
        'ownerUid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploaded successfully')));
      setState(() {
        _titleController.clear();
        _descriptionController.clear();
        _pickedPdf = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? email = FirebaseAuth.instance.currentUser?.email;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (email != null) Text('Signed in as $email', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickPdf,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Pick PDF'),
                    ),
                    const SizedBox(width: 12),
                    if (_pickedPdf != null) Expanded(child: Text(_pickedPdf!.name, overflow: TextOverflow.ellipsis)),
                    if (_pickedPdf != null && _pickedPdf!.path != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _openPickedPdf,
                        icon: const Icon(Icons.open_in_new),
                        tooltip: 'Open',
                      )
                    ]
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _isUploading ? null : _upload,
                  icon: _isUploading
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.cloud_upload_outlined),
                  label: Text(_isUploading ? 'Uploading...' : 'Upload PDF'),
                ),
                const SizedBox(height: 24),
                const _RecentUploads(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentUploads extends StatelessWidget {
  const _RecentUploads();

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('documents')
          .where('ownerUid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('No uploads yet')),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final String title = data['title'] ?? '';
            final String fileName = data['fileName'] ?? '';
            final String? downloadUrl = data['downloadUrl'] as String?;
            return ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: Text(title.isEmpty ? fileName : title),
              subtitle: Text(fileName),
              trailing: IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: downloadUrl == null ? null : () => OpenFile.open(downloadUrl),
                tooltip: 'Open',
              ),
            );
          },
        );
      },
    );
  }
}