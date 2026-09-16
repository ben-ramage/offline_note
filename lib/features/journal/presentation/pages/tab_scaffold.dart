import 'package:flutter/material.dart';

class TabScaffold extends StatelessWidget {
  final Widget? header;
  final String title;
  final List<Tab> tabs;
  final List<Widget> tabViews;

  const TabScaffold({
    super.key,
    this.header,
    required this.title,
    required this.tabs,
    required this.tabViews,
  }) : assert(tabs.length == tabViews.length);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        body: Column(
          children: [
            ?header,
            TabBar(tabs: tabs),
            Expanded(child: TabBarView(children: tabViews)),
          ],
        ),
      ),
    );
  }
}
