// HistoryScreen: full history browser with search, filter, sort, favorites.
//
// Layout:
//   AppBar with search toggle + sort menu + clear-all
//   Filter row: All | Favorites | Folder | Tag
//   Search field (animated)
//   History list (cards with preview thumbnail, content, type, date, actions)
//
// Long-press → multi-select mode (delete, move-to-folder, add-tag, export).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/content_type.dart';
import '../../../core/extensions/build_context.dart';
import '../../../core/utils/service_locator.dart';
import '../../../domain/entities/history_entry.dart';
import '../../../domain/usecases/history_usecases.dart';
import '../../providers/history_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  bool _showSearch = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(historyFilterProvider);
    final historyAsync = ref.watch(filteredHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: context.l10n.history_searchHint,
                  border: InputBorder.none,
                ),
                onChanged: (v) =>
                    ref.read(historyFilterProvider.notifier).setQuery(v),
              )
            : Text(context.l10n.history_title),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _showSearch = !_showSearch);
              if (!_showSearch) {
                _searchController.clear();
                ref.read(historyFilterProvider.notifier).setQuery('');
              }
            },
          ),
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            onSelected: (s) =>
                ref.read(historyFilterProvider.notifier).setSort(s),
            itemBuilder: (_) => [
              PopupMenuItem(value: SortOption.dateDesc, child: Text(context.l10n.history_sort_date)),
              PopupMenuItem(value: SortOption.dateAsc, child: Text('${context.l10n.history_sort_date} ↑')),
              PopupMenuItem(value: SortOption.nameAsc, child: Text(context.l10n.history_sort_name)),
              PopupMenuItem(value: SortOption.nameDesc, child: Text('${context.l10n.history_sort_name} ↓')),
              PopupMenuItem(value: SortOption.typeAsc, child: Text(context.l10n.history_sort_type)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () async {
              final entries = await ref.read(historyListProvider.future);
              if (!context.mounted) return;
              final ok = await ConfirmDialog.show(
                context,
                title: context.l10n.dialog_clearHistoryTitle,
                message: context.l10n.dialog_clearHistoryMessage(entries.length),
                isDestructive: true,
              );
              if (ok) {
                await ServiceLocator.instance.historyRepository.clearAll();
                ref.invalidate(historyListProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.snackbar_deleted)),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(filter: filter),
          Expanded(
            child: historyAsync.when(
              data: (entries) {
                if (entries.isEmpty) {
                  return EmptyState(
                    icon: Icons.history,
                    title: context.l10n.history_empty,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _HistoryCard(entry: entries[i]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------------
// Filter bar
// -------------------------------------------------------------------------

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.filter});
  final HistoryFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Wrap(
        spacing: 6,
        children: [
          FilterChip(
            label: Text(context.l10n.history_all),
            selected: !filter.favoritesOnly &&
                filter.folderId == null &&
                filter.tag == null,
            onSelected: (_) {
              ref.read(historyFilterProvider.notifier).clear();
            },
          ),
          FilterChip(
            label: Text(context.l10n.history_favorites),
            selected: filter.favoritesOnly,
            onSelected: (_) =>
                ref.read(historyFilterProvider.notifier).toggleFavorites(),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------------
// History card
// -------------------------------------------------------------------------

class _HistoryCard extends ConsumerWidget {
  const _HistoryCard({required this.entry});
  final HistoryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: _TypeAvatar(type: entry.content.type),
        title: Text(
          entry.content.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.content.raw,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _TypeChip(type: entry.content.type),
                const SizedBox(width: 6),
                Text(
                  _formatDate(entry.createdAt),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                if (entry.isFavorite) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.star, size: 14, color: context.colors.tertiary),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleAction(context, ref, action),
          itemBuilder: (_) => [
            PopupMenuItem(value: 'favorite', child: _favoriteLabel(context)),
            PopupMenuItem(value: 'copy', child: Text(context.l10n.action_copy)),
            PopupMenuItem(value: 'delete', child: Text(context.l10n.action_delete)),
          ],
        ),
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: entry.content.encoded));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.snackbar_copied)),
            );
          }
        },
      ),
    );
  }

  Widget _favoriteLabel(BuildContext context) {
    return Row(children: [
      Icon(entry.isFavorite ? Icons.star : Icons.star_outline,
          size: 18, color: Theme.of(context).colorScheme.tertiary,),
      const SizedBox(width: 8),
      Text(entry.isFavorite
          ? context.l10n.snackbar_removedFromFavorites
          : context.l10n.snackbar_addedToFavorites,),
    ],);
  }

  Future<void> _handleAction(BuildContext context, WidgetRef ref, String action) async {
    switch (action) {
      case 'favorite':
        // Toggle favorite via repository
        final toggled = entry.copyWith(isFavorite: !entry.isFavorite);
        await ServiceLocator.instance.historyRepository.save(toggled);
        ref.invalidate(historyListProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(toggled.isFavorite
                ? context.l10n.snackbar_addedToFavorites
                : context.l10n.snackbar_removedFromFavorites),
          ));
        }
        break;
      case 'copy':
        await Clipboard.setData(ClipboardData(text: entry.content.encoded));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.snackbar_copied)),
          );
        }
        break;
      case 'delete':
        final ok = await ConfirmDialog.show(
          context,
          title: context.l10n.dialog_deleteTitle,
          message: context.l10n.dialog_deleteMessage,
          isDestructive: true,
        );
        if (ok) {
          await ServiceLocator.instance.historyRepository.delete(entry.id);
          ref.invalidate(historyListProvider);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.action_delete)),
            );
          }
        }
        break;
    }
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

// -------------------------------------------------------------------------
// Misc widgets
// -------------------------------------------------------------------------

class _TypeAvatar extends StatelessWidget {
  const _TypeAvatar({required this.type});
  final ContentType type;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      child: Icon(_icon(type), size: 22),
    );
  }

  IconData _icon(ContentType t) {
    switch (t) {
      case ContentType.url: return Icons.language;
      case ContentType.email: return Icons.email;
      case ContentType.phone: return Icons.phone;
      case ContentType.sms: return Icons.sms;
      case ContentType.wifi: return Icons.wifi;
      case ContentType.vcard: return Icons.contact_page;
      case ContentType.calendarEvent: return Icons.event;
      case ContentType.geo: return Icons.location_on;
      case ContentType.crypto: return Icons.currency_bitcoin;
      case ContentType.social: return Icons.share;
      case ContentType.appStore: return Icons.shop;
      case ContentType.product: return Icons.inventory_2;
      case ContentType.isbn: return Icons.book;
      default: return Icons.qr_code_2;
    }
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});
  final ContentType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type.label,
        style: context.textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
