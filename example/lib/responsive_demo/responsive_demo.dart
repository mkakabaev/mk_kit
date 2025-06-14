import 'dart:math';

import 'package:flutter/material.dart';

import 'package:mk_kit/mk_kit.dart';

class ResponsiveDemo extends StatefulWidget {
  const ResponsiveDemo({super.key});

  @override
  State<ResponsiveDemo> createState() => _ResponsiveDemoState();
}

class _ResponsiveDemoState extends State<ResponsiveDemo> {
  final _controller = TransformationController();
  final _screenSizes = <(Size, String)>[];
  var _currentScreenSizeIndex = 0;
  var _mustUpdateTransformation = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mqd = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Responsive Demo'), actions: [_buildSizeSelector()]),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Set up screen sizes. Do it only once when the current screen size is available.
          if (_screenSizes.isEmpty) {
            _screenSizes.add((const Size(320, 568), ''));
            _screenSizes.add((const Size(375, 667), ''));
            _screenSizes.add((const Size(375, 812), ''));
            _screenSizes.add((const Size(414, 896), ''));
            _screenSizes.add((const Size(390, 844), ''));
            _screenSizes.add((const Size(428, 926), 'iPhone 12 Pro Max'));
            _screenSizes.add((const Size(393, 852), 'iPhone 16'));
            _screenSizes.add((const Size(430, 932), 'iPhone 16 Plus, 15 Pro Max'));
            _screenSizes.add((const Size(402, 874), 'iPhone 16 Pro'));
            _screenSizes.add((const Size(440, 956), 'iPhone 16 Pro Max'));
            _screenSizes.add((const Size(768, 1024), ''));
            if (_screenSizes.indexWhere((s) => s.$1 == mqd.size) == -1) {
              _screenSizes.add((mqd.size, ''));
            }
            _screenSizes.sort((a, b) => (a.$1.width * 1000 + a.$1.height).compareTo((b.$1.width * 1000 + b.$1.height)));
            _currentScreenSizeIndex = _screenSizes.indexWhere((s) => s.$1 == mqd.size);
          }

          // Get child screen size and calculate boundary margin to center the child screen if it is small
          final currentScreenSize = _screenSizes[_currentScreenSizeIndex].$1; // ignore: avoid-unsafe-collection-methods
          final boundaryMargin = EdgeInsets.symmetric(
            horizontal: max(10, (constraints.maxWidth - currentScreenSize.width) / 2),
            vertical: max(10, (constraints.maxHeight - currentScreenSize.height) / 2),
          );

          if (_mustUpdateTransformation) {
            _controller.value = Matrix4.identity()..translate(boundaryMargin.left, boundaryMargin.top);
            _mustUpdateTransformation = false;
          }

          // Theme for the child screen
          final baseTheme = ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber), useMaterial3: true);
          final childTheme = baseTheme.copyWith(
            appBarTheme: AppBarTheme(backgroundColor: baseTheme.colorScheme.inversePrimary),
          );

          return InteractiveViewer(
            minScale: 1,
            maxScale: 1,
            constrained: false,
            transformationController: _controller,
            boundaryMargin: boundaryMargin,
            alignment: Alignment.center,
            child: MediaQuery(
              data: mqd.copyWith(size: currentScreenSize, viewPadding: EdgeInsets.zero, padding: EdgeInsets.zero),
              child: SizedBox(
                width: currentScreenSize.width,
                height: currentScreenSize.height,
                child: Theme(
                  data: childTheme,
                  child: const ClipRect(child: Responsive(child: _Screen())),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSizeSelector() {
    return PopupMenuButton(
      onSelected: (index) {
        setState(() {
          _currentScreenSizeIndex = index;
          _mustUpdateTransformation = true;
        });
      },
      itemBuilder: (context) => List.generate(_screenSizes.length, (index) {
        final size = _screenSizes[index];
        return PopupMenuItem(
          value: index,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(size.$1.shortDescription),
              Expanded(child: Text(size.$2)),
              if (index == _currentScreenSizeIndex) const Icon(Icons.check),
            ],
          ),
        );
      }),
    );
  }
}

extension on Size {
  String get shortDescription => '${width.toInt()} x ${height.toInt()}';
}

class _Screen extends StatelessWidget {
  const _Screen();

  Widget _buildContainer(double spacing, String text) {
    return Container(
      padding: EdgeInsets.fromLTRB(spacing, spacing, spacing, spacing),
      color: Colors.blue.shade100,

      child: Container(
        color: Colors.blue,
        // width: 50,
        // height: 100,
        child: Text("$text → ${spacing.toInt()}"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = Responsive.of(context);
    final mqd = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("${mqd.size.shortDescription} • TXT ${mqd.textScaler.scale(1.0).toStringAsFixed(3)}"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: data.screenMargin,
        child: Column(
          spacing: data.spacing10,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 2,
                      runSpacing: 2,
                      children: [
                        _buildContainer(data.spacing2, '2'),
                        _buildContainer(data.spacing4, '4'),
                        _buildContainer(data.spacing6, '6'),
                        _buildContainer(data.spacing8, '8'),
                        _buildContainer(data.spacing10, '10'),
                        _buildContainer(data.spacing12, '12'),
                        _buildContainer(data.spacing16, '16'),
                        _buildContainer(data.spacing20, '20'),
                        _buildContainer(data.spacing24, '24'),
                        _buildContainer(data.spacing32, '32'),
                        _buildContainer(data.spacing48, '48'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
