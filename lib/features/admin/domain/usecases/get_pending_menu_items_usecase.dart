import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/data/datasources/admin_menu_management_datasource.dart';

/// Use case to get pending menu items
class GetPendingMenuItemsUseCase {
  final AdminMenuManagementDataSource dataSource;

  GetPendingMenuItemsUseCase(this.dataSource);

  Future<Either<Failure, List<Map<String, dynamic>>>> call() async {
    try {
      final items = await dataSource.getPendingMenuItems();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

