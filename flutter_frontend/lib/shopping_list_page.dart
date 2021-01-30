import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/shopping_list_filter_options.dart';
import 'package:kaufhansel_client/shopping_list_mode.dart';
import 'package:kaufhansel_client/shopping_list_view.dart';

class ShoppingListPage extends StatefulWidget {
  final ShoppingListFilterOption _filter;
  final ShoppingListMode _mode;
  final String _initialCategory;
  final List<String> _categories;
  final void Function(String) _onCategoryChanged;

  ShoppingListPage(this._categories, this._filter,
      {ShoppingListMode mode = ShoppingListMode.DEFAULT,
      String initialCategory,
      void Function(String) onCategoryChanged})
      : _mode = mode,
        _initialCategory = initialCategory,
        _onCategoryChanged = onCategoryChanged;

  @override
  _ShoppingListPageState createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> with TickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _createTabController();
  }

  @override
  void didUpdateWidget(covariant ShoppingListPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget._categories.length != widget._categories.length) {
      _createTabController();
    }
  }

  void _createTabController() {
    // If we had a controller before dispose it.
    if (_tabController != null) {
      _tabController.dispose();
    }

    assert(widget._categories.isNotEmpty, "There must be at least one category.");
    assert(widget._categories.contains(widget._initialCategory), "Invalid initial category.");
    final initialIndex = widget._initialCategory != null ? widget._categories.indexOf(widget._initialCategory) : 0;
    _tabController = TabController(length: widget._categories.length, initialIndex: initialIndex, vsync: this);
    _tabController.addListener(this._tabControllerChanged);
  }

  void _tabControllerChanged() {
    if (!_tabController.indexIsChanging && widget._onCategoryChanged != null) {
      widget._onCategoryChanged(widget._categories[_tabController.index]);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
          decoration: BoxDecoration(color: Theme.of(context).primaryColor, boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))
          ]),
          child: Material(
              type: MaterialType.transparency,
              child: TabBar(
                controller: _tabController,
                tabs: widget._categories.map((category) => Tab(text: category)).toList(),
                indicator: BoxDecoration(border: Border(bottom: BorderSide(width: 3, color: Colors.white))),
              ))),
      Expanded(
          child: TabBarView(
              controller: _tabController,
              children: widget._categories
                  .map((category) => ShoppingListView(
                        category: category,
                        filter: widget._filter,
                        mode: widget._mode,
                      ))
                  .toList()))
    ]);
  }
}
