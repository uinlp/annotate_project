import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoadingCard extends StatefulWidget {
  const LoadingCard({super.key, this.message = "Loading..."});

  final String message;

  @override
  State<LoadingCard> createState() => _LoadingCardState();
}

class _LoadingCardState extends State<LoadingCard> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        color: Theme.of(context).colorScheme.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            const SizedBox(width: 16.0),
            Text(widget.message, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class ErrorCard extends StatelessWidget {
  const ErrorCard({
    super.key,
    required this.title,
    required this.message,
    this.actions,
  });

  final String title;
  final String message;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions:
          actions ??
          [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: Text("OK"),
            ),
          ],
    );
  }
}

class SuccessCard extends StatelessWidget {
  const SuccessCard({
    super.key,
    required this.message,
    this.actions,
    this.title,
  });

  final String message;
  final List<Widget>? actions;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title ?? "Success"),
      content: Text(message),
      actions:
          actions ??
          [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: Text("OK"),
            ),
          ],
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.message, this.actions, this.title});
  final String? title;
  final String message;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title ?? "Info"),
      content: Text(message),
      actions:
          actions ??
          [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: Text("OK"),
            ),
          ],
    );
  }
}

showLoadingDialog(BuildContext context, {String? message}) {
  return showDialog(
    context: context,
    routeSettings: RouteSettings(name: "loading-dialog"),
    barrierDismissible: false,
    builder: (context) {
      return PopScope(
        canPop: false,
        child: Center(child: LoadingCard(message: message ?? "Loading...")),
      );
    },
  );
}

hideLoadingDialog(BuildContext context) {
  return Navigator.of(context, rootNavigator: true).popUntil((route) {
    return route.settings.name != "loading-dialog";
  });
}

showErrorDialog(
  BuildContext context,
  String title,
  String message, {
  List<Widget>? actions,
}) {
  hideLoadingDialog(context);
  return showDialog(
    context: context,
    routeSettings: RouteSettings(name: "error-dialog"),
    barrierDismissible: false,
    builder: (context) {
      return ErrorCard(title: title, message: message, actions: actions);
    },
  );
}

showSuccessDialog(
  BuildContext context,
  String message, {
  List<Widget>? actions,
  String? title,
}) {
  hideLoadingDialog(context);
  return showDialog(
    context: context,
    routeSettings: RouteSettings(name: "success-dialog"),
    barrierDismissible: false,
    builder: (context) {
      return SuccessCard(message: message, actions: actions, title: title);
    },
  );
}

showInfoDialog(
  BuildContext context,
  String message, {
  List<Widget>? actions,
  String? title,
}) {
  hideLoadingDialog(context);
  return showDialog(
    context: context,
    routeSettings: RouteSettings(name: "info-dialog"),
    barrierDismissible: false,
    builder: (context) {
      return InfoCard(message: message, actions: actions, title: title);
    },
  );
}
