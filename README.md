# jlt_app_ui_elements

A Flutter package providing default app UI elements for the JLT software suite. Includes animated navigation buttons and integrates with the JLT theme handler for consistent styling.

## Features

- Animated navigation button with Lottie animation support
- Theme integration via [jlt_app_theme_handler](https://github.com/JoTroup/jlt_app_theme_handler)
- Customizable highlight and padding
- Easily extendable for additional UI elements

## Getting started

Add the package to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  jlt_app_ui_elements:
    path: ../jlt_app_ui_elements # or use your local/git path
```

Run `flutter pub get` to install dependencies.

## Usage

Import the package and use the `AppUiElements` class:

```dart
import 'package:jlt_app_ui_elements/jlt_app_ui_elements.dart';

final appUi = AppUiElements();

Widget navButton = appUi.animatedNavButton(
  context: context,
  onTap: () => print('Tapped!'),
  hoverAnimationController: AnimationController(vsync: this),
  lottieString: 'assets/animation.json',
  setState: setState,
  widthOverride: 40,
  heightOverride: 40,
  selectedHightlightRightIndex: 1,
);
```

## Example

See the `/example` folder for a complete usage example.

## Additional information

- This package is designed for use with the JLT software suite.
- For theme customization, see [jlt_app_theme_handler](https://github.com/JoTroup/jlt_app_theme_handler).
- Contributions and issues are welcome!
