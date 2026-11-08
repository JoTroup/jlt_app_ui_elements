import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlt_app_ui_elements/jlt_app_ui_elements.dart';

class _NavAssets extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final String content;
    if (key == 'test-logo.svg') {
      content =
          '<svg xmlns="http://www.w3.org/2000/svg" width="36" height="36">'
          '<rect width="36" height="36" fill="blue"/></svg>';
    } else if (key == 'test-animation.json') {
      content =
          '{"v":"5.7.4","fr":30,"ip":0,"op":30,"w":32,"h":32,"layers":[]}';
    } else {
      return rootBundle.load(key);
    }
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(content)));
  }
}

void main() {
  for (final direction in Axis.values) {
    for (final compact in [false, true]) {
      for (final expanded in [false, true]) {
        testWidgets(
            '$direction navigation: compact=$compact expanded=$expanded',
            (tester) async {
          final controller = SideBarController()
            ..isCompactDevice = compact
            ..isExpanded = expanded
            ..customLogoUrl = '';
          var settingsTapped = false;
          await tester.pumpWidget(
            DefaultAssetBundle(
              bundle: _NavAssets(),
              child: MaterialApp(
                home: Scaffold(
                  body: SizedBox(
                    width: direction == Axis.horizontal ? 800 : 320,
                    height: direction == Axis.horizontal ? 140 : 600,
                    child: SideNavBar(
                      direction: direction,
                      sideBarController: controller,
                      primaryActions: [
                        SideBarLottieButton(
                          name: 'Home',
                          lottieStringAssetPath: 'test-animation.json',
                          widget: const SizedBox(),
                        ),
                        SideBarLottieButton(
                          name: 'Search',
                          lottieStringAssetPath: 'test-animation.json',
                          widget: const SizedBox(),
                        ),
                      ],
                      settingsActions: [
                        SideBarLottieButton(
                          name: 'Settings',
                          lottieStringAssetPath: 'test-animation.json',
                          widget: const SizedBox(),
                          onTap: () => settingsTapped = true,
                        ),
                      ],
                      logoAssetPath: 'test-logo.svg',
                      appName: 'Test',
                      setState: (VoidCallback callback) => callback(),
                      mounted: true,
                      isExpandable: false,
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          if (compact) {
            expect(tester.widget<Wrap>(find.byType(Wrap).first).direction,
                direction);
          } else {
            expect(tester.widget<Flex>(find.byType(Flex).first).direction,
                direction);
            final buttons = find.byType(InkWell);
            final primary = tester.getCenter(buttons.at(1));
            final nextPrimary = tester.getCenter(buttons.at(2));
            final settings = tester.getCenter(buttons.at(3));
            if (direction == Axis.horizontal) {
              expect(primary.dx, lessThan(nextPrimary.dx));
              expect(primary.dx, lessThan(settings.dx));
            } else {
              expect(primary.dy, lessThan(nextPrimary.dy));
              expect(primary.dy, lessThan(settings.dy));
            }
            await tester.tap(buttons.at(3));
            expect(settingsTapped, isTrue);
          }
          await tester.pumpWidget(const SizedBox());
          controller
            ..isCompactDevice = false
            ..isExpanded = false;
        });
      }
    }
  }

  test('SideNavBar defaults to vertical', () {
    final bar = SideNavBar(
      sideBarController: SideBarController(),
      primaryActions: const [],
      settingsActions: const [],
      logoAssetPath: 'test-logo.svg',
      setState: (VoidCallback callback) => callback(),
      mounted: true,
    );
    expect(bar.direction, Axis.vertical);
  });
}
