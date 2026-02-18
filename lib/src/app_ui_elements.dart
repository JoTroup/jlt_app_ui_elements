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
  int currentViewIndex = 0;


  ValueNotifier<Widget> currentMenu = ValueNotifier(Container());

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

  SideBarLottieButton({required this.name, required this.lottieStringAssetPath, required this.widget, this.onTap});
}

class AppUiElements {
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

    sideBarController.currentMenu.value = disableAnimation == false
        ? PageTransitionSwitcher(
            child: returnContent,
            transitionBuilder: (Widget child, Animation<double> primaryAnimation, Animation<double> secondaryAnimation) {
              sideBarController.currentViewIndex = selectedIndex;
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

  Widget settingsSubMenuRow({String? settingTitle, Widget? functionWidget, Widget? contentWidget, bool? disableWidget, bool? isFuture}) {
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

  Future<bool?> genericDialog({
    required BuildContext context,
    required tickerProvider,
    bool disableIcon = false,
    bool disableHeading = false,
    String? lottieIconOverride,
    double? iconSizeOverride,
    bool? closeIcon,
    String? title,
    String? description,
    Widget? contentOverride,
    List<Widget>? overrideActions,
    MainAxisAlignment? actionAlignment,
    double? actionSpacing,
    bool? automaticallyPop,
    double? widthOverride}) {
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
                if (disableHeading == false)
                  Padding(
                    padding: AppTheme().getAppPadding().copyWith(left: 0, right: 0, top: 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Row(
                          spacing: 16,
                          children: [
                            if(closeIcon == true)
                              InkWell(
                                onTap: () => Navigator.of(context).pop(false),
                                child: Icon(Icons.close, size: 24, color: Colors.black54),
                              ),

                            if (disableIcon == false)
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

                        if (description != null) ...[
                          Text(description),
                        ]
                      ],
                    ),
                  ),

                Flexible(child: SingleChildScrollView(child: contentOverride ?? Text(title ?? ""))),

                if (overrideActions != null) Row(spacing: actionSpacing ?? 8, mainAxisAlignment: actionAlignment ?? MainAxisAlignment.center, children: overrideActions),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget getKeyboardWidget({required Function setState, required fieldController, required Function submit, bool numericOnly = true, bool unboundConstraints = false, bool keyboardTypeToggle = false}) {
    return _CustomKeyboardWidget(
      tenderEntryController: fieldController,
      submit: submit,
      numericOnly: numericOnly,
      unboundConstraints: unboundConstraints,
      keyboardTypeToggle: keyboardTypeToggle,
    );
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
    final spacing = isQwerty ? 4.0 : 8.0;
    const footerHeight = 56.0;
    const columnSpacing = 16.0;

    Widget buildGrid(BoxConstraints constraints) {
      final rows = (characters.length / itemsPerRow).ceil();
      final gridWidth = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : MediaQuery.of(context).size.width;
      final gridHeight = constraints.maxHeight.isFinite
          ? constraints.maxHeight
          : 400.0;
      final cellWidth = (gridWidth - (itemsPerRow - 1) * spacing) / itemsPerRow;
      final cellHeight = (gridHeight - (rows - 1) * spacing) / rows;
      final childAspectRatio = cellWidth > 0 && cellHeight > 0 ? cellWidth / cellHeight : 1.0;

      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: itemsPerRow,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: characters.length,
        itemBuilder: (context, index) {
          final char = characters[index];
          if (char.isEmpty) return SizedBox.shrink();
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: AppTheme().getPrimaryBackgroundColour(),
              padding: EdgeInsets.zero,
            ),
            onPressed: () => onKeyboardTap(char),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(char, style: TextStyle(fontSize: isQwerty ? 14 : 18)),
            ),
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Compute concrete dimensions from constraints
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final maxHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 400.0;

        // Ensure we always have positive dimensions
        final safeWidth = max(100.0, maxWidth);
        final safeHeight = max(footerHeight + columnSpacing + 100.0, maxHeight);

        return SizedBox(
          width: safeWidth,
          height: safeHeight,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, gridConstraints) {
                    final gridHeight = gridConstraints.maxHeight;
                    return buildGrid(BoxConstraints(
                      minWidth: safeWidth,
                      maxWidth: safeWidth,
                      minHeight: gridHeight,
                      maxHeight: gridHeight,
                    ));
                  },
                ),
              ),
              SizedBox(height: columnSpacing),
              SizedBox(
                height: footerHeight,
                width: safeWidth,
                child: Row(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 16,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.keyboardTypeToggle)
                          ElevatedButton(
                              onPressed: switchKeyboard,
                              child: Text(isQwerty ? '123' : 'ABC', overflow: TextOverflow.clip)
                          ),
                        ElevatedButton(onPressed: onRemove, child: Icon(Icons.backspace)),
                      ],
                    ),
                    ElevatedButton(
                        onPressed: onSubmit,
                        child: Text('Submit', overflow: TextOverflow.clip)
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MenuHeroWidget extends StatefulWidget {
  final String? lottieAsset;
  final String title;
  final Widget? functionWidget;
  final Widget? contentWidget;
  final bool? disableWidget;

  const MenuHeroWidget({
    super.key,
    this.lottieAsset,
    required this.title,
    this.functionWidget,
    this.contentWidget,
    this.disableWidget,
  });

  @override
  State<MenuHeroWidget> createState() => _MenuHeroWidgetState();
}

class _MenuHeroWidgetState extends State<MenuHeroWidget> with TickerProviderStateMixin {
  late AnimationController hoverAnimationController;

  @override
  void initState() {
    super.initState();
    hoverAnimationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    hoverAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ColorFiltered(
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  child: Lottie.asset(
                    widget.lottieAsset ?? "assets/lotties/main-account.json",
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
                  child: Text(widget.title, style: AppTheme().primarySubMenuHeadingStyle.copyWith(color: Colors.white)),
                ),
                if (widget.functionWidget != null) widget.functionWidget!,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SideNavBar extends StatefulWidget {
  final SideBarController sideBarController;
  final List<SideBarLottieButton> primaryActions;
  final List<SideBarLottieButton> settingsActions;
  final String logoAssetPath;
  final String appName;
  final Function setState;
  final bool isExpandable;
  final bool mounted;

  const SideNavBar({
    super.key,
    required this.sideBarController,
    required this.primaryActions,
    required this.settingsActions,
    required this.logoAssetPath,
    required this.appName,
    required this.setState,
    required this.mounted,
    this.isExpandable = true,
  });

  @override
  State<SideNavBar> createState() => _SideNavBarState();
}

class _SideNavBarState extends State<SideNavBar> with TickerProviderStateMixin {
  late List<AnimationController> primaryControllers;
  late List<AnimationController> settingsControllers;

  @override
  void initState() {
    super.initState();
    primaryControllers = List.generate(widget.primaryActions.length, (_) => AnimationController(vsync: this));
    settingsControllers = List.generate(widget.settingsActions.length, (_) => AnimationController(vsync: this));
  }

  @override
  void dispose() {
    for (var c in primaryControllers) { c.dispose(); }
    for (var c in settingsControllers) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sideBarController = widget.sideBarController;
    if (sideBarController.isCompactDevice) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Wrap(
            direction: Axis.vertical,
            children: List.generate(widget.primaryActions.length, (index) {
              final action = widget.primaryActions[index];
              return AppUiElements().animatedNavButton(
                context: context,
                onTap: () {
                  AppUiElements().handleNavigationChange(
                    selectedIndex: index,
                    updateMenu: widget.setState,
                    replacementWidget: action.widget,
                    context: context,
                    mounted: widget.mounted,
                    sideBarController: sideBarController,
                  );
                },
                hoverAnimationController: primaryControllers[index],
                lottieString: action.lottieStringAssetPath,
                setState: widget.setState,
                selectedHighlightRightIndex: index,
                menuNameString: "",
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
                if(widget.logoAssetPath.endsWith(".svg"))
                  SvgPicture.asset(widget.logoAssetPath, width: 36, height: 36)
                else
                  Image.asset(widget.logoAssetPath, width: 36, height: 36),
                AnimatedSize(
                  duration: Duration(milliseconds: 100),
                  child: SizedBox(
                    width: sideBarController.isExpanded ? null : 0,
                    child: ClipRect(
                      child: Text(
                        widget.appName.toUpperCase(),
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
            children: List.generate(widget.primaryActions.length, (index) {
              final action = widget.primaryActions[index];
              return AppUiElements().animatedNavButton(
                context: context,
                onTap: () {
                  AppUiElements().handleNavigationChange(
                    selectedIndex: index,
                    updateMenu: widget.setState,
                    replacementWidget: action.widget,
                    context: context,
                    mounted: widget.mounted,
                    sideBarController: sideBarController,
                  );
                },
                hoverAnimationController: primaryControllers[index],
                lottieString: action.lottieStringAssetPath,
                setState: widget.setState,
                selectedHighlightRightIndex: index,
                menuNameString: "",
                expandedMenuTitle: sideBarController.isExpanded,
                isCompactView: sideBarController.isCompactDevice,
              );
            }),
          ),

          Expanded(child: Container()),

          if (!AppTheme().getDeviceSmall() && widget.isExpandable)
            Row(
              children: [
                Center(
                  child: AnimatedRotation(
                    turns: sideBarController.isExpanded ? 0 : 0.5,
                    duration: Duration(milliseconds: 300),
                    child: IconButton(
                      onPressed: () {
                        widget.setState(() {
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
            children: List.generate(widget.settingsActions.length, (index) {
              final action = widget.settingsActions[index];
              return AppUiElements().animatedNavButton(
                context: context,
                onTap: () {
                  if (action.onTap != null) action.onTap!();
                },
                hoverAnimationController: settingsControllers[index],
                lottieString: action.lottieStringAssetPath,
                setState: widget.setState,
                menuNameString: "",
                expandedMenuTitle: sideBarController.isExpanded,
                isCompactView: sideBarController.isCompactDevice,
              );
            }),
          ),
        ],
      ),
    );
  }
}
