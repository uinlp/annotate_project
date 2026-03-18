import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uinlp_annotate/components/status_card.dart';
import 'package:uinlp_annotate/features/annotate_task/bloc/annotate_task_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const routeName = 'profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AuthUser? _user;
  List<AuthUserAttribute>? _attributes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      final attributes = await Amplify.Auth.fetchUserAttributes();
      if (mounted) {
        setState(() {
          _user = user;
          _attributes = attributes;
          _isLoading = false;
        });
      }
    } on AuthException catch (e) {
      safePrint('Error fetching user data: ${e.message}');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await Amplify.Auth.signOut();
    } on AuthException catch (e) {
      safePrint('Error signing out: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _isLoading
          ? LoadingCard()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      _user?.username[0].toUpperCase() ?? '?',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _user?.username ?? 'Unknown User',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _attributes
                            ?.firstWhere(
                              (attr) =>
                                  attr.userAttributeKey ==
                                  AuthUserAttributeKey.email,
                              orElse: () => const AuthUserAttribute(
                                userAttributeKey: AuthUserAttributeKey.email,
                                value: 'No email',
                              ),
                            )
                            .value ??
                        'No email found',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 48),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('User ID'),
                    subtitle: Text(_user?.userId ?? 'N/A'),
                  ),
                  const Divider(),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      backgroundColor: theme.colorScheme.errorContainer,
                      foregroundColor: theme.colorScheme.onErrorContainer,
                    ).copyWith(elevation: ButtonStyleButton.allOrNull(0)),
                  ),
                  // const Divider(),
                  // Text("Recent Tasks Panel", style: theme.textTheme.headlineSmall),
                  // BlocBuilder<AnnotateTaskBloc, AnnotateTaskState>(
                  //   builder: (context, state) {
                  //     return Column(
                  //       children: [
                  //         for (final task in state.tasks)

                  //       ],
                  //     );
                  //   },
                  // ),
                ],
              ),
            ),
    );
  }
}
