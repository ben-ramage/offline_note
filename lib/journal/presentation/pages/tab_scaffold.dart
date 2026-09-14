import 'package:flutter/material.dart';

class TabScaffold extends StatelessWidget {
  final String title;
  final List<Tab> tabs;
  final List<Widget> tabViews;

  const TabScaffold({
    super.key,
    required this.title,
    required this.tabs,
    required this.tabViews,
  }) : assert(tabs.length == tabViews.length);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          centerTitle: true,
          bottom: TabBar(tabs: tabs),
        ),
        body: Expanded(child: TabBarView(children: tabViews)),
      ),
    );
  }
}
