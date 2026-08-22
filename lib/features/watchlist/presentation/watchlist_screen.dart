import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/empty_state_widget.dart';
import 'providers/watchlist_providers.dart';
import 'widgets/stock_picker_dialog.dart';
import 'widgets/watchlist_stock_tile.dart';

/// Watchlist Management screen (Feature 1).
///
/// Features:
/// - Supports multiple named watchlists (create, rename, delete).
/// - TabBar navigation between watchlists.
/// - Drag-to-reorder stocks via [ReorderableListView].
/// - Stock picker to add stocks from the 10 available NSE stocks.
/// - Swipe / action to remove stocks.
/// - Persists all watchlists and stock orders across app restarts.
class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _syncTabController(int length, int initialIndex) {
    if (_tabController?.length != length) {
      _tabController?.dispose();
      _tabController = TabController(
        length: length,
        vsync: this,
        initialIndex: initialIndex.clamp(0, length > 0 ? length - 1 : 0),
      );
      _tabController?.addListener(() {
        if (_tabController != null && !_tabController!.indexIsChanging) {
          ref.read(activeWatchlistIndexProvider.notifier).state =
              _tabController!.index;
        }
      });
    }
  }

  /// Opens dialog to create a new watchlist.
  Future<void> _showCreateWatchlistDialog() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('New Watchlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Watchlist Name (e.g. Technology)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentBlue,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (name != null && name.trim().isNotEmpty) {
      await ref.read(watchlistsProvider.notifier).createWatchlist(name);
      // Switch tab to the newly created watchlist
      final watchlists = ref.read(watchlistsProvider);
      ref.read(activeWatchlistIndexProvider.notifier).state =
          watchlists.length - 1;
    }
  }

  /// Opens dialog to rename the current watchlist.
  Future<void> _showRenameWatchlistDialog(
      String watchlistId, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Rename Watchlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter new name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentBlue,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName.trim().isNotEmpty) {
      await ref
          .read(watchlistsProvider.notifier)
          .renameWatchlist(watchlistId, newName);
    }
  }

  /// Opens confirmation dialog to delete the current watchlist.
  Future<void> _showDeleteWatchlistDialog(
      String watchlistId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text('Delete "$name"?'),
        content: const Text(
          'This will permanently delete this watchlist and its stock layout.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sellRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(watchlistsProvider.notifier).deleteWatchlist(watchlistId);
      ref.read(activeWatchlistIndexProvider.notifier).state = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final watchlists = ref.watch(watchlistsProvider);
    final activeIndex = ref.watch(activeWatchlistIndexProvider);

    // Sync tab controller whenever watchlists count changes
    _syncTabController(watchlists.length, activeIndex);

    // Empty state when no watchlists exist at all
    if (watchlists.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Watchlists'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Create Watchlist',
              onPressed: _showCreateWatchlistDialog,
            ),
          ],
        ),
        body: EmptyStateWidget(
          icon: Icons.list_alt,
          title: 'No Watchlists',
          subtitle: 'Create a watchlist to track your favorite stocks in real time.',
          actionLabel: 'Create Watchlist',
          onActionPressed: _showCreateWatchlistDialog,
        ),
      );
    }

    // Ensure active index is valid
    final clampedIndex = activeIndex.clamp(0, watchlists.length - 1);
    final currentWatchlist = watchlists[clampedIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlists'),
        actions: [
          // Add new watchlist action
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create New Watchlist',
            onPressed: _showCreateWatchlistDialog,
          ),
          // More options menu for current watchlist (rename / delete)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'rename') {
                _showRenameWatchlistDialog(
                  currentWatchlist.id,
                  currentWatchlist.name,
                );
              } else if (value == 'delete') {
                _showDeleteWatchlistDialog(
                  currentWatchlist.id,
                  currentWatchlist.name,
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 12),
                    Text('Rename Watchlist'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: AppColors.sellRed),
                    SizedBox(width: 12),
                    Text(
                      'Delete Watchlist',
                      style: TextStyle(color: AppColors.sellRed),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        // TabBar for switching between watchlists
        bottom: _tabController != null && watchlists.length > 1
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppColors.accentBlue,
                labelColor: AppColors.accentBlue,
                unselectedLabelColor: AppColors.textMuted,
                tabs: watchlists
                    .map((w) => Tab(text: '${w.name} (${w.symbols.length})'))
                    .toList(),
              )
            : PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: AppColors.divider, height: 1),
              ),
      ),
      body: currentWatchlist.symbols.isEmpty
          // Empty state for empty watchlist tab
          ? EmptyStateWidget(
              icon: Icons.search_off,
              title: '${currentWatchlist.name} is Empty',
              subtitle:
                  'Add stocks from the 10 available NSE stocks to watch live price updates.',
              actionLabel: 'Add Stock',
              onActionPressed: () {
                StockPickerDialog.show(
                  context,
                  watchlistId: currentWatchlist.id,
                  existingSymbols: currentWatchlist.symbols,
                  onStockSelected: (symbol) {
                    ref
                        .read(watchlistsProvider.notifier)
                        .addStock(currentWatchlist.id, symbol);
                  },
                );
              },
            )
          // Reorderable list of stocks in current watchlist
          : ReorderableListView.builder(
              itemCount: currentWatchlist.symbols.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              onReorder: (oldIndex, newIndex) {
                ref
                    .read(watchlistsProvider.notifier)
                    .reorderStock(currentWatchlist.id, oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final symbol = currentWatchlist.symbols[index];
                return WatchlistStockTile(
                  key: ValueKey('${currentWatchlist.id}_$symbol'),
                  symbol: symbol,
                  index: index,
                  onRemove: () {
                    ref
                        .read(watchlistsProvider.notifier)
                        .removeStock(currentWatchlist.id, symbol);
                  },
                );
              },
            ),
      // Floating Action Button to add stocks to current watchlist
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          StockPickerDialog.show(
            context,
            watchlistId: currentWatchlist.id,
            existingSymbols: currentWatchlist.symbols,
            onStockSelected: (symbol) {
              ref
                  .read(watchlistsProvider.notifier)
                  .addStock(currentWatchlist.id, symbol);
            },
          );
        },
        backgroundColor: AppColors.accentBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Stock',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
