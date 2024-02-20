import 'package:a_hole_meter/src/features/onboarding/data/onboarding_repository.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/app_sizes.dart';
import '/src/constants/strings.dart';
import '/src/features/jobs/data/jobs_repository.dart';
import '/src/features/jobs/domain/job.dart';
import '/src/features/jobs/presentation/jobs_screen/jobs_screen_controller.dart';
import '/src/routing/app_router.dart';
import '/src/utils/async_value_ui.dart';

class JobsScreen extends ConsumerWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingRepository =
        ref.watch(onboardingRepositoryProvider).requireValue;
    final isImagePredictorUnlocked =
        onboardingRepository.isImagePredictorUnlocked();
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.people),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => context.goNamed(AppRoute.addJob.name),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Your Assholemeter is Locked!\n\n\n'),
          const Text('To unlock it forever'),
          const Text('Just rate five people from your photo library\n'),
          const Text('Remember! \n - most people are not assholes'),
          gapH32,
          Consumer(
            builder: (context, ref, child) {
              ref.listen<AsyncValue>(
                jobsScreenControllerProvider,
                (_, state) => state.showAlertDialogOnError(context),
              );
              final jobsQuery = ref.watch(jobsQueryProvider);
              return FirestoreListView<Job>(
                shrinkWrap: true,
                query: jobsQuery,
                emptyBuilder: (context) => const Center(child: Text('No data')),
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Text(error.toString()),
                ),
                loadingBuilder: (context) =>
                    const Center(child: CircularProgressIndicator()),
                itemBuilder: (context, doc) {
                  final job = doc.data();
                  return Dismissible(
                    key: Key('job-${job.id}'),
                    background: Container(color: Colors.red),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) => ref
                        .read(jobsScreenControllerProvider.notifier)
                        .deleteJob(job),
                    child: JobListTile(
                      job: job,
                      onTap: () => context.goNamed(
                        AppRoute.job.name,
                        pathParameters: {'id': job.id},
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class JobListTile extends StatelessWidget {
  const JobListTile({super.key, required this.job, this.onTap});
  final Job job;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(job.name),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
