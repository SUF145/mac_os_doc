import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// The root of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MacBottomAppBar(),
    );
  }
}

/// A widget that mimics a macOS-style bottom app bar with draggable icons.
class MacBottomAppBar extends StatefulWidget {
  const MacBottomAppBar({super.key});

  @override
  _MacBottomAppBarState createState() => _MacBottomAppBarState();
}

class _MacBottomAppBarState extends State<MacBottomAppBar> {
  /// List of app icons displayed in the dock.
  final List<String> _appIcons = [
    'https://cdn.iconscout.com/icon/free/png-512/free-apple-photos-icon-download-in-svg-png-gif-file-formats--logo-photo-apps-pack-user-interface-icons-493155.png?f=webp&w=256',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Google_Chrome_icon_%28February_2022%29.svg/768px-Google_Chrome_icon_%28February_2022%29.svg.png',
    'https://cdn.iconscout.com/icon/free/png-512/free-safari-logo-icon-download-in-svg-png-gif-file-formats--brand-company-business-brands-pack-logos-icons-2284897.png?f=webp&w=256',
    'https://cdn.iconscout.com/icon/free/png-512/free-facebook-logo-icon-download-in-svg-png-gif-file-formats--fb-social-media-pack-logos-icons-789828.png?f=webp&w=256',
    'https://cdn.iconscout.com/icon/free/png-512/free-instagram-logo-icon-download-in-svg-png-gif-file-formats--social-media-logos-icons-2745482.png?f=webp&w=256',
  ];

  /// The index of the icon currently being dragged.
  int? _draggingIndex;

  /// Reorders icons in the list when dragging ends.
  void _moveIcon(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return; // Avoid unnecessary updates.
    setState(() {
      final item = _appIcons.removeAt(oldIndex);
      _appIcons.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image.
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1460500063983-994d4c27756c?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          // Bottom app bar.
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 80,
                    color: Colors.black.withOpacity(0.6),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: List.generate(_appIcons.length, (index) {
                        final iconPath = _appIcons[index];
                        final isDragging = _draggingIndex == index;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: 50,
                          height: 50,
                          margin: EdgeInsets.symmetric(horizontal: isDragging ? 15 : 8),
                          child: Draggable<String>(
                            data: iconPath,
                            feedback: Material(
                              color: Colors.transparent,
                              child: IconDisplay(iconPath: iconPath, size: 65),
                            ),
                            childWhenDragging: null,
                            onDragStarted: () => setState(() => _draggingIndex = index),
                            onDragEnd: (_) => setState(() => _draggingIndex = null),
                            onDragCompleted: () => setState(() => _draggingIndex = null),
                            child: DragTarget<String>(
                              onWillAcceptWithDetails: (details) {
                                final oldIndex = _appIcons.indexOf(details.data!);
                                if (oldIndex != index) {
                                  _moveIcon(oldIndex, index);
                                }
                                return true;
                              },
                              onAcceptWithDetails: (_) => setState(() => _draggingIndex = null),
                              builder: (context, candidateData, rejectedData) {
                                return IconDisplay(
                                  iconPath: iconPath,
                                  size: 50,
                                );
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A widget to display an icon with a specified size.
class IconDisplay extends StatelessWidget {
  /// The URL of the icon to display.
  final String iconPath;

  /// The size of the icon.
  final double size;

  const IconDisplay({
    super.key,
    required this.iconPath,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(iconPath),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}