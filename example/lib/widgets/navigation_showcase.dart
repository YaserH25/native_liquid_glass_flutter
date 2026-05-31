import 'package:flutter/material.dart';
import 'package:native_liquid_glass_flutter/native_liquid_glass_flutter.dart';

import 'example_section.dart';

class NavigationShowcase extends StatefulWidget {
  const NavigationShowcase({super.key});

  @override
  State<NavigationShowcase> createState() => NavigationShowcaseState();
}

class NavigationShowcaseState extends State<NavigationShowcase> {
  int selectedIndex = 0;
  int directionIndex = 0;
  String lastAppBarAction = 'None';

  static const List<String> tabLabels = <String>['Today', 'Saved', 'Settings'];

  TextDirection get textDirection {
    return directionIndex == 0 ? TextDirection.ltr : TextDirection.rtl;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ExampleSection(
          title: 'Native app bar',
          children: <Widget>[
            Text('Direction: ${directionIndex == 0 ? 'LTR' : 'RTL'}'),
            Text('Last app bar action: $lastAppBarAction'),
            const SizedBox(height: 10),
            LiquidGlassSegmentedControl(
              selectedIndex: directionIndex,
              onChanged: (index) => setState(() => directionIndex = index),
              segments: const <LiquidGlassSegment>[
                LiquidGlassSegment(label: 'LTR'),
                LiquidGlassSegment(label: 'RTL'),
              ],
            ),
            const SizedBox(height: 12),
            Directionality(
              textDirection: textDirection,
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: LiquidGlassAppBar(
                  title: const Text('App bar title'),
                  automaticallyImplyLeading: false,
                  nativeActions: const <LiquidGlassAppBarAction>[
                    LiquidGlassAppBarAction(
                      title: 'Bookmark',
                      value: 'bookmark',
                      nativeSymbol: 'bookmark',
                    ),
                    LiquidGlassAppBarAction(
                      title: 'More',
                      value: 'more',
                      nativeSymbol: 'ellipsis.circle',
                      menuActions: <LiquidGlassAction>[
                        LiquidGlassAction(
                          title: 'Share',
                          value: 'share',
                          nativeSymbol: 'square.and.arrow.up',
                        ),
                        LiquidGlassAction(
                          title: 'Delete',
                          value: 'delete',
                          role: LiquidGlassActionRole.destructive,
                          nativeSymbol: 'trash',
                        ),
                      ],
                    ),
                  ],
                  onNativeActionSelected: updateAppBarAction,
                ),
              ),
            ),
            const SizedBox(height: 12),
            LiquidGlassButton(
              onPressed: openDetail,
              child: const Text('Open detail'),
            ),
          ],
        ),
        ExampleSection(
          title: 'Native app bar route',
          children: const <Widget>[
            Text('Detail routes use the same native app bar bridge.'),
          ],
        ),
        Directionality(
          textDirection: textDirection,
          child: ExampleSection(
            title: 'Native tab bar',
            children: <Widget>[
              Text('Selection: ${tabLabels[selectedIndex]}'),
              const Text('Saved badge: 2'),
              const SizedBox(height: 10),
              LiquidGlassTabBar(
                selectedIndex: selectedIndex,
                onSelected: (index) => setState(() => selectedIndex = index),
                margin: EdgeInsets.zero,
                items: const <LiquidGlassTabItem>[
                  LiquidGlassTabItem(
                    icon: Icon(Icons.calendar_today_outlined),
                    selectedIcon: Icon(Icons.calendar_today_rounded),
                    label: Text('Today'),
                    nativeSymbol: 'calendar',
                  ),
                  LiquidGlassTabItem(
                    icon: Icon(Icons.bookmark_border_rounded),
                    selectedIcon: Icon(Icons.bookmark_rounded),
                    label: Text('Saved'),
                    nativeSymbol: 'bookmark',
                    nativeSelectedSymbol: 'bookmark.fill',
                    badge: '2',
                  ),
                  LiquidGlassTabItem(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings_rounded),
                    label: Text('Settings'),
                    nativeSymbol: 'gearshape',
                    nativeSelectedSymbol: 'gearshape.fill',
                    enabled: false,
                  ),
                ],
              ),
            ],
          ),
        ),
        ExampleSection(
          title: 'LiquidGlassScaffold',
          children: <Widget>[
            Text(
              'Bottom inset: '
              '${LiquidGlassScaffold.scrollBottomPadding(context).round()}',
            ),
          ],
        ),
      ],
    );
  }

  Future<void> openDetail() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) {
          return Directionality(
            textDirection: textDirection,
            child: const NavigationDetailPage(),
          );
        },
      ),
    );
  }

  void updateAppBarAction(String value) {
    setState(() {
      lastAppBarAction = switch (value) {
        'bookmark' => 'Bookmark',
        'share' => 'Share',
        'delete' => 'Delete',
        _ => value,
      };
    });
  }
}

class NavigationDetailPage extends StatelessWidget {
  const NavigationDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LiquidGlassScaffold(
      appBar: LiquidGlassAppBar(title: Text('Detail')),
      body: Center(child: Text('Detail screen')),
    );
  }
}
