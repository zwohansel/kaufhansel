import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/rest_client.dart';
import 'package:kaufhansel_client/shopping_list_item_input.dart';
import 'package:kaufhansel_client/shopping_list_view.dart';
import 'package:kaufhansel_client/synced_shoppinglist.dart';
import 'package:kaufhansel_client/utils/update_check.dart';
import 'package:kaufhansel_client/widgets/category_manager_dialog.dart';
import 'package:kaufhansel_client/widgets/link.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class ShoppingListPage extends StatefulWidget {
  final List<String> _categories;
  final bool editMode;
  final String? initialCategory;
  final void Function(String)? onCategoryChanged;
  final Future<void> Function() onRefresh;
  final Update update;

  ShoppingListPage(
    this._categories, {
    this.editMode = false,
    this.initialCategory,
    this.onCategoryChanged,
    required this.update,
    required this.onRefresh,
  });

  @override
  _ShoppingListPageState createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> with TickerProviderStateMixin {
  TabController? _tabController;
  bool _showInfoBox = true;
  bool _loading = false;
  bool _doNotShowProgressBarWhileLoading = false;
  String? _filterText;
  List<ScrollController> _scrollControllers = [];

  @override
  void initState() {
    super.initState();
    _createTabController();
    _createScrollControllers();
  }

  @override
  void didUpdateWidget(covariant ShoppingListPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget._categories.length != widget._categories.length) {
      _createTabController();
      _createScrollControllers();
    }
  }

  void _createTabController() {
    // If we had a controller before dispose it.
    if (_tabController != null) {
      _tabController?.dispose();
    }

    final initialCategory = widget.initialCategory;
    assert(widget._categories.isNotEmpty, "There must be at least one category.");
    assert(initialCategory == null || widget._categories.contains(initialCategory), "Invalid initial category.");
    final initialIndex = initialCategory != null ? widget._categories.indexOf(initialCategory) : 0;
    _tabController = TabController(length: widget._categories.length, initialIndex: initialIndex, vsync: this);
    _tabController?.addListener(this._tabControllerChanged);
  }

  void _tabControllerChanged() {
    final onCategoryChanged = widget.onCategoryChanged;
    if (!(_tabController?.indexIsChanging ?? false) && onCategoryChanged != null) {
      onCategoryChanged(widget._categories[_tabController?.index ?? 0]);
    }
  }

  void _createScrollControllers() {
    if (_scrollControllers.length > widget._categories.length) {
      _scrollControllers
          .getRange(widget._categories.length, _scrollControllers.length)
          .forEach((controller) => controller.dispose());
      _scrollControllers.removeRange(widget._categories.length, _scrollControllers.length);
    } else if (_scrollControllers.length < widget._categories.length) {
      while (_scrollControllers.length != widget._categories.length) {
        _scrollControllers.add(ScrollController());
      }
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _scrollControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInfoBox(),
        Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor, boxShadow: [
              BoxShadow(color: Colors.grey.withValues(alpha: 0.5), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))
            ]),
            child: Material(
                type: MaterialType.transparency,
                child: TabBar(
                  controller: _tabController,
                  tabs: widget._categories.map((category) => _buildTab(category, context)).toList(),
                  indicator: BoxDecoration(border: Border(bottom: BorderSide(width: 3, color: Colors.white))),
                ))),
        _buildProgress(),
        Expanded(
            child: TabBarView(
          controller: _tabController,
          children: [
            for (var i = 0; i < widget._categories.length; i++)
              ShoppingListView(
                category: widget._categories[i],
                scrollController: _scrollControllers[i],
                enabled: !_loading,
                filterText: _filterText,
                editMode: widget.editMode,
                onRefresh: _refreshList,
                onItemMoved: _moveItem,
              )
          ],
        )),
        _buildItemInput(),
      ],
    );
  }

  Widget _buildInfoBox() {
    if (!_showInfoBox) {
      return Container();
    }

    final _infoMessage = _buildInfoMessage();
    final _newVersionAvailable = _buildNewVersionAvailable();
    final _dismissButton = _buildDismissButton();

    if (_infoMessage == null && _newVersionAvailable == null) {
      return Container();
    }

    return Container(
      color: widget.update.isCritical() ? Colors.blueAccent : Theme.of(context).primaryColorDark,
      child: Padding(
        padding: EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
        child: Column(
          children: [
            _infoMessage ?? Container(),
            SizedBox(height: 10),
            _newVersionAvailable ?? Container(),
            SizedBox(height: 10),
            _dismissButton,
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget? _buildInfoMessage() {
    if (!widget.update.hasInfoMessage()) {
      return null;
    }

    final critical = widget.update.infoMessage?.severity == InfoMessageSeverity.CRITICAL;
    final message = widget.update.infoMessage?.message ?? "";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(critical ? Icons.warning_amber_outlined : Icons.info_outlined, color: Colors.white, size: 24),
        SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: Text(message, style: TextStyle(color: Colors.white))),
            ],
          ),
        )
      ],
    );
  }

  Widget? _buildNewVersionAvailable() {
    if (!widget.update.isNewVersionAvailable()) {
      return null;
    }

    List<Widget> obligatoryUpdateInfo = widget.update.isBreakingChange()
        ? [
            SizedBox(height: 10),
            Flexible(
              child: Text(
                AppLocalizations.of(context).newerVersionAvailableObligatoryUpdate,
                style: TextStyle(color: Colors.white),
              ),
            )
          ]
        : [];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.get_app, color: Colors.white, size: 24),
        SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Link(
                  AppLocalizations.of(context).downloadLink,
                  text: AppLocalizations.of(context).newerVersionAvailable(widget.update.latestVersion.toString()),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ...obligatoryUpdateInfo,
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDismissButton() {
    final dismissLabelText = widget.update.infoMessage?.dismissLabel ?? AppLocalizations.of(context).ok;

    return Align(
      alignment: Alignment.bottomRight,
      child: OutlinedButton(
        style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.white30)),
        onPressed: () => setState(() {
          widget.update.confirmMessage();
          _showInfoBox = false;
        }),
        child: Text(dismissLabelText),
      ),
    );
  }

  Widget _buildProgress() {
    if (_loading && !_doNotShowProgressBarWhileLoading) {
      return LinearProgressIndicator(minHeight: 5);
    }
    return Container();
  }

  Widget _buildTab(String category, BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // necessary to detected a long press in the complete tab not only the text part
      onLongPress: () {
        final list = Provider.of<SyncedShoppingList>(context, listen: false);
        showDialog(
          context: context,
          builder: (context) => CategoryManager(
            list: list,
            initialSelected: category,
            onClose: () => Navigator.pop(context),
          ),
        );
      },
      child: SizedBox(
        width: double.infinity,
        child: Tab(
          child: Text(
            category,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildItemInput() {
    final canEditItems = Provider.of<SyncedShoppingList>(context).info.permissions.canEditItems;
    if (!canEditItems) {
      return Container();
    }

    return Container(
        child: Material(
            child: ShoppingListItemInput(
              shoppingListScrollController: _scrollControllers[_tabController?.index ?? 0],
              category: widget._categories[_tabController?.index ?? 0],
              enabled: !_loading,
              onChange: (text) => setState(() => _filterText = text),
            ),
            type: MaterialType.transparency),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.5), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))
        ]));
  }

  void _moveItem(List<SyncedShoppingListItem> itemsOfThisList, int oldIndexInThisList, int newIndexInThisList) async {
    if (_loading == true) {
      return;
    }
    setState(() => _loading = true);
    final SyncedShoppingList list = Provider.of<SyncedShoppingList>(context, listen: false);
    try {
      await list.moveItemsInSubList(itemsOfThisList, oldIndexInThisList, newIndexInThisList);
    } on HttpResponseException catch (e) {
      log("Could not move item from $oldIndexInThisList to $newIndexInThisList", error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).exceptionMoveItemFailed), duration: Duration(seconds: 2)),
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
}
