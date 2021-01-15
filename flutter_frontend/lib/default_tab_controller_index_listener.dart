import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class DefaultTabControllerIndexListener extends StatefulWidget {
  const DefaultTabControllerIndexListener();

  @override
  _DefaultTabControllerIndexListenerState createState() => _DefaultTabControllerIndexListenerState();
}

class _DefaultTabControllerIndexListenerState extends State<DefaultTabControllerIndexListener> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tabController = DefaultTabController.of(context);
    Provider.of<ShoppingListTabSelection>(context, listen: false).currentTabIndex = tabController.index;
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

  @override
  void dispose() {
    super.dispose();
    DefaultTabController.of(context).removeListener(_onTabControllerChanged);
  }
}
