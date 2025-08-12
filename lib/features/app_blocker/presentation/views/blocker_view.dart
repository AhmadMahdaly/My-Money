import 'package:app_usage/app_usage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/features/app_blocker/data/models/app_rule.dart';
import 'package:opration/features/app_blocker/presentation/bloc/blocker_bloc.dart';
import 'package:opration/features/app_blocker/presentation/views/widgets/app_list_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مراقب التطبيقات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HomeLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(LoadInstalledApps());
              },
              child: ListView.builder(
                itemCount: state.apps.length,
                itemBuilder: (context, index) {
                  final app = state.apps[index];

                  final rule = state.rules.firstWhere(
                    (r) => r.packageName == app.packageName,
                    orElse: () => AppRule(packageName: app.packageName),
                  );

                  final usage = state.usageStats.firstWhere(
                    (u) => u.packageName == app.packageName,
                    orElse: () => AppUsageInfo(
                      app.packageName,
                      0,
                      DateTime.now(),
                      DateTime.now(),
                      DateTime.now(),
                    ),
                  );

                  return AppListItem(
                    app: app,
                    rule: rule,
                    usage: usage.usage,
                    onTap: () {
                      context.push('/details', extra: app).then((_) {
                        context.read<HomeBloc>().add(LoadInstalledApps());
                      });
                    },
                  );
                },
              ),
            );
          }
          if (state is HomeError) {
            return Center(child: Text('حدث خطأ: ${state.message}'));
          }
          return const Center(child: Text('الرجاء الانتظار...'));
        },
      ),
    );
  }
}
