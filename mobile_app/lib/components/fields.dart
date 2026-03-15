import 'package:flutter/material.dart';
import 'package:uinlp_annotate/features/annotate_task/screens/annotate_editor_screen.dart';
import 'package:uinlp_annotate/models/annotate_task.dart';

class AnnotateTextField extends StatefulWidget {
  const AnnotateTextField({
    super.key,
    required this.field,
    required this.theme,
  });

  final AnnotateFieldStateModel field;
  final ThemeData theme;

  @override
  State<AnnotateTextField> createState() => _AnnotateTextFieldState();
}

class _AnnotateTextFieldState extends State<AnnotateTextField> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.field.value.value);
    widget.field.value.addListener(() {
      setState(() {
        controller.text = widget.field.value.value ?? "";
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onSaved: (value) {
        if (value != null && value.isNotEmpty) {
          widget.field.value.value = value;
        } else {
          widget.field.value.value = null;
        }
      },
      decoration: InputDecoration(
        labelText: widget.field.name.toTitleCase(),
        hintText: widget.field.description,
        suffixIcon: ValueListenableBuilder(
          valueListenable: controller,
          builder: (context, value, child) {
            return Icon(
              Icons.check_circle,
              color: widget.field.value.value == value.text
                  ? widget.theme.colorScheme.primary
                  : value.text.isNotEmpty
                  ? Colors.orange
                  : widget.theme.colorScheme.outline,
            );
          },
        ),
      ),
    );
  }
}

class AnnotateAudioField extends StatelessWidget {
  const AnnotateAudioField({super.key, required this.field});

  final AnnotateFieldStateModel field;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class AnnotateImageField extends StatelessWidget {
  const AnnotateImageField({super.key, required this.field});

  final AnnotateFieldStateModel field;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class AnnotateVideoField extends StatelessWidget {
  const AnnotateVideoField({super.key, required this.field});

  final AnnotateFieldStateModel field;

  @override
  Widget build(BuildContext context) {
    field.
    return const Placeholder();
  }
}
