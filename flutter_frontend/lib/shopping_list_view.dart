import 'package:flutter/material.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/shopping_list_filter_options.dart';
import 'package:kaufhansel_client/shopping_list_item_input.dart';
import 'package:kaufhansel_client/shopping_list_item_tile.dart';
import 'package:kaufhansel_client/shopping_list_mode.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class ShoppingListView extends StatefulWidget {
  ShoppingListView(
      {String category, @required ShoppingListFilterOption filter, ShoppingListMode mode = ShoppingListMode.DEFAULT})
      : _category = category,
        _filter = filter,
        _mode = mode,
        _scrollController = ScrollController();

  final ScrollController _scrollController;
  final String _category;
  final ShoppingListMode _mode;
  final ShoppingListFilterOption _filter;

  @override
  _ShoppingListViewState createState() => _ShoppingListViewState();
}

class _ShoppingListViewState extends State<ShoppingListView> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Selector<ShoppingList, Iterable<ShoppingListItem>>(
        selector: (_, shoppingList) =>
            shoppingList.items.where((item) => item.isInCategory(widget._category)).toList(growable: false),
        builder: (context, items, child) {
          return Column(children: [
            _buildProgress(),
            Expanded(child: _buildListView(items, context)),
            Container(
                child: Material(
                    child: ShoppingListItemInput(
                      shoppingListScrollController: widget._scrollController,
                      category: widget._category,
                      enabled: !_loading,
                    ),
                    type: MaterialType.transparency),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))
                ])),
          ]);
        });
  }

  Widget _buildProgress() {
    if (_loading) {
      return LinearProgressIndicator(minHeight: 5);
    }
    return Container();
  }

  Widget _buildListView(List<ShoppingListItem> items, BuildContext context) {
    final tiles = items.where(_isItemVisible).map(_createListTileForItem);
    final dividedTiles = _divideTilesWithKey(tiles, context).toList();

    if (widget._mode == ShoppingListMode.EDITING) {
      return ReorderableListView(
        children: dividedTiles,
        onReorder: (oldIndex, newIndex) => _moveItem(items, oldIndex, newIndex),
        scrollController: widget._scrollController,
      );
    } else {
      return Scrollbar(
          isAlwaysShown: true,
          controller: widget._scrollController,
          child: ListView(
            shrinkWrap: true,
            children: dividedTiles,
            controller: widget._scrollController,
          ));
    }
  }

  bool _isItemVisible(ShoppingListItem item) {
    switch (widget._filter) {
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
        child: ShoppingListItemTile(
          mode: widget._mode,
          enabled: !_loading,
          showUserCategory: widget._category == CATEGORY_ALL,
        ));
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
        SnackBar(content: Text("${item.name} konnte nicht verschoben werden..."), duration: Duration(seconds: 2)),
      );
    } finally {
      setState(() => _loading = false);
    }
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
