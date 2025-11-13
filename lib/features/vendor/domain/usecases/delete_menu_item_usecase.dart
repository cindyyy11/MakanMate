import '../repositories/vendor_repository.dart';

class DeleteMenuItemUseCase {
  final VendorRepository repository;
  DeleteMenuItemUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteMenuItem(id);
  }
}
