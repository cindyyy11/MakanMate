import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/data/datasources/admin_menu_management_datasource.dart';

/// Use case to approve a menu item
class ApproveMenuItemUseCase {
  final AdminMenuManagementDataSource dataSource;

  ApproveMenuItemUseCase(this.dataSource);

  Future<Either<Failure, void>> call(ApproveMenuItemParams params) async {
    try {
      await dataSource.approveMenuItem(
        vendorId: params.vendorId,
        menuItemId: params.menuItemId,
        featured: params.featured,
        reason: params.reason,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class ApproveMenuItemParams {
  final String vendorId;
  final String menuItemId;
  final bool? featured;
  final String? reason;

  ApproveMenuItemParams({
    required this.vendorId,
    required this.menuItemId,
    this.featured,
    this.reason,
  });
}

