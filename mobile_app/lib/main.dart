import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uinlp_annotate/features/annotate_task/bloc/annotate_task_bloc.dart';
import 'package:uinlp_annotate/repositories/asset.dart';
import 'package:uinlp_annotate/repositories/task.dart';
import 'package:uinlp_annotate/repositories/user.dart';
import 'package:uinlp_annotate/utilities/router.dart';
import 'package:uinlp_annotate/utilities/theme.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

import 'amplify_outputs.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await _configureAmplify();
    runApp(const MainApp());
  } on AmplifyException catch (e) {
    runApp(Text("Error configuring Amplify: ${e.message}"));
  }
}

Future<void> _configureAmplify() async {
  try {
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.configure(amplifyConfig);
    safePrint('Successfully configured');
  } on Exception catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final userRepo = UserRepository();
    final taskRepo = TaskRepository();
    final assetRepo = AssetRepository();
    Future<String> tokenRetriever() async {
      final result = await Amplify.Auth.getPlugin(
        AmplifyAuthCognito.pluginKey,
      ).fetchAuthSession();
      return result.userPoolTokensResult.value.idToken.raw;
    }

    userRepo.init(accessTokenRetriever: tokenRetriever);
    taskRepo.init(accessTokenRetriever: tokenRetriever);
    assetRepo.init(accessTokenRetriever: tokenRetriever);
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepository>(create: (context) => userRepo),
        RepositoryProvider<TaskRepository>(create: (context) => taskRepo),
        RepositoryProvider<AssetRepository>(create: (context) => assetRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AnnotateTaskBloc(
              taskRepo: context.read<TaskRepository>(),
              assetRepo: context.read<AssetRepository>(),
              userRepo: context.read<UserRepository>(),
            ),
          ),
        ],
        child: Authenticator(
          child: MaterialApp.router(
            title: 'UINLP Annotate',
            theme: appLightTheme,
            darkTheme: appDarkTheme,
            themeMode: ThemeMode.system,
            routerConfig: appRouter,
            builder: Authenticator.builder(),
            // builder: (context, child) {
            //   print("Initializing repositories");
            //   return FutureBuilder(
            //     key: ValueKey("123"),
            //     future: context.read<UinlpAnnotateRepository>().init(),
            //     builder: (context, asyncSnapshot) {
            //       if (asyncSnapshot.connectionState != ConnectionState.done) {
            //         return const Center(child: CircularProgressIndicator());
            //       }
            //       return child ?? const SizedBox.shrink();
            //     },
            //   );
            // },
          ),
        ),
      ),
    );
  }
}
