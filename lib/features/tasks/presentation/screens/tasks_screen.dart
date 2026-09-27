import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../exports.dart';

/// Заглушка экрана заданий по ТЗ: только кнопка "Назад".
class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors.mainColors;

    return BlocProvider<TasksCubit>(
      create: (_) => sl<TasksCubit>(),
      child: Scaffold(
        backgroundColor: colors.tasksScreenBackground,
        body: SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back, color: colors.appColorWhite),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
