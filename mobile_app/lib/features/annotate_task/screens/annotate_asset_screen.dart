import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uinlp_annotate/components/asset_tile.dart';
import 'package:uinlp_annotate/components/status_card.dart';
import 'package:uinlp_annotate/features/annotate_task/bloc/annotate_task_bloc.dart';
import 'package:uinlp_annotate/features/annotate_task/screens/annotate_editor_screen.dart';
import 'package:uinlp_annotate/models/annotate_task.dart';
import 'package:uinlp_annotate/repositories/asset.dart';
import 'package:uinlp_annotate/utilities/helper.dart';
import 'package:uinlp_annotate/utilities/status.dart';

class AnnotateAssetScreen extends StatelessWidget {
  const AnnotateAssetScreen({super.key, required this.routerState});
  final GoRouterState routerState;

  static const routeName = "annotate-assets-list";

  static const modalityQueryParam = "modality";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$modalityTitle Assets")),
      body: BlocListener<AnnotateTaskBloc, AnnotateTaskState>(
        listenWhen: (previous, current) {
          return current.status.event is CreateAnnotateTaskEvent;
        },
        listener: (context, state) {
          if (state.status is LoadingStatus) {
            showLoadingDialog(context);
          }
          if (state.status is SuccessStatus) {
            context.goNamed(
              AnnotateEditorScreen.routeName,
              queryParameters: {
                AnnotateEditorScreen.idQueryParam: state.status.data,
              },
            );
          }
          if (state.status is ErrorStatus) {
            final errorStatus = state.status as ErrorStatus;
            showErrorDialog(
              context,
              "Error",
              "Failed to create annotate task:\n${errorStatus.data.message}",
            );
          }
        },
        child: FutureBuilder(
          future: context.read<AssetRepository>().getRecentAssets(
            modality: AnnotateModalityEnum.values
                .where((e) => e.repr == modality)
                .first,
          ),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.waiting) {
              return LoadingCard();
            }
            if (asyncSnapshot.hasError) {
              debugPrintStack(stackTrace: asyncSnapshot.stackTrace);
              return ErrorCard(
                title: "Error",
                message: "Failed to load assets: ${asyncSnapshot.error}",
              );
            }
            if (asyncSnapshot.data!.isEmpty) {
              return ErrorCard(title: "Oops", message: "No assets found");
            }
            return Column(
              crossAxisAlignment: .stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    left: 16,
                    right: 16,
                    bottom: 32,
                  ),
                  child: Text(
                    "Choose an asset to annotate 👇",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: GridView.extent(
                    maxCrossAxisExtent: 800,
                    padding: const EdgeInsets.all(16),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio:
                        MediaQuery.sizeOf(context).width /
                        (MediaQuery.sizeOf(context).width < 850 ? 125 : 250),
                    children: [
                      for (final asset in asyncSnapshot.data!)
                        AssetTile(asset: asset, margin: .zero),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String? get modality {
    return routerState.uri.queryParameters[modalityQueryParam];
  }

  String get modalityTitle {
    if (modality == null) return "Annotate";
    return AnnotateModalityEnum.values
        .firstWhere((e) => e.repr == modality)
        .repr
        .toTitleCase(sep: '_');
  }
}
