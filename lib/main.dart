import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(
    const SpringboardScope(
      child: App(),
    ),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AppState();
  }
}

class _AppState extends State<App> {
  Vault? _vault = Vault.dashboard;

  void onVault(Vault vault) {
    setState(() {
      _vault = vault;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Navigator(
        onPopPage: (route, result) => route.didPop(result),
        pages: [
          TransitionlessPage(
            child: SpringboardScreen(
              onVault: onVault,
            ),
          ),
          if (_vault == Vault.dashboard)
            SpringboardPage(
              child: DashboardScreen(
                onExit: () {
                  setState(() {
                    _vault = null;
                  });
                },
              ),
            ),
          if (_vault == Vault.settings)
            SpringboardPage(
              child: SettingsScreen(
                onExit: () {
                  setState(() {
                    _vault = null;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}

enum Vault {
  dashboard,
  settings,
}

class SpringboardScreen extends StatelessWidget {
  const SpringboardScreen({
    required this.onVault,
    super.key,
  });

  final ValueSetter<Vault> onVault;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          'Springboard',
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SpringboardControl(
              child: ElevatedButton(
                onPressed: () => onVault(Vault.dashboard),
                child: const Text('Launch dashboard'),
              ),
            ),
            SpringboardControl(
              child: ElevatedButton(
                onPressed: () => onVault(Vault.settings),
                child: const Text('Launch settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    required this.onExit,
    super.key,
  });

  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: onExit,
        ),
        title: const Text(
          'Dashboard',
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SpringboardControl(
              child: ElevatedButton(
                onPressed: onExit,
                child: const Text('Back to springboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.onExit,
    super.key,
  });

  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: onExit,
        ),
        title: const Text(
          'Settings',
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SpringboardControl(
              child: ElevatedButton(
                onPressed: onExit,
                child: const Text('Back to springboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SpringboardScope extends StatefulWidget {
  const SpringboardScope({
    required this.child,
    super.key,
  });

  static SpringboardScopeState? of(BuildContext context) {
    final navigator = context
        .dependOnInheritedWidgetOfExactType<_InheritedSpringboardScope>();
    return navigator?.state;
  }

  final Widget child;

  @override
  State<SpringboardScope> createState() => SpringboardScopeState();
}

class SpringboardScopeState extends State<SpringboardScope> {
  Offset? transitionOrigin;

  @override
  Widget build(BuildContext context) {
    return _InheritedSpringboardScope(
      state: this,
      child: widget.child,
    );
  }
}

class _InheritedSpringboardScope extends InheritedWidget {
  const _InheritedSpringboardScope({
    required this.state,
    required super.child,
  });

  final SpringboardScopeState state;

  @override
  bool updateShouldNotify(_InheritedSpringboardScope oldWidget) =>
      state.transitionOrigin != oldWidget.state.transitionOrigin;
}

class SpringboardControl extends StatelessWidget {
  const SpringboardControl({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        final scope = SpringboardScope.of(context);
        scope?.transitionOrigin = event.position;
        return;
      },
      child: child,
    );
  }
}

/// A [Page] that is presented from the springboard.
///
/// This is *not* the [Page] that is used to present the springboard itself.
class SpringboardPage extends Page<void> {
  const SpringboardPage({
    required this.child,
    super.key,
    super.arguments,
    super.name,
    super.restorationId,
  });

  final Widget child;

  @override
  Route<void> createRoute(BuildContext context) {
    return SpringboardPageRoute(
      settings: this,
    );
  }
}

class SpringboardPageRoute extends PageRoute<void> {
  SpringboardPageRoute({
    required SpringboardPage super.settings,
    super.allowSnapshotting = true,
    super.fullscreenDialog = true,
  });

  @override
  SpringboardPage get settings => super.settings as SpringboardPage;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return settings.child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (animation.isCompleted || animation.isDismissed) {
      return child;
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ClipPath(
          clipper: SpringboardScreenClipper(
            origin: SpringboardScope.of(context)?.transitionOrigin,
            progress: animation.value,
          ),
          child: child,
        );
      },
      child: child,
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 335);

  @override
  Animation<double> createAnimation() {
    return CurvedAnimation(
      parent: controller!,
      curve: Curves.fastEaseInToSlowEaseOut,
    );
  }
}

class SpringboardScreenClipper extends CustomClipper<Path> {
  const SpringboardScreenClipper({
    required this.progress,
    required this.origin,
  });

  final double progress;

  final Offset? origin;

  @override
  Path getClip(Size size) {
    final path = Path();

    final center = Offset(size.width * 0.5, size.height * 0.5);
    final origin = this.origin ?? center;
    final difference = (center - origin);

    final width = size.width + (difference.dx.abs() * 2);
    final height = size.height + (difference.dy.abs() * 2);

    final dimension = math.sqrt(
      math.pow(width, 2) + math.pow(height, 2),
    );

    final radius = dimension * 0.5 * progress;

    path.addOval(
      Rect.fromCircle(
        center: origin,
        radius: radius,
      ),
    );

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class TransitionlessPage extends Page<void> {
  const TransitionlessPage({
    required this.child,
    super.key,
    super.arguments,
    super.name,
    super.restorationId,
  });

  final Widget child;

  @override
  Route<void> createRoute(BuildContext context) {
    return TransitionlessPageRoute(
      settings: this,
    );
  }
}

class TransitionlessPageRoute extends PageRoute<void> {
  TransitionlessPageRoute({
    required TransitionlessPage super.settings,
    super.allowSnapshotting = true,
    super.fullscreenDialog = true,
  });

  @override
  TransitionlessPage get settings => super.settings as TransitionlessPage;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  String? get barrierLabel => 'throw UnimplementedError();';

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return settings.child;
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Duration get reverseTransitionDuration => Duration.zero;
}
