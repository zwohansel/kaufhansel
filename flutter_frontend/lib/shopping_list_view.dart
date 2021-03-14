import 'package:flutter/material.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/shopping_list_filter_options.dart';
import 'package:kaufhansel_client/shopping_list_item_input.dart';
import 'package:kaufhansel_client/shopping_list_item_tile.dart';
import 'package:kaufhansel_client/shopping_list_mode.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'model.dart';

class ShoppingListView extends StatefulWidget {
  ShoppingListView({
    @required this.filter,
    @required this.onRefresh,
    this.category,
    this.mode = ShoppingListModeOption.DEFAULT,
  });

  final ShoppingListFilterOption filter;
  final Future<void> Function() onRefresh;
  final String category;
  final ShoppingListModeOption mode;

  @override
  _ShoppingListViewState createState() => _ShoppingListViewState();
}

class _ShoppingListViewState extends State<ShoppingListView> {
  bool _loading = false;
  bool _doNotShowProgressBarWhileLoading = false;
  ScrollController _scrollController;
  String _shoppingListItemInputText;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ShoppingList, Tuple2<Iterable<ShoppingListItem>, ShoppingListPermissions>>(
        selector: (_, shoppingList) => Tuple2(
            shoppingList.items.where((item) => item.isInCategory(widget.category)).toList(growable: false),
            shoppingList.info.permissions),
        builder: (context, tuple, child) {
          return Column(children: [
            _buildProgress(),
            _buildListView(context, tuple.item1, tuple.item2.canEditItems),
            _buildItemInput(tuple.item2.canEditItems),
          ]);
        });
  }

  Widget _buildProgress() {
    if (_loading && !_doNotShowProgressBarWhileLoading) {
      return LinearProgressIndicator(minHeight: 5);
    }
    return Container();
  }

  Widget _buildListView(BuildContext context, List<ShoppingListItem> items, bool canEditItems) {
    Iterable<ShoppingListItem> visibleItems = items.where(_isItemVisible);
    if (_shoppingListItemInputText != null && _shoppingListItemInputText.isNotEmpty) {
      final filterText = _shoppingListItemInputText.trim().toLowerCase();
      visibleItems = visibleItems.where((item) => item.name.toLowerCase().contains(filterText));
    }

    final dividedTiles = _divideTilesWithKey(visibleItems.map(_createListTileForItem), context).toList();

    if (widget.mode == ShoppingListModeOption.EDITING && canEditItems) {
      return Expanded(
          child: ReorderableListView(
        children: dividedTiles,
        onReorder: (oldIndex, newIndex) => _moveItem(items, oldIndex, newIndex),
        scrollController: _scrollController,
      ));
    } else {
      return Expanded(
        child: Scrollbar(
          isAlwaysShown: true,
          controller: _scrollController,
          child: RefreshIndicator(
            onRefresh: _refreshList,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(), // allow overscroll to trigger refresh indicator
              shrinkWrap: true,
              children: dividedTiles,
              controller: _scrollController,
            ),
          ),
        ),
      );
    }
  }

  bool _isItemVisible(ShoppingListItem item) {
    switch (widget.filter) {
      case ShoppingListFilterOption.CHECKED:
        return item.checked;
      case ShoppingListFilterOption.UNCHECKED:
        return !item.checked;
      case ShoppingListFilterOption.ALL:
      default:
        return true;
    }
  }

  Widget _createListTileForItem(ShoppingListItem item) {
    return ChangeNotifierProvider<ShoppingListItem>.value(
        value: item,
        key: ValueKey(item.id),
        child: Selector<ShoppingList, ShoppingListPermissions>(
            selector: (_, shoppingList) => shoppingList.info.permissions,
            builder: (context, permissions, child) => ShoppingListItemTile(
                  mode: widget.mode,
                  enabled: !_loading,
                  showUserCategory: widget.category == CATEGORY_ALL,
                  canCheckItems: permissions.canCheckItems,
                  canEditItems: permissions.canEditItems,
                )));
  }

  void _moveItem(List<ShoppingListItem> itemsOfThisList, int oldIndexInThisList, int newIndexInThisList) async {
    setState(() => _loading = true);
    final RestClient client = RestClientWidget.of(context);
    final ShoppingList list = Provider.of<ShoppingList>(context, listen: false);
    final ShoppingListItem item = itemsOfThisList[oldIndexInThisList];
    final oldIndex = list.items.indexOf(item);
    try {
      int targetIndexInCompleteList;
      if (newIndexInThisList < itemsOfThisList.length) {
        targetIndexInCompleteList = list.items.indexOf(itemsOfThisList[newIndexInThisList]);
      } else {
        targetIndexInCompleteList = list.items.indexOf(itemsOfThisList.last) + 1;
      }
      // Perform the move even if the move request to the server fails.
      // Otherwise the item is first moved back to its original position
      // and then jumps to the new position once the request is finished.
      list.moveItem(item, targetIndexInCompleteList);
      await client.moveShoppingListItem(list.id, item, targetIndexInCompleteList);
    } catch (e) {
      // restore the old position on error
      list.moveItem(item, oldIndex);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context).exceptionMoveItemFailed(item.name)),
            duration: Duration(seconds: 2)),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _refreshList() async {
    try {
      setState(() {
        _loading = true;
        _doNotShowProgressBarWhileLoading = true;
      });
      await widget.onRefresh();
    } finally {
      setState(() {
        _loading = false;
        _doNotShowProgressBarWhileLoading = false;
      });
    }
  }

  Widget _buildItemInput(bool canEditItems) {
    if (!canEditItems) {
      return Container();
    }

    return Container(
        child: Material(
            child: ShoppingListItemInput(
              shoppingListScrollController: _scrollController,
              category: widget.category,
              enabled: !_loading,
              onChange: (text) => setState(() => _shoppingListItemInputText = text),
            ),
            type: MaterialType.transparency),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))
        ]));
  }
}

List<Widget> _divideTilesWithKey(Iterable<Widget> tiles, BuildContext context) {
  final Decoration decoration = BoxDecoration(
    border: Border(
      bottom: Divider.createBorderSide(context),
    ),
  );

  return tiles.map((tile) {
    return DecoratedBox(
      key: tile.key,
      position: DecorationPosition.foreground,
      decoration: decoration,
      child: tile,
    );
  }).toList(growable: false);
}
