import 'dart:math';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:jlt_app_theme_handler/jlt_app_theme_handler.dart';
import 'package:lottie/lottie.dart';
import 'package:wave_widget/wave_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SideBarController {
  static final SideBarController _instance = SideBarController._internal();
  factory SideBarController() => _instance;
  SideBarController._internal();

  bool isExpanded = false;
  bool isCompactDevice = false;


  Widget currentMenu = Container();

  Tween<Offset> offsetAnimationPrimary = Tween(
      begin: const Offset(0,0),
      end: const Offset(0,0)
  );

  Tween<Offset> offsetAnimationSecondary = Tween(
      begin: const Offset(0,0),
      end: const Offset(0,0)
  );
}

class SideBarLottieButton {
  final String name;
  final String lottieStringAssetPath;
  Widget widget = Container();
  Function? onTap;
  final AnimationController lottieController;

  SideBarLottieButton({required this.name, required this.lottieStringAssetPath, required this.widget, required this.lottieController, this.onTap});
}

class AppUiElements {
  Widget sideNavBar({
    required SideBarController sideBarController,
    required List<SideBarLottieButton> primaryActions,
    required List<SideBarLottieButton> settingsActions,
    required String logoAssetPath,
    required String appName,
    required BuildContext context,
    required TickerProvider tickerProvider,
    required Function setState,
    required bool mounted,
  }) {
    if (sideBarController.isCompactDevice) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Wrap(
            direction: Axis.vertical,
            children: List.generate(primaryActions.length, (index) {
              return AppUiElements().animatedNavButton(
                context: context,
                onTap: () {
                  handleNavigationChange(
                      selectedIndex: index,
                      updateMenu: setState,
                      replacementWidget: primaryActions[index].widget,
                      context: context,
                      mounted: mounted,
                      sideBarController: sideBarController,
                  );
                },
                hoverAnimationController: primaryActions[index].lottieController,
                lottieString: primaryActions[index].lottieStringAssetPath,
                setState: setState,
                selectedHighlightRightIndex: index,
                menuNameString: primaryActions[index].name,
                expandedMenuTitle: false,
                isCompactView: sideBarController.isCompactDevice,
              );
            }),
          ),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        spacing: 16,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: sideBarController.isExpanded ? EdgeInsets.only(left: 0, right: 0, top: 24, bottom: 24) : EdgeInsets.all(24),
            child: Wrap(
              spacing: sideBarController.isExpanded ? 16 : 0,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if(logoAssetPath.endsWith(".svg"))
                  SvgPicture.asset(logoAssetPath, width: 36, height: 36)
                else
                  Image.asset(logoAssetPath, width: 36, height: 36),
                AnimatedSize(
                  duration: Duration(milliseconds: 100),
                  child: SizedBox(
                    width: sideBarController.isExpanded ? null : 0,
                    child: ClipRect(
                      child: Text(
                        appName.toUpperCase(),
                        overflow: TextOverflow.clip,
                        softWrap: false,
                        style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(child: Container()),

          Wrap(
            direction: Axis.vertical,
            children: List.generate(primaryActions.length, (index) {
              return AppUiElements().animatedNavButton(
                context: context,
                onTap: () {
                  handleNavigationChange(
                      selectedIndex: index,
                      updateMenu: setState,
                      replacementWidget: primaryActions[index].widget,
                      context: context,
                      mounted: mounted,
                      sideBarController: sideBarController
                  );
                },
                hoverAnimationController: primaryActions[index].lottieController,
                lottieString: primaryActions[index].lottieStringAssetPath,
                setState: setState,
                selectedHighlightRightIndex: index,
                menuNameString: primaryActions[index].name,
                expandedMenuTitle:  sideBarController.isExpanded,
                isCompactView:  sideBarController.isCompactDevice,
              );
            }),
          ),

          Expanded(child: Container()),

          if (!AppTheme().getDeviceSmall())
            Row(
              children: [
                Center(
                  child: AnimatedRotation(
                    turns: sideBarController.isExpanded ? 0 : 0.5,
                    duration: Duration(milliseconds: 300),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          sideBarController.isExpanded = !sideBarController.isExpanded;
                        });
                      },
                      icon: Icon(Icons.arrow_left, color: Colors.black38),
                    ),
                  ),
                ),
              ],
            ),

          Wrap(
            direction: Axis.vertical,
            children: List.generate(settingsActions.length, (index) {
              return AppUiElements().animatedNavButton(
                context: context,
                onTap: () {
                  settingsActions[index].onTap!();
                },
                hoverAnimationController: settingsActions[index].lottieController,
                lottieString: settingsActions[index].lottieStringAssetPath,
                setState: setState,
                menuNameString: settingsActions[index].name,
                expandedMenuTitle: sideBarController.isExpanded,
                isCompactView: sideBarController.isCompactDevice,
              );
            }),
          ),
        ],
      ),
    );
  }

  /// HELPER FUNCTIONS
  void handleNavigationChange({
    required SideBarController sideBarController,
    required BuildContext context,
    required int selectedIndex,
    required Widget replacementWidget,
    required Function? updateMenu,
    required bool mounted,
    bool forceDisableAnimation = false,
  }) {

    bool disableAnimation = false;
    Offset offsetPrimary = const Offset(0, 0);
    Offset offsetSecondary = const Offset(0, 0);
    Widget returnContent = Container();

    returnContent = replacementWidget;

    if (AppTheme().currentViewIndex > selectedIndex) {
      offsetPrimary = Offset(0, MediaQuery.of(context).size.width > MediaQuery.of(context).size.height ? -2 : -1.2);
      offsetSecondary = Offset(0, MediaQuery.of(context).size.width > MediaQuery.of(context).size.height ? 2 : 1.2);
    }

    if (AppTheme().currentViewIndex < selectedIndex) {
      offsetPrimary = Offset(0, MediaQuery.of(context).size.width > MediaQuery.of(context).size.height ? 2 : 1.2);
      offsetSecondary = Offset(0, MediaQuery.of(context).size.width > MediaQuery.of(context).size.height ? -2 : -1.2);
    }
    AppTheme().currentViewIndex = selectedIndex;

    sideBarController.offsetAnimationPrimary = Tween<Offset>(begin: offsetPrimary, end: Offset.zero);
    sideBarController.offsetAnimationSecondary = Tween<Offset>(begin: Offset.zero, end: offsetSecondary);

    sideBarController.currentMenu = disableAnimation == false
        ? PageTransitionSwitcher(
            child: returnContent,
            transitionBuilder: (Widget child, Animation<double> primaryAnimation, Animation<double> secondaryAnimation) {
              return Align(
                alignment: Alignment.topCenter,
                child: SlideTransition(
                  position: sideBarController.offsetAnimationPrimary.animate(CurvedAnimation(parent: primaryAnimation, curve: Curves.fastEaseInToSlowEaseOut)),
                  child: SlideTransition(
                    position: sideBarController.offsetAnimationSecondary.animate(CurvedAnimation(parent: secondaryAnimation, curve: Curves.fastEaseInToSlowEaseOut)),
                    child: child,
                  ),
                ),
              );
            },
          )
        : returnContent;

    if (mounted) {
      if (updateMenu != null) {
        updateMenu(() {});
      }
    }
  }

  Widget animatedNavButton({
    required BuildContext context,
    required Function onTap,
    required hoverAnimationController,
    required menuNameString,
    required lottieString,
    required setState,
    required bool expandedMenuTitle,
    required bool isCompactView,
    double? widthOverride,
    double? heightOverride,
    int? selectedHighlightRightIndex,
  }) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: isCompactView ? Alignment.topCenter : Alignment.centerRight,
        children: [
          if (selectedHighlightRightIndex != null)
            RotatedBox(
              quarterTurns: isCompactView ? 1 : 0,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(color: AppTheme().getPrimaryColour(), borderRadius: AppTheme().getAppRadius()),
                width: AppTheme().currentViewIndex == selectedHighlightRightIndex ? 3 : 0,
                height: AppTheme().currentViewIndex == selectedHighlightRightIndex ? heightOverride ?? 32 : 0,
                child: Column(),
              ),
            ),

          InkWell(
            onTap: () => onTap(),
            onHover: (value) {
              if (value) {
                hoverAnimationController.forward().then((value) => hoverAnimationController.reset());
              }
            },
            child: Padding(
              padding: EdgeInsets.only(left: AppTheme().getAppPadding().left, right: AppTheme().getAppPadding().right, top: AppTheme().getAppPadding().top / 2, bottom: AppTheme().getAppPadding().bottom / 2),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                children: [
                  Lottie.asset(
                    lottieString,
                    width: widthOverride ?? 32,
                    height: heightOverride ?? 32,
                    controller: hoverAnimationController,
                    onLoaded: (p0) {
                      setState(() {
                        hoverAnimationController.duration = p0.duration;
                      });
                    },
                  ),
                  if (expandedMenuTitle) Container(width: 10),
                  AnimatedSize(
                    duration: Duration(milliseconds: 200),
                    curve: Curves.fastEaseInToSlowEaseOut,
                    child: Container(
                      constraints: BoxConstraints(minWidth: expandedMenuTitle ? 125 : 0, maxWidth: expandedMenuTitle ? 150 : 0),
                      width: expandedMenuTitle ? null : 0,
                      height: expandedMenuTitle ? null : 0,
                      child: ClipRect(child: Text(expandedMenuTitle ? menuNameString : "")),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showUserDetailsDialog({required BuildContext context, required tickerProvider, required void Function(VoidCallback fn) setState, required Widget contentOverride, List<Widget>? overrideActions}) {
    AnimationController hoverAnimationController = AnimationController(vsync: tickerProvider);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          clipBehavior: Clip.hardEdge,
          titlePadding: EdgeInsets.all(0),
          title: Stack(
            alignment: Alignment.center,
            children: [
              RotatedBox(
                quarterTurns: 2,
                child: WavesWidget(
                  amplitude: 5,
                  size: Size(double.infinity, 60),
                  waveLayers: [WaveLayer.solid(duration: 30000, heightFactor: 0.9, color: AppTheme().getPrimaryColour())],
                ),
              ),
              Row(
                spacing: 16,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    child: Lottie.asset(
                      "assets/lotties/main-account.json",
                      controller: hoverAnimationController,
                      width: 32,
                      height: 32,
                      onLoaded: (p0) {
                        hoverAnimationController.duration = p0.duration;
                        hoverAnimationController.reset();
                        hoverAnimationController.forward().then((value) => hoverAnimationController.stop());
                      },
                    ),
                  ),
                  Text('User Details', style: AppTheme().primarySubMenuHeadingStyle.copyWith(color: Colors.white)),
                ],
              ),
            ],
          ),
          content: Container(
            padding: AppTheme().getAppPadding(),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6, minWidth: 400),
            child: SingleChildScrollView(child: contentOverride),
          ),
          actions:
              overrideActions ??
              <Widget>[
                TextButton(
                  style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge),
                  child: const Text('close'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
        );
      },
    );
  }

  ClipRRect menuHeroWidget({required BuildContext context, required TickerProvider tickerProvider, String? lottieAsset, required String title, Widget? functionWidget, Widget? contentWidget, bool? disableWidget}) {
    AnimationController hoverAnimationController = AnimationController(vsync: tickerProvider);

    return ClipRRect(
      borderRadius: AppTheme().getAppRadius().copyWith(bottomLeft: Radius.zero, bottomRight: Radius.zero),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RotatedBox(
            quarterTurns: 2,
            child: WavesWidget(
              amplitude: 5,
              size: Size(double.infinity, 90),

              waveLayers: [WaveLayer.solid(duration: 30000, heightFactor: 0.9, color: AppTheme().getPrimaryColour())],
            ),
          ),
          Padding(
            padding: AppTheme().getAppPadding().copyWith(top: 0, bottom: 8),
            child: Row(
              spacing: 16,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ColorFiltered(
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  child: Lottie.asset(
                    lottieAsset ?? "assets/lotties/main-account.json",
                    controller: hoverAnimationController,
                    width: 32,
                    height: 32,
                    onLoaded: (p0) {
                      hoverAnimationController.duration = p0.duration;
                      hoverAnimationController.reset();
                      hoverAnimationController.forward().then((value) => hoverAnimationController.stop());
                    },
                  ),
                ),
                Expanded(
                  child: Text(title, style: AppTheme().primarySubMenuHeadingStyle.copyWith(color: Colors.white)),
                ),
                if (functionWidget != null) functionWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration settingsFormFieldDecoration({required String labelText, String? hintText}) {
    return InputDecoration(floatingLabelBehavior: FloatingLabelBehavior.always, label: Text(labelText), hintText: hintText);
  }

  Widget settingsMenuRow({required IconData icon, required String title, Widget? functionWidget, Widget? contentWidget, bool? disableWidget}) {
    return IgnorePointer(
      ignoring: disableWidget ?? false,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme().getAppRadius(),
          border: Border.all(color: Colors.black12, width: 1),
        ),
        foregroundDecoration: disableWidget != null && disableWidget ? BoxDecoration(color: Colors.black45, borderRadius: AppTheme().getAppRadius()) : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 16,
              children: [
                Row(
                  spacing: 16,
                  children: [
                    Icon(icon),
                    Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ],
                ),
                if (functionWidget != null) functionWidget,
              ],
            ),

            Container(
              margin: EdgeInsets.only(top: contentWidget != null ? 12 : 0),
              child: contentWidget ?? Container(),
            ),
          ],
        ),
      ),
    );
  }

  Widget settingsSectionHeading({required String title}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(),
        Row(children: [Text(title, style: AppTheme().primarySubMenuHeadingStyle.copyWith(fontSize: 14))]),
        Divider(thickness: 1, color: Colors.black26, radius: BorderRadius.circular(25)),
      ],
    );
  }

  Widget settingsSubMenuRow({String? settingTitle, Widget? functionWidget, Widget? contentWidget, bool? disableWidget}) {
    return IgnorePointer(
      ignoring: disableWidget ?? false,
      child: Container(
        foregroundDecoration: disableWidget != null && disableWidget ? BoxDecoration(color: Colors.black45, borderRadius: AppTheme().getAppRadius()) : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 16,
          children: [
            contentWidget ?? Text(settingTitle ?? "", style: TextStyle(fontWeight: FontWeight.w500)),
            if (functionWidget != null) functionWidget,
          ],
        ),
      ),
    );
  }

  Widget lottieButton({required BuildContext context, required Function onTap, required lottieString, required hoverAnimationController, required setState, bool bigBorderButton = false, String menuNameString = "", double? widthOverride, double? heightOverride, String? tooltipString}) {
    return Tooltip(
      message: tooltipString ?? "",
      child: Material(
        color: Colors.white,
        borderRadius: AppTheme().primaryBorderRadius,

        child: InkWell(
          borderRadius: AppTheme().primaryBorderRadius,

          onTap: () => onTap(),
          onHover: (value) {
            if (value) {
              hoverAnimationController.forward().then((value) => hoverAnimationController.reset());
            }
          },
          child: Container(
            width: bigBorderButton ? 150 : 32,
            height: bigBorderButton ? 150 : 32,
            decoration: bigBorderButton
                ? BoxDecoration(
                    borderRadius: AppTheme().primaryBorderRadius,
                    border: Border.all(color: Colors.black54, width: 2),
                  )
                : BoxDecoration(),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runAlignment: WrapAlignment.center,
                  children: [
                    SizedBox(
                      width: widthOverride ?? 24,
                      height: heightOverride ?? 24,
                      child: Center(
                        child: Lottie.asset(
                          lottieString,
                          controller: hoverAnimationController,
                          onLoaded: (p0) {
                            setState(() {
                              hoverAnimationController.duration = p0.duration;
                            });
                          },
                        ),
                      ),
                    ),

                    if (menuNameString.isNotEmpty) ...[
                      Text(
                        menuNameString.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: AppTheme().primarySubMenuHeadingStyle.copyWith(color: Colors.black54),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> confirmActionDialog({required BuildContext context, required tickerProvider, String? message}) {
    AnimationController hoverAnimationController = AnimationController(vsync: tickerProvider);
    //TextEditingController passcodeController = TextEditingController();

    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          title: Row(
            children: [
              Lottie.asset(
                "assets/lotties/main-help.json",
                controller: hoverAnimationController,
                width: 32,
                height: 32,
                onLoaded: (p0) {
                  hoverAnimationController.duration = p0.duration;
                  hoverAnimationController.reset();
                  hoverAnimationController.forward().then((value) => hoverAnimationController.stop());
                },
              ),
              Container(width: 10),
              Text('Are you sure?', style: AppTheme().primarySubMenuHeadingStyle),
            ],
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            padding: EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Expanded(child: Text(message ?? "", softWrap: true))],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge),
              child: const Text('cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),

            TextButton(
              style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge),
              child: const Text('confirm'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> genericDialog({required BuildContext context, required tickerProvider, String? lottieIconOverride, double? iconSizeOverride, String? title, Widget? contentOverride, List<Widget>? overrideActions, bool? automaticallyPop, double? widthOverride}) {
    AnimationController hoverAnimationController = AnimationController(vsync: tickerProvider);

    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8, maxWidth: widthOverride ?? MediaQuery.of(context).size.width * 0.8),
          child: Container(
            padding: AppTheme().getAppPadding(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                Padding(
                  padding: AppTheme().getAppPadding().copyWith(left: 0, right: 0, top: 0),
                  child: Row(
                    spacing: 16,
                    children: [
                      Lottie.asset(
                        lottieIconOverride ?? "assets/lotties/main-check.json",
                        controller: hoverAnimationController,
                        width: iconSizeOverride ?? 32,
                        height: iconSizeOverride ?? 32,
                        onLoaded: (p0) {
                          hoverAnimationController.duration = p0.duration;
                          hoverAnimationController.reset();
                          hoverAnimationController.forward().then((value) => hoverAnimationController.stop());
                        },
                      ),
                      Expanded(child: Text(title ?? "", style: AppTheme().primarySubMenuHeadingStyle)),
                    ],
                  ),
                ),

                Flexible(child: SingleChildScrollView(child: contentOverride ?? Text(title ?? ""))),

                if (overrideActions != null) Row(mainAxisAlignment: MainAxisAlignment.center, children: overrideActions),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget getKeyboardWidget({required Function setState, required fieldController, required Function submit, bool numericOnly = true, bool unboundConstraints = false, bool keyboardTypeToggle = false}) {
    return _CustomKeyboardWidget(tenderEntryController: fieldController, submit: submit, numericOnly: numericOnly, unboundConstraints: unboundConstraints, keyboardTypeToggle: keyboardTypeToggle);
  }

  Color generateRandomColor() {
    Random random = Random();
    return Color.fromARGB(255, 180 + random.nextInt(76), 180 + random.nextInt(76), 180 + random.nextInt(76));
  }
}

class _CustomKeyboardWidget extends StatefulWidget {
  final TextEditingController tenderEntryController;
  final Function submit;
  final bool numericOnly;
  final bool unboundConstraints;
  final bool keyboardTypeToggle;
  const _CustomKeyboardWidget({required this.tenderEntryController, required this.submit, required this.numericOnly, required this.unboundConstraints, required this.keyboardTypeToggle});

  @override
  State<_CustomKeyboardWidget> createState() => _CustomKeyboardWidgetState();
}

class _CustomKeyboardWidgetState extends State<_CustomKeyboardWidget> {
  late bool isQwerty = !widget.numericOnly;

  void switchKeyboard() {
    setState(() {
      isQwerty = !isQwerty;
    });
  }

  void onKeyboardTap(String value) {
    setState(() {
      widget.tenderEntryController.text = widget.tenderEntryController.text + value;
    });
  }

  void onRemove() {
    setState(() {
      if (widget.tenderEntryController.text.isNotEmpty) {
        widget.tenderEntryController.text = widget.tenderEntryController.text.substring(0, widget.tenderEntryController.text.length - 1);
      }
    });
  }

  void onSubmit() {
    widget.submit();
  }

  static const numericCharacters = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '.'];
  static const qwertyCharacters = [
    // Row 1
    'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P',
    // Row 2
    '', 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L',
    // Row 3
    '', '', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '',
  ];

  @override
  Widget build(BuildContext context) {
    isQwerty = !widget.numericOnly;
    final characters = isQwerty ? qwertyCharacters : numericCharacters;
    final itemsPerRow = isQwerty ? 10 : 3;
    return Column(
      spacing: 32,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: isQwerty ? 900 : 300, minWidth: isQwerty ? 600 : 200, maxHeight: 400),
          child: GridView.builder(
            shrinkWrap: true,

            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: itemsPerRow, childAspectRatio: 1.5),
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final char = characters[index];
              if (char.isEmpty) return SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.all(isQwerty ? 2 : 4.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: AppTheme().getPrimaryBackgroundColour(),
                  ),
                  onPressed: () => onKeyboardTap(char),
                  child: Text(char, style: TextStyle(fontSize: isQwerty ? 14 : 18)),
                ),
              );
            },
          ),
        ),
        Row(
          spacing: 16,
          children: [
            if (widget.keyboardTypeToggle) ElevatedButton(onPressed: switchKeyboard, child: Text(isQwerty ? '123' : 'ABC')),
            ElevatedButton(onPressed: onRemove, child: Icon(Icons.backspace)),
            Expanded(child: Container()),
            ElevatedButton(onPressed: onSubmit, child: Text('Submit')),
          ],
        ),
      ],
    );
  }
}
