import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/vendor_profile_entity.dart';
import '../../domain/usecases/get_vendor_menu_items_usecase.dart';
import '../../domain/usecases/get_vendor_profile_usecase.dart';
import 'vendor_event.dart';
import 'vendor_state.dart';

class VendorBloc extends Bloc<VendorEvent, VendorState> {
  final GetVendorProfileUseCase getVendorProfile;
  final GetVendorMenuItemsUseCase getVendorMenuItems;

  VendorBloc({
    required this.getVendorProfile,
    required this.getVendorMenuItems,
  }) : super(VendorInitial()) {
    on<LoadVendorProfileEvent>(_onLoadVendorProfile);
    on<LoadVendorMenuEvent>(_onLoadVendorMenu);
  }

  Future<void> _onLoadVendorProfile(
    LoadVendorProfileEvent event,
    Emitter<VendorState> emit,
  ) async {
    emit(VendorLoading());
    try {
      final vendor = await getVendorProfile(event.vendorId);
      final menu = await getVendorMenuItems(event.vendorId);
      emit(VendorLoaded(vendor: vendor, menuItems: menu));
    } catch (e) {
      emit(VendorError(e.toString()));
    }
  }

  Future<void> _onLoadVendorMenu(
    LoadVendorMenuEvent event,
    Emitter<VendorState> emit,
  ) async {
    //
  }
}
