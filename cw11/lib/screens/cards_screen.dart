import 'package:cw11/models/folder.dart';
import 'package:cw11/models/playing_card.dart';
import 'package:cw11/repositories/card_repository.dart';
import 'package:cw11/repositories/folder_repository.dart';
import 'package:flutter/material.dart';

class CardsScreen extends StatefulWidget {
  final Folder folder;
  const CardsScreen({super.key, required this.folder});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final CardRepository _cardRepo = CardRepository();
  final FolderRepository _folderRepo = FolderRepository();
  late Future<List<PlayingCard>> _cardsFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _cardsFuture = _cardRepo.getCardsByFolder(widget.folder.id!);
  }

  Future<void> _addCard() async {
    final count = await _folderRepo.countCardsInFolder(widget.folder.id!);
    if (count >= 6) {
      _showMessage('This folder can only hold 6 cards.');
      return;
    }
    final selected = await showDialog<PlayingCard?>(
      context: context,
      builder: (context) => _SelectCardDialog(folderId: widget.folder.id!),
    );
    if (selected != null) {
      selected.folderId = widget.folder.id;
      await _cardRepo.updateCard(selected);
      await _folderRepo.updatePreviewImageFromFirstCard(widget.folder.id!);
      setState(_reload);
    }
  }

  Future<void> _removeCard(PlayingCard card) async {
    card.folderId = null;
    await _cardRepo.updateCard(card);
    await _folderRepo.updatePreviewImageFromFirstCard(widget.folder.id!);
    setState(_reload);
  }

  void _showMessage(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
        actions: [
          IconButton(onPressed: _addCard, icon: const Icon(Icons.add)),
        ],
      ),
      body: FutureBuilder<List<PlayingCard>>(
        future: _cardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final cards = snapshot.data ?? [];
          if (cards.length < 3) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showMessage('You need at least 3 cards in this folder.');
            });
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.65,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              return _CardTile(
                card: card,
                onDelete: () => _removeCard(card),
              );
            },
          );
        },
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  final PlayingCard card;
  final VoidCallback onDelete;

  const _CardTile({required this.card, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Expanded(
            child: Image.network(card.imageUrl, fit: BoxFit.contain),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(card.name, textAlign: TextAlign.center, maxLines: 2),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Remove from folder',
          ),
        ],
      ),
    );
  }
}

class _SelectCardDialog extends StatefulWidget {
  final int folderId;
  const _SelectCardDialog({required this.folderId});

  @override
  State<_SelectCardDialog> createState() => _SelectCardDialogState();
}

class _SelectCardDialogState extends State<_SelectCardDialog> {
  final CardRepository _cardRepo = CardRepository();
  late Future<List<PlayingCard>> _available;

  @override
  void initState() {
    super.initState();
    _available = _cardRepo.getUnassignedCards();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select a card to add'),
      content: SizedBox(
        width: 400,
        height: 400,
        child: FutureBuilder<List<PlayingCard>>(
          future: _available,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final cards = snapshot.data!;
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.65,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                return InkWell(
                  onTap: () => Navigator.pop(context, card),
                  child: Column(
                    children: [
                      Expanded(child: Image.network(card.imageUrl, fit: BoxFit.contain)),
                      Text(card.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      ],
    );
  }
}


