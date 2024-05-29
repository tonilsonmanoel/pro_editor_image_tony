import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor_tony/modules/emoji_editor/emoji_editor.dart';
import 'package:pro_image_editor_tony/modules/sticker_editor.dart';
import 'package:pro_image_editor_tony/utils/design_mode.dart';

import '../../models/editor_configs/pro_image_editor_configs.dart';

/// Represents the temporary sticker mode for WhatsApp.
///
/// This variable defines the temporary sticker mode for WhatsApp, indicating whether stickers or emojis are being used.
WhatsAppStickerMode whatsAppTemporaryStickerMode = WhatsAppStickerMode.sticker;

/// Represents the sticker-editor page for the WhatsApp theme.
class WhatsAppStickerPage extends StatefulWidget {
  /// The configuration for the image editor.
  final ProImageEditorConfigs configs;

  const WhatsAppStickerPage({
    super.key,
    required this.configs,
  });

  @override
  State<WhatsAppStickerPage> createState() => _WhatsAppStickerPageState();
}

class _WhatsAppStickerPageState extends State<WhatsAppStickerPage> {
  final _emojiEditorKey = GlobalKey<EmojiEditorState>();
  bool _activeSearch = false;
  late TextEditingController _searchCtrl;
  late FocusNode _searchFocus;

  @override
  void initState() {
    _searchCtrl = TextEditingController();
    _searchFocus = FocusNode();
    if (widget.configs.stickerEditorConfigs == null) {
      whatsAppTemporaryStickerMode = WhatsAppStickerMode.emoji;
    }
    super.initState();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Scaffold(
        backgroundColor: Colors.black38,
        body: SafeArea(
          child: Column(
            children: [
              if (widget.configs.designMode == ImageEditorDesignModeE.material)
                ..._buildMaterialHeader()
              else
                ..._buildCupertinoHeader(),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Offstage(
                      offstage: whatsAppTemporaryStickerMode !=
                          WhatsAppStickerMode.emoji,
                      child: EmojiEditor(
                        key: _emojiEditorKey,
                        configs: widget.configs,
                      ),
                    ),
                    if (widget.configs.stickerEditorConfigs != null)
                      Offstage(
                        offstage: whatsAppTemporaryStickerMode !=
                            WhatsAppStickerMode.sticker,
                        child: StickerEditor(
                          configs: widget.configs,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMaterialHeader() {
    return [
      Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        color: Colors.black12,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.black38,
              ),
              tooltip: widget.configs.i18n.cancel,
              onPressed: () {
                if (_activeSearch) {
                  setState(() {
                    _searchCtrl.clear();
                    _activeSearch = false;
                    widget.configs.stickerEditorConfigs?.onSearchChanged
                        ?.call('');
                  });
                } else {
                  Navigator.pop(context);
                }
              },
              icon: Icon(
                widget.configs.icons.backButton,
                color: Colors.white,
              ),
            ),
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.black38,
              ),
              onPressed: () {},
              icon: Icon(
                widget.configs.icons.stickerEditor.bottomNavBar,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      Container(
        color: Colors.black12,
        padding: const EdgeInsets.all(8),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _activeSearch
              ? _buildSearchBar()
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _activeSearch = !_activeSearch;
                          });
                        },
                        icon: const Icon(Icons.search),
                        color: Colors.white,
                      ),
                    ),
                    if (widget.configs.stickerEditorConfigs != null)
                      Align(
                        alignment: Alignment.center,
                        child: SegmentedButton(
                          showSelectedIcon: false,
                          emptySelectionAllowed: false,
                          style: SegmentedButton.styleFrom(
                            backgroundColor: Colors.white38,
                            foregroundColor: Colors.white,
                            selectedForegroundColor: Colors.black,
                            selectedBackgroundColor: Colors.white,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          segments: <ButtonSegment>[
                            ButtonSegment(
                              value: WhatsAppStickerMode.sticker,
                              label: Text(
                                widget.configs.i18n.stickerEditor
                                    .bottomNavigationBarText,
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            ButtonSegment(
                              value: WhatsAppStickerMode.emoji,
                              label: Text(
                                widget.configs.i18n.emojiEditor
                                    .bottomNavigationBarText,
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                          selected: {whatsAppTemporaryStickerMode},
                          onSelectionChanged: (Set newSelection) {
                            setState(() {
                              whatsAppTemporaryStickerMode = newSelection.first;
                            });
                          },
                        ),
                      )
                  ],
                ),
        ),
      ),
    ];
  }

  List<Widget> _buildCupertinoHeader() {
    return [
      Container(
        margin: const EdgeInsets.only(top: 7),
        width: 70,
        height: 5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: Colors.grey.shade700,
        ),
      ),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        reverseDuration: widget.configs.stickerEditorConfigs != null
            ? null
            : const Duration(),
        switchInCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: widget.configs.stickerEditorConfigs != null
              ? SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1,
                  child: child,
                )
              : ScaleTransition(
                  scale: animation,
                  alignment: Alignment.topCenter,
                  child: child,
                ),
        ),
        child: _activeSearch ? _buildSearchBar() : const SizedBox.shrink(),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: AnimatedSwitcher(
          duration: Duration(
              milliseconds:
                  widget.configs.stickerEditorConfigs != null ? 160 : 0),
          switchInCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          child: _activeSearch
              ? (widget.configs.stickerEditorConfigs != null
                  ? Row(
                      children: [
                        Expanded(
                          child: _buildCupertinoSegments(),
                        ),
                      ],
                    )
                  : const SizedBox.shrink())
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _activeSearch = !_activeSearch;
                          });
                        },
                        icon: const Icon(Icons.search),
                        color: Colors.white,
                      ),
                      if (widget.configs.stickerEditorConfigs != null)
                        _buildCupertinoSegments(),
                      IconButton(
                        onPressed: null,
                        icon: Icon(
                          widget.configs.icons.stickerEditor.bottomNavBar,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    ];
  }

  Widget _buildCupertinoSegments() {
    return CupertinoSlidingSegmentedControl<WhatsAppStickerMode>(
      backgroundColor: const Color(0xFF353537),
      thumbColor: const Color(0xFF6C6D72),
      groupValue: whatsAppTemporaryStickerMode,
      onValueChanged: (value) {
        if (value != null) {
          setState(() {
            whatsAppTemporaryStickerMode = value;
          });
        }
      },
      children: <WhatsAppStickerMode, Widget>{
        WhatsAppStickerMode.emoji: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Icon(
            widget.configs.icons.emojiEditor.bottomNavBar,
            color: Colors.white,
          ),
        ),
        WhatsAppStickerMode.sticker: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Icon(
            widget.configs.icons.stickerEditor.bottomNavBar,
            color: Colors.white,
          ),
        ),
      },
    );
  }

  Widget _buildSearchBar() {
    if (widget.configs.designMode == ImageEditorDesignModeE.cupertino) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Row(
          children: [
            Expanded(
              child: CupertinoSearchTextField(
                autofocus: true,
                controller: _searchCtrl,
                focusNode: _searchFocus,
                onChanged: (value) {
                  _emojiEditorKey.currentState?.externSearch(value);
                  widget.configs.stickerEditorConfigs?.onSearchChanged
                      ?.call(value);
                  _searchFocus.requestFocus();
                  Future.delayed(const Duration(milliseconds: 1))
                      .whenComplete(() {
                    _searchFocus.requestFocus();
                  });
                },
                itemColor: const Color.fromARGB(255, 243, 243, 243),
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            CupertinoButton(
              child: Text(widget.configs.i18n.cancel),
              onPressed: () {
                setState(() {
                  _activeSearch = false;
                });
              },
            ),
          ],
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(100)),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.search),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: TextField(
                  autofocus: true,
                  controller: _searchCtrl,
                  focusNode: _searchFocus,
                  onChanged: (value) {
                    _emojiEditorKey.currentState?.externSearch(value);
                    widget.configs.stickerEditorConfigs?.onSearchChanged
                        ?.call(value);
                    _searchFocus.requestFocus();
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.configs.i18n.emojiEditor.search,
                    isCollapsed: true,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  if (_searchCtrl.text.isNotEmpty) {
                    _searchCtrl.clear();
                    widget.configs.stickerEditorConfigs?.onSearchChanged
                        ?.call('');
                  } else {
                    _activeSearch = false;
                  }
                });
              },
            ),
          ],
        ),
      );
    }
  }
}

enum WhatsAppStickerMode {
  sticker,
  emoji,
}
