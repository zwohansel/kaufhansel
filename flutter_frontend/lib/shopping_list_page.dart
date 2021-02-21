import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaufhansel_client/generated/l10n.dart';
import 'package:kaufhansel_client/shopping_list_filter_options.dart';
import 'package:kaufhansel_client/shopping_list_mode.dart';
import 'package:kaufhansel_client/shopping_list_view.dart';
import 'package:kaufhansel_client/utils/update_check.dart';
import 'package:kaufhansel_client/widgets/link.dart';

import 'model.dart';

class ShoppingListPage extends StatefulWidget {
  final ShoppingListFilterOption _filter;
  final ShoppingListMode _mode;
  final String _initialCategory;
  final List<String> _categories;
  final void Function(String) _onCategoryChanged;
  final Update _update;

  ShoppingListPage(this._categories, this._filter,
      {ShoppingListMode mode = ShoppingListMode.DEFAULT,
      String initialCategory,
      void Function(String) onCategoryChanged,
      Update update})
      : _mode = mode,
        _initialCategory = initialCategory,
        _onCategoryChanged = onCategoryChanged,
        _update = update;

  @override
  _ShoppingListPageState createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> with TickerProviderStateMixin {
  TabController _tabController;
  bool _showInfoBox = true;

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
      _buildInfoBox(),
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
      color: Theme.of(context).primaryColorDark,
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

  Widget _buildInfoMessage() {
    if (widget._update.infoMessage == null) {
      return null;
    }

    final critical = widget._update.infoMessage.severity == InfoMessageSeverity.CRITICAL;
    final message = widget._update.infoMessage.message;

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
              // SizedBox(width: 20),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildNewVersionAvailable() {
    if (!widget._update.isNewVersionAvailable()) {
      return null;
    }

    final obligatoryUpdateInfo = widget._update.isBreakingChange()
        ? Flexible(
            child: Text(
              AppLocalizations.of(context).newerVersionAvailableObligatoryUpdate,
              style: TextStyle(color: Colors.white),
            ),
          )
        : Container();

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
                  text: AppLocalizations.of(context).newerVersionAvailable(widget._update.latestVersion.toString()),
                  style: TextStyle(color: Colors.white, decoration: TextDecoration.underline),
                ),
              ),
              obligatoryUpdateInfo,
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDismissButton() {
    final dismissLabelText = widget._update?.infoMessage?.dismissLabel ?? AppLocalizations.of(context).ok;

    return Align(
      alignment: Alignment.bottomRight,
      child: OutlinedButton(
        style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact, primary: Colors.white, side: BorderSide(color: Colors.white24)),
        onPressed: () => setState(() => _showInfoBox = false),
        child: Text(dismissLabelText),
      ),
    );
  }
}
