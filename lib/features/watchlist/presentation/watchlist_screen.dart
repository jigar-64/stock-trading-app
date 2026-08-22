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
/// - TabBar & TabBarView synchronized navigation between watchlists.
/// - Drag-to-reorder stocks via [ReorderableListView].
/// - Stock picker to add stocks from the 10 available NSE stocks.
/// - Persists all watchlists and stock layouts across app restarts.
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
    _tabController?.removeListener(_handleTabChange);
    _tabController?.dispose();
    super.dispose();
  }

  void _syncTabController(int length, int initialIndex) {
    final clampedIndex = initialIndex.clamp(0, length > 0 ? length - 1 : 0);
    if (_tabController == null || _tabController!.length != length) {
      _tabController?.removeListener(_handleTabChange);
      _tabController?.dispose();
      _tabController = TabController(
        length: length,
        vsync: this,
        initialIndex: clampedIndex,
      );
      _tabController!.addListener(_handleTabChange);
    } else if (_tabController!.index != clampedIndex &&
        !_tabController!.indexIsChanging) {
      _tabController!.animateTo(clampedIndex);
    }
  }

  void _handleTabChange() {
    if (_tabController != null &&
        ref.read(activeWatchlistIndexProvider) != _tabController!.index) {
      ref.read(activeWatchlistIndexProvider.notifier).state =
          _tabController!.index;
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
              backgroundColor: AppColors.accentIndigo,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (name != null && name.trim().isNotEmpty) {
      await ref.read(watchlistsProvider.notifier).createWatchlist(name);
      final watchlists = ref.read(watchlistsProvider);
      final newIndex = watchlists.length - 1;
      ref.read(activeWatchlistIndexProvider.notifier).state = newIndex;
      if (_tabController != null && _tabController!.length == watchlists.length) {
        _tabController!.animateTo(newIndex);
      }
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
              backgroundColor: AppColors.accentIndigo,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

    // Sync tab controller with current watchlists length & active index
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
        bottom: watchlists.length > 1 && _tabController != null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: AppColors.accentIndigo.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.accentIndigo.withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: AppColors.textPrimary,
                    unselectedLabelColor: AppColors.textMuted,
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                    ),
                    tabs: watchlists
                        .map((w) => Tab(
                              height: 34,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text('${w.name} (${w.symbols.length})'),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              )
            : PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: AppColors.divider, height: 1),
              ),
      ),
      body: _tabController == null
          ? const SizedBox.shrink()
          : TabBarView(
              controller: _tabController,
              children: watchlists.map((watchlist) {
                if (watchlist.symbols.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.search_off,
                    title: '${watchlist.name} is Empty',
                    subtitle:
                        'Add stocks from the 10 available NSE stocks to watch live price updates.',
                    actionLabel: 'Add Stock',
                    onActionPressed: () {
                      StockPickerDialog.show(
                        context,
                        watchlistId: watchlist.id,
                        existingSymbols: watchlist.symbols,
                        onStockSelected: (symbol) {
                          ref
                              .read(watchlistsProvider.notifier)
                              .addStock(watchlist.id, symbol);
                        },
                      );
                    },
                  );
                }
                return ReorderableListView.builder(
                  key: PageStorageKey<String>(watchlist.id),
                  itemCount: watchlist.symbols.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  onReorder: (oldIndex, newIndex) {
                    ref
                        .read(watchlistsProvider.notifier)
                        .reorderStock(watchlist.id, oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final symbol = watchlist.symbols[index];
                    return WatchlistStockTile(
                      key: ValueKey('${watchlist.id}_$symbol'),
                      symbol: symbol,
                      index: index,
                      onRemove: () {
                        ref
                            .read(watchlistsProvider.notifier)
                            .removeStock(watchlist.id, symbol);
                      },
                    );
                  },
                );
              }).toList(),
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
        backgroundColor: AppColors.accentIndigo,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Stock',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
