part of 'package:extended_text_field/src/extended/widgets/text_field.dart';

/// [RenderEditable]
class ExtendedRenderEditable extends _RenderEditable {
  ExtendedRenderEditable({
    super.text,
    required super.textDirection,
    super.textAlign = TextAlign.start,
    super.cursorColor,
    super.backgroundCursorColor,
    super.showCursor,
    super.hasFocus,
    required super.startHandleLayerLink,
    required super.endHandleLayerLink,
    super.maxLines = 1,
    super.minLines,
    super.expands = false,
    super.strutStyle,
    super.selectionColor,
    super.textScaleFactor = 1.0,
    super.textScaler = TextScaler.noScaling,
    super.selection,
    required super.offset,
    super.ignorePointer = false,
    super.readOnly = false,
    super.forceLine = true,
    super.textHeightBehavior,
    super.textWidthBasis = TextWidthBasis.parent,
    super.obscuringCharacter = '•',
    super.obscureText = false,
    super.locale,
    super.cursorWidth = 1.0,
    super.cursorHeight,
    super.cursorRadius,
    super.paintCursorAboveText = false,
    super.cursorOffset = Offset.zero,
    super.devicePixelRatio = 1.0,
    super.selectionHeightStyle = ui.BoxHeightStyle.tight,
    super.selectionWidthStyle = ui.BoxWidthStyle.tight,
    super.enableInteractiveSelection,
    super.floatingCursorAddedMargin = const EdgeInsets.fromLTRB(4, 4, 4, 5),
    super.promptRectRange,
    super.promptRectColor,
    super.clipBehavior = Clip.hardEdge,
    required super.textSelectionDelegate,
    super.painter,
    super.foregroundPainter,
    super.children,
    this.supportSpecialText = false,
    super.offsetFunction,
  }) {
    _findSpecialInlineSpanBase(text);
  }

  bool supportSpecialText = false;
  bool _hasSpecialInlineSpanBase = false;
  bool get hasSpecialInlineSpanBase =>
      supportSpecialText && _hasSpecialInlineSpanBase;

  void _findSpecialInlineSpanBase(InlineSpan? span) {
    _hasSpecialInlineSpanBase = false;
    span?.visitChildren((InlineSpan span) {
      if (span is SpecialInlineSpanBase) {
        _hasSpecialInlineSpanBase = true;
        return false;
      }
      return true;
    });
  }

  @override
  set text(InlineSpan? value) {
    if (_textPainter.text == value) {
      return;
    }
    _findSpecialInlineSpanBase(value);
    super.text = value;
  }

  @override
  String get plainText {
    return ExtendedTextLibraryUtils.textSpanToActualText(_textPainter.text!);
  }

  @override
  void selectWordEdge({required SelectionChangedCause cause}) {
    _computeTextMetricsIfNeeded();
    assert(_lastTapDownPosition != null);
    final TextPosition position = _textPainter.getPositionForOffset(
        globalToLocal(_lastTapDownPosition! - _paintOffset));
    final TextRange word = _textPainter.getWordBoundary(position);
    late TextSelection newSelection;
    if (position.offset <= word.start) {
      newSelection = TextSelection.collapsed(offset: word.start);
    } else {
      newSelection = TextSelection.collapsed(
          offset: word.end, affinity: TextAffinity.upstream);
    }

    /// zmtzawqlp
    newSelection = hasSpecialInlineSpanBase
        ? ExtendedTextLibraryUtils
            .convertTextPainterSelectionToTextInputSelection(
                text!, newSelection)
        : newSelection;
    _setSelection(newSelection, cause);
  }

  @override
  void selectPositionAt(
      {required Offset from,
      Offset? to,
      required SelectionChangedCause cause}) {
    _computeTextMetricsIfNeeded();
    TextPosition fromPosition =
        _textPainter.getPositionForOffset(globalToLocal(from - _paintOffset));
    TextPosition? toPosition = to == null
        ? null
        : _textPainter.getPositionForOffset(globalToLocal(to - _paintOffset));
    //zmt
    if (hasSpecialInlineSpanBase) {
      fromPosition =
          ExtendedTextLibraryUtils.convertTextPainterPostionToTextInputPostion(
              text!, fromPosition)!;
      toPosition =
          ExtendedTextLibraryUtils.convertTextPainterPostionToTextInputPostion(
              text!, toPosition);
    }
    final int baseOffset = fromPosition.offset;
    final int extentOffset = toPosition?.offset ?? fromPosition.offset;

    final TextSelection newSelection = TextSelection(
      baseOffset: baseOffset,
      extentOffset: extentOffset,
      affinity: fromPosition.affinity,
    );

    _setSelection(newSelection, cause);
  }

  @override
  TextSelection getWordAtOffset(TextPosition position) {
    final TextSelection selection = super.getWordAtOffset(position);

    /// zmt
    return hasSpecialInlineSpanBase
        ? ExtendedTextLibraryUtils
            .convertTextPainterSelectionToTextInputSelection(text!, selection,
                selectWord: true)
        : selection;
  }

  @override
  TextSelection getLineAtOffset(TextPosition position) {
    debugAssertLayoutUpToDate();
    final TextPosition tempPosition = hasSpecialInlineSpanBase
        ? ExtendedTextLibraryUtils.convertTextInputPostionToTextPainterPostion(
            text!, position)
        : position;

    final TextRange line = _textPainter.getLineBoundary(tempPosition);
    // If text is obscured, the entire string should be treated as one line.

    late TextSelection newSelection;
    if (obscureText) {
      newSelection =
          TextSelection(baseOffset: 0, extentOffset: plainText.length);
    } else {
      newSelection =
          TextSelection(baseOffset: line.start, extentOffset: line.end);
    }
    newSelection = hasSpecialInlineSpanBase
        ? ExtendedTextLibraryUtils
            .convertTextPainterSelectionToTextInputSelection(
                text!, newSelection)
        : newSelection;

    return newSelection;
  }

  @override
  List<TextSelectionPoint> getEndpointsForSelection(TextSelection selection) {
    // zmtzawqlp
    if (hasSpecialInlineSpanBase) {
      selection = ExtendedTextLibraryUtils
          .convertTextInputSelectionToTextPainterSelection(text!, selection);
    }

    return super.getEndpointsForSelection(selection);
  }

  @override
  set selection(TextSelection? value) {
    if (_selection == value) {
      return;
    }
    _selection = value;
    _selectionPainter.highlightedRange = getActualSelection();
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  @override
  void setPromptRectRange(TextRange? newRange) {
    _autocorrectHighlightPainter.highlightedRange =
        getActualSelection(newRange: newRange);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final InlineSpan? textSpan = _textPainter.text;
    final Offset effectivePosition = position - _paintOffset;
    if (textSpan != null) {
      final TextPosition textPosition =
          _textPainter.getPositionForOffset(effectivePosition);
      final Object? span = textSpan.getSpanForPosition(textPosition);
      if (span is HitTestTarget) {
        result.add(HitTestEntry(span));
        return true;
      }
    }
    // return hitTestInlineChildren(result, position);
    return hitTestInlineChildren(result, effectivePosition);
  }

  TextSelection? getActualSelection({TextRange? newRange}) {
    TextSelection? value = selection;
    if (newRange != null) {
      value =
          TextSelection(baseOffset: newRange.start, extentOffset: newRange.end);
    }

    return hasSpecialInlineSpanBase
        ? ExtendedTextLibraryUtils
            .convertTextInputSelectionToTextPainterSelection(text!, value!)
        : value;
  }

  /// Returns the [Rect] in local coordinates for the caret at the given text
  /// position.
  ///
  /// See also:
  ///
  ///  * [getPositionForPoint], which is the reverse operation, taking
  ///    an [Offset] in global coordinates and returning a [TextPosition].
  ///  * [getEndpointsForSelection], which is the equivalent but for
  ///    a selection rather than a particular text position.
  ///  * [TextPainter.getOffsetForCaret], the equivalent method for a
  ///    [TextPainter] object.
  @override
  Rect getLocalRectForCaret(TextPosition caretPosition) {
    _computeTextMetricsIfNeeded();
    final Rect caretPrototype = _caretPrototype;
    Offset caretOffset =
        _textPainter.getOffsetForCaret(caretPosition, caretPrototype);

    if (caretOffset.dx == 0) {
      var length = 0;
      text?.visitChildren((InlineSpan ts) {
        length += ExtendedTextLibraryUtils.getInlineOffset(ts);
        if (length > caretPosition.offset) {
          return false;
        }
        return true;
      });
      if (length == caretPosition.offset) {
        caretOffset = ExtendedTextLibraryUtils.getCaretOffset(
          caretPosition,
          _textPainter,
          hasSpecialInlineSpanBase,
          boxHeightStyle: selectionHeightStyle,
          boxWidthStyle: selectionWidthStyle,
        );
      }
    }

    Rect caretRect = caretPrototype.shift(caretOffset + cursorOffset);
    final double scrollableWidth =
        math.max(_textPainter.width + _caretMargin, size.width);

    final double caretX = clampDouble(
        caretRect.left, 0, math.max(scrollableWidth - _caretMargin, 0));
    caretRect = Offset(caretX, caretRect.top) & caretRect.size;

    final double caretHeight = cursorHeight;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        final double fullHeight =
            _textPainter.getFullHeightForCaret(caretPosition, caretPrototype) ??
                _textPainter.preferredLineHeight;
        final double heightDiff = fullHeight - caretRect.height;
        // Center the caret vertically along the text.
        caretRect = Rect.fromLTWH(
          caretRect.left,
          caretRect.top + heightDiff / 2,
          caretRect.width,
          caretRect.height,
        );
      case TargetPlatform.android:
      case TargetPlatform.ohos:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        // Override the height to take the full height of the glyph at the TextPosition
        // when not on iOS. iOS has special handling that creates a taller caret.
        // TODO(garyq): See the TODO for _computeCaretPrototype().
        caretRect = Rect.fromLTWH(
          caretRect.left,
          caretRect.top - _kCaretHeightOffset,
          caretRect.width,
          caretHeight,
        );
    }

    caretRect = caretRect.shift(_paintOffset);
    return caretRect.shift(_snapToPhysicalPixel(caretRect.topLeft));
  }
}
