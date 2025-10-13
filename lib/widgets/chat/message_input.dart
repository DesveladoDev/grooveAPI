import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MessageInputWidget extends StatefulWidget {

  const MessageInputWidget({
    required this.controller, required this.onSendMessage, required this.onStartTyping, required this.onAttachImage, required this.onAttachFile, super.key,
    this.isLoading = false,
  });
  final TextEditingController controller;
  final Function(String) onSendMessage;
  final VoidCallback onStartTyping;
  final VoidCallback onAttachImage;
  final VoidCallback onAttachFile;
  final bool isLoading;

  @override
  State<MessageInputWidget> createState() => _MessageInputWidgetState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TextEditingController>('controller', controller));
    properties.add(ObjectFlagProperty<Function(String p1)>.has('onSendMessage', onSendMessage));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onStartTyping', onStartTyping));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onAttachImage', onAttachImage));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onAttachFile', onAttachFile));
    properties.add(DiagnosticsProperty<bool>('isLoading', isLoading));
  }
}

class _MessageInputWidgetState extends State<MessageInputWidget> {
  bool _isExpanded = false;
  bool _hasText = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
    
    if (hasText) {
      widget.onStartTyping();
    }
  }

  void _onFocusChanged() {
    setState(() {
      _isExpanded = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!_hasText && !_isExpanded) _buildAttachmentButton(theme),
          const SizedBox(width: 8),
          Expanded(
            child: _buildMessageField(theme),
          ),
          const SizedBox(width: 8),
          _buildSendButton(theme),
        ],
      ),
    );
  }

  Widget _buildAttachmentButton(ThemeData theme) => PopupMenuButton<String>(
      onSelected: _handleAttachmentSelection,
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.attach_file,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'image',
          child: Row(
            children: [
              Icon(
                Icons.image,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              const Text('Imagen'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'file',
          child: Row(
            children: [
              Icon(
                Icons.insert_drive_file,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              const Text('Archivo'),
            ],
          ),
        ),
      ],
    );

  Widget _buildMessageField(ThemeData theme) => Container(
      constraints: const BoxConstraints(
        minHeight: 40,
        maxHeight: 120,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _focusNode.hasFocus
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.3),
          width: _focusNode.hasFocus ? 2 : 1,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        maxLines: null,
        textInputAction: TextInputAction.newline,
        keyboardType: TextInputType.multiline,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Escribe un mensaje...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
        onSubmitted: _hasText ? _handleSendMessage : null,
      ),
    );

  Widget _buildSendButton(ThemeData theme) {
    final canSend = _hasText && !widget.isLoading;
    
    return GestureDetector(
      onTap: canSend ? () => _handleSendMessage(widget.controller.text) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: canSend
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
          boxShadow: canSend
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: widget.isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : Icon(
                Icons.send,
                color: canSend
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
      ),
    );
  }

  void _handleSendMessage(String message) {
    if (message.trim().isEmpty || widget.isLoading) return;
    
    HapticFeedback.lightImpact();
    widget.onSendMessage(message.trim());
  }

  void _handleAttachmentSelection(String type) {
    HapticFeedback.selectionClick();
    
    switch (type) {
      case 'image':
        widget.onAttachImage();
        break;
      case 'file':
        widget.onAttachFile();
        break;
    }
  }
}

class MessageInputField extends StatefulWidget {

  const MessageInputField({
    required this.controller, super.key,
    this.hintText = 'Escribe un mensaje...',
    this.onSubmitted,
    this.onChanged,
    this.enabled = true,
    this.maxLines,
    this.minLines = 1,
  });
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onSubmitted;
  final VoidCallback? onChanged;
  final bool enabled;
  final int? maxLines;
  final int? minLines;

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TextEditingController>('controller', controller));
    properties.add(StringProperty('hintText', hintText));
    properties.add(ObjectFlagProperty<Function(String p1)?>.has('onSubmitted', onSubmitted));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onChanged', onChanged));
    properties.add(DiagnosticsProperty<bool>('enabled', enabled));
    properties.add(IntProperty('maxLines', maxLines));
    properties.add(IntProperty('minLines', minLines));
  }
}

class _MessageInputFieldState extends State<MessageInputField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onTextChanged() {
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isFocused
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.3),
          width: _isFocused ? 2 : 1,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        textInputAction: TextInputAction.newline,
        keyboardType: TextInputType.multiline,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
        ),
        onSubmitted: widget.onSubmitted,
      ),
    );
  }
}