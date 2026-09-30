import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_tracker/config/routing/app_routes.dart';
import 'package:delivery_tracker/config/routing/routing_extensions.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/core/di/di.dart';
import 'package:delivery_tracker/core/helpers/snackbar_utils.dart';
import '../cubit/deliveries/deliveries_cubit.dart';
import '../cubit/deliveries/deliveries_state.dart';
import '../widgets/list/deliveries_empty_state.dart';
import '../widgets/list/deliveries_error_state.dart';
import '../widgets/list/deliveries_filter_chips.dart';
import '../widgets/list/deliveries_list_view.dart';
import '../widgets/list/deliveries_search_bar.dart';
import '../widgets/radar/deliveries_searching_radar.dart';

/// Primary deliveries listing screen displaying the animated radar on initial load,
/// responsive card list, real-time search, and status filters.
class DeliveriesListPage extends StatelessWidget {
  const DeliveriesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DeliveriesListCubit>()..loadDeliveries(),
      child: const _DeliveriesListViewWrapper(),
    );
  }
}

class _DeliveriesListViewWrapper extends StatefulWidget {
  const _DeliveriesListViewWrapper();

  @override
  State<_DeliveriesListViewWrapper> createState() =>
      _DeliveriesListViewWrapperState();
}

class _DeliveriesListViewWrapperState
    extends State<_DeliveriesListViewWrapper> {
  late final Timer _startupTimer;
  bool _showStartupRadar = true;

  @override
  void initState() {
    super.initState();
    // Keep the startup animation visible even when cached data arrives immediately.
    _startupTimer = Timer(const Duration(milliseconds: 450), () {
      setState(() => _showStartupRadar = false);
    });
  }

  @override
  void dispose() {
    _startupTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveriesListCubit, DeliveriesListState>(
      listenWhen: (prev, current) =>
          prev.errorMessage != current.errorMessage &&
          current.errorMessage != null &&
          current.deliveries.isNotEmpty,
      listener: (context, state) {
        if (state.errorMessage != null) {
          SnackBarUtils.showError(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.spaceMD,
                  AppDimensions.spaceSM,
                  AppDimensions.spaceMD,
                  AppDimensions.spaceSM,
                ),
                child: DeliveriesSearchBar(
                  initialQuery: state.searchQuery,
                  onChanged: (q) =>
                      context.read<DeliveriesListCubit>().searchChanged(q),
                ),
              ),
              DeliveriesFilterChips(
                selectedFilter: state.filter,
                totalCount: state.totalCount,
                pendingCount: state.pendingCount,
                deliveredCount: state.deliveredCount,
                failedCount: state.failedCount,
                onFilterSelected: (DeliveryStatusFilter filter) =>
                    context.read<DeliveriesListCubit>().filterChanged(filter),
              ),
              const SizedBox(height: AppDimensions.spaceSM),
              Expanded(child: _buildListBody(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListBody(BuildContext context, DeliveriesListState state) {
    if (_showStartupRadar || (state.isLoading && state.deliveries.isEmpty)) {
      return const DeliveriesSearchingRadar();
    }

    if (state.status == DeliveriesListStatus.error &&
        state.deliveries.isEmpty) {
      return DeliveriesErrorState(
        message: state.errorMessage,
        onRetry: () => context.read<DeliveriesListCubit>().loadDeliveries(),
      );
    }

    if (state.deliveries.isEmpty) {
      return const DeliveriesEmptyState(isFiltered: false);
    }

    if (state.visibleDeliveries.isEmpty) {
      return const DeliveriesEmptyState(isFiltered: true);
    }

    return DeliveriesListView(
      deliveries: state.visibleDeliveries,
      onRefresh: () => context.read<DeliveriesListCubit>().refresh(),
      onDeliveryTap: (delivery) {
        context.pushNamed(AppRoutes.deliveryDetails, arguments: delivery.id);
      },
    );
  }
}
