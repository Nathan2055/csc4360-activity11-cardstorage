import 'package:cw11/models/folder.dart';
import 'package:cw11/repositories/folder_repository.dart';
import 'package:flutter/material.dart';

import 'cards_screen.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final FolderRepository _folderRepo = FolderRepository();
  late Future<List<Folder>> _foldersFuture;

  @override
  void initState() {
    super.initState();
    _foldersFuture = _folderRepo.getAllFolders();
  }

  Future<void> _refresh() async {
    setState(() {
      _foldersFuture = _folderRepo.getAllFolders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Card Organizer - Folders')),
      body: FutureBuilder<List<Folder>>(
        future: _foldersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final folders = snapshot.data ?? [];
          return RefreshIndicator(
            onRefresh: _refresh,
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folder = folders[index];
                return _FolderTile(
                  folder: folder,
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CardsScreen(folder: folder),
                      ),
                    );
                    _refresh();
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _FolderTile extends StatelessWidget {
  final Folder folder;
  final VoidCallback onTap;

  const _FolderTile({required this.folder, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (folder.previewImage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(folder.previewImage!, height: 80, fit: BoxFit.contain),
              )
            else
              const Icon(Icons.folder, size: 64, color: Colors.blueGrey),
            const SizedBox(height: 8),
            Text(folder.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            _FolderCount(folderId: folder.id!),
          ],
        ),
      ),
    );
  }
}

class _FolderCount extends StatefulWidget {
  final int folderId;
  const _FolderCount({required this.folderId});

  @override
  State<_FolderCount> createState() => _FolderCountState();
}

class _FolderCountState extends State<_FolderCount> {
  final FolderRepository _repo = FolderRepository();
  late Future<int> _countFuture;

  @override
  void initState() {
    super.initState();
    _countFuture = _repo.countCardsInFolder(widget.folderId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _countFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2));
        }
        return Text('${snapshot.data} cards', style: const TextStyle(color: Colors.black54));
      },
    );
  }
}


