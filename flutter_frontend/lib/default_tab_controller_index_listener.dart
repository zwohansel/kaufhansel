import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class DefaultTabControllerIndexListener extends StatefulWidget {
  @override
  _DefaultTabControllerIndexListenerState createState() => _DefaultTabControllerIndexListenerState();
}

class _DefaultTabControllerIndexListenerState extends State<DefaultTabControllerIndexListener> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tabController = DefaultTabController.of(context);

    // Flutter does not want us to change the currentTabIndex of ShoppingListTabSelection
    // here since didChangeDependencies is executed while building the DefaultTabControllerIndexListener widget.
    // The consumers of the ShoppingListTabSelection (like ShoppingListTitle) will be marked as
    // "needs to be built" when we change the index.
    // If we do this here it could lead to a build loop (e.g. if ShoppingListTitle is an ancestor of this widget).
    // Therefore we defer the change until the current build is done.
    // We do not actually have this problem as ShoppingListTitle and DefaultTabControllerIndexListener are in
    // different branches of the build tree... however; We do not want to be annoyed by the warning.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShoppingListTabSelection>(context, listen: false).currentTabIndex = tabController.index;
    });
    tabController.addListener(_onTabControllerChanged);
  }

  void _onTabControllerChanged() {
    final tabController = DefaultTabController.of(context);
    if (!tabController.indexIsChanging) {
      Provider.of<ShoppingListTabSelection>(context, listen: false).currentTabIndex = tabController.index;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
