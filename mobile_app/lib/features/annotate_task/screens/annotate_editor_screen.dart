import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uinlp_annotate/components/annotate_editor_grid_view.dart';
import 'package:uinlp_annotate/components/annotate_editor_info_view.dart';
import 'package:uinlp_annotate/components/displays.dart';
import 'package:uinlp_annotate/components/fields.dart';
import 'package:uinlp_annotate/features/annotate_task/bloc/annotate_task_bloc.dart';
import 'package:uinlp_annotate/features/main/screens/dashboard_screen.dart';
import 'package:uinlp_annotate/models/annotate_task.dart';

class AnnotateEditorScreen extends StatefulWidget {
  const AnnotateEditorScreen({super.key, required this.routerState});
  final GoRouterState routerState;

  static const String routeName = "annotate-editor";
  static const String idQueryParam = "id";

  @override
  State<AnnotateEditorScreen> createState() => _AnnotateEditorScreenState();
}

class _AnnotateEditorScreenState extends State<AnnotateEditorScreen> {
  List<AnnotateFieldStateModel> fields = [];
  String? taskId;
  ValueNotifier<int> currentDataIndex = ValueNotifier(0);
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    debugPrint("I'm here");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      taskId = widget
          .routerState
          .uri
          .queryParameters[AnnotateEditorScreen.idQueryParam];
      final state = context.read<AnnotateTaskBloc>().state;
      final task = state.tasks.where((e) => e.id == taskId).firstOrNull;
      debugPrint("Task field count: ${task?.annotateFields.length}");
      setState(() {
        if (task != null) {
          fields = task.annotateFields
              .map(
                (e) => AnnotateFieldStateModel(
                  name: e.name,
                  modality: e.modality,
                  description: e.description,
                ),
              )
              .toList();
        }
      });

      // load current fields on init
      loadCurrentFields();

      // load current fields on data index change
      currentDataIndex.addListener(() {
        debugPrint("Current data index changed: ${currentDataIndex.value}");
        loadCurrentFields();
      });
    });
  }

  void loadCurrentFields() async {
    final state = context.read<AnnotateTaskBloc>().state;
    final task = state.tasks.where((e) => e.id == taskId).firstOrNull;
    if (task == null) return;
    for (var field in fields) {
      field.file.value = await task.loadDataFieldFile(
        currentDataIndex.value,
        field,
      );
      if (field.file.value.existsSync()) {
        if (field.modality == AnnotateModalityEnum.text) {
          field.value.value = await field.file.value.readAsString();
        } else {
          field.value.value = await field.file.value.readAsBytes();
        }
      } else {
        field.value.value = null;
      }
    }
  }

  void goto(int index) {
    currentDataIndex.value = index;
  }

  void next() {
    final totalData = context
        .read<AnnotateTaskBloc>()
        .state
        .tasks
        .where((e) => e.id == taskId)
        .firstOrNull
        ?.dataIds
        .length;
    if (totalData == null) return;
    if (currentDataIndex.value < (totalData - 1)) {
      currentDataIndex.value += 1;
    }
  }

  void previous() {
    if (currentDataIndex.value > 0) {
      currentDataIndex.value -= 1;
    }
  }

  Future<bool> saveCurrentAnnotations() async {
    _formKey.currentState!.save(); // update all fields value
    final task = context
        .read<AnnotateTaskBloc>()
        .state
        .tasks
        .where((e) => e.id == taskId)
        .firstOrNull;
    if (task == null) return false;
    Map<String, dynamic> commitData = {};
    for (var field in fields) {
      if (field.value.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Field '${field.name}' cannot be empty.")),
        );
        return false;
      }
      if (!field.file.value.existsSync()) {
        field.file.value.createSync(recursive: true);
      }
      if (field.modality == AnnotateModalityEnum.text) {
        field.file.value.writeAsStringSync(field.value.value ?? "");
      } else {
        field.file.value.writeAsBytesSync(field.value.value ?? []);
      }
      commitData[field.name] = field.file.value.path;
    }
    await task.updateCommit(task.dataIds[currentDataIndex.value], commitData);
    return true;
  }

  bool canBePublished() {
    if (!mounted) return false;
    final task = context
        .read<AnnotateTaskBloc>()
        .state
        .tasks
        .where((e) => e.id == taskId)
        .firstOrNull;
    if (task == null) return false;
    return task.progress >= 1.0;
  }

  @override
  void dispose() {
    currentDataIndex.dispose();
    for (var field in fields) {
      field.value.dispose();
      field.file.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder(
          valueListenable: currentDataIndex,
          builder: (context, value, child) {
            return Text("Annotate Editor [${currentDataIndex.value + 1}]");
          },
        ),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: () {
                  final scaffold = Scaffold.of(context);
                  if (scaffold.hasEndDrawer) {
                    scaffold.openEndDrawer();
                  }
                },
                icon: Icon(Icons.info_outline),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 24,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ValueListenableBuilder(
                valueListenable: currentDataIndex,
                builder: (context, value, child) {
                  // state.tasks.where((e) => e.id == taskId).firstOrNull
                  final task = context
                      .read<AnnotateTaskBloc>()
                      .state
                      .tasks
                      .where((e) => e.id == taskId)
                      .firstOrNull;
                  if (task == null) {
                    return Text(
                      "Task not found",
                      style: theme.textTheme.headlineMedium,
                    );
                  }
                  return FutureBuilder(
                    future: task.loadDataFile(value),
                    builder: (context, asyncSnapshot) {
                      if (asyncSnapshot.hasError) {
                        return Text(
                          "Error loading data ${asyncSnapshot.error}",
                          style: theme.textTheme.headlineMedium,
                        );
                      }
                      if (!asyncSnapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      switch (task.modality) {
                        case AnnotateModalityEnum.text:
                          return AnnotateTextDisplay(file: asyncSnapshot.data!);
                        case AnnotateModalityEnum.audio:
                          return AnnotateAudioDisplay(
                            file: asyncSnapshot.data!,
                          );
                        case AnnotateModalityEnum.image:
                          return AnnotateImageDisplay(
                            file: asyncSnapshot.data!,
                          );
                        case AnnotateModalityEnum.video:
                          return AnnotateVideoDisplay(
                            file: asyncSnapshot.data!,
                          );
                      }
                    },
                  );
                },
              ),
              for (var field in fields)
                switch (field.modality) {
                  AnnotateModalityEnum.text => AnnotateTextField(
                    key: ValueKey(field.name),
                    field: field,
                    theme: theme,
                  ),
                  AnnotateModalityEnum.audio => AnnotateAudioField(
                    key: ValueKey(field.name),
                    field: field,
                  ),
                  AnnotateModalityEnum.image => AnnotateImageField(
                    key: ValueKey(field.name),
                    field: field,
                  ),
                  AnnotateModalityEnum.video => AnnotateVideoField(
                    key: ValueKey(field.name),
                    field: field,
                  ),
                },
            ],
          ),
        ),
      ),
      drawer: ValueListenableBuilder(
        valueListenable: currentDataIndex,
        builder: (context, value, child) {
          return AnnotateEditorGridView(
            taskId: taskId,
            currentDataIndex: currentDataIndex.value,
            onDataIndexPressed: (index) {
              goto(index);
              context.pop();
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final enablePublish = canBePublished();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("More Actions", style: theme.textTheme.titleLarge),
                  ListTile(
                    leading: const Icon(Icons.save),
                    title: const Text("Save"),
                    onTap: () {
                      saveCurrentAnnotations();
                      context.pop();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.arrow_forward),
                    title: const Text("Next"),
                    onTap: () {
                      next();
                      context.pop();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.arrow_back),
                    title: const Text("Previous"),
                    onTap: () {
                      previous();
                      context.pop();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout_sharp),
                    title: const Text("Exit"),
                    onTap: () {
                      context.goNamed(DashboardScreen.routeName);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text("Save & Exit"),
                    onTap: () async {
                      final saved = await saveCurrentAnnotations();
                      context.pop();
                      if (saved) {
                        context.goNamed(DashboardScreen.routeName);
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.publish),
                    title: const Text("Publish"),
                    onTap: () {
                      context.pop();
                    },
                    enabled: enablePublish,
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.keyboard_arrow_up),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        color: theme.colorScheme.surfaceContainerLow,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BottomActionButton(
              icon: Icons.arrow_back,
              label: "Previous",
              onPressed: () {
                previous();
              },
            ),
            BottomActionButton(
              icon: Icons.arrow_forward,
              label: "Save & Next",
              onPressed: () async {
                final saved = await saveCurrentAnnotations();
                if (saved) {
                  next();
                }
              },
            ),
          ],
        ),
      ),
      endDrawer: AnnotateEditorInfoView(taskId: taskId),
    );
  }
}

class BottomActionButton extends StatelessWidget {
  const BottomActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(icon), Text(label)],
          ),
        ),
      ),
    );
  }
}

class AnnotateFieldStateModel extends AnnotateFieldModel {
  AnnotateFieldStateModel({
    required super.name,
    required super.modality,
    required super.description,
    ValueNotifier<dynamic>? value,
    ValueNotifier<File>? file,
  }) : value = value ?? ValueNotifier<dynamic>(null),
       file = file ?? ValueNotifier<File>(File(""));
  final ValueNotifier<dynamic> value;
  final ValueNotifier<File> file;
}
