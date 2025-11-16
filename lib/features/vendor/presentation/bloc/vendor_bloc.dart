import 'package:flutter_bloc/flutter_bloc.dart';
import 'vendor_event.dart';
import 'vendor_state.dart';
import '../../../vendor/domain/usecases/get_menu_items_usecase.dart';
import '../../../vendor/domain/usecases/add_menu_item_usecase.dart';
import '../../../vendor/domain/usecases/update_menu_item_usecase.dart';
import '../../../vendor/domain/usecases/delete_menu_item_usecase.dart';
import '../../../vendor/domain/entities/menu_item_entity.dart';
import '../../../vendor/data/services/storage_service.dart';

class VendorBloc extends Bloc<VendorEvent, VendorState> {
  final GetMenuItemsUseCase getMenuItems;
  final AddMenuItemUseCase addMenuItem;
  final UpdateMenuItemUseCase updateMenuItem;
  final DeleteMenuItemUseCase deleteMenuItem;
  final StorageService storageService;

  VendorBloc({
    required this.getMenuItems,
    required this.addMenuItem,
    required this.updateMenuItem,
    required this.deleteMenuItem,
    required this.storageService,
  }) : super(VendorInitial()) {
    on<LoadMenuEvent>(_onLoadMenu);
    on<SearchMenuEvent>(_onSearchMenu);
    on<FilterByCategoryEvent>(_onFilterByCategory);
    on<UploadImageEvent>(_onUploadImage);
    on<AddMenuEvent>(_onAddMenu);
    on<UpdateMenuEvent>(_onUpdateMenu);
    on<DeleteMenuEvent>(_onDeleteMenu);
  }

  Future<void> _onLoadMenu(LoadMenuEvent event, Emitter emit) async {
    emit(VendorLoading());
    try {
      final items = await getMenuItems();

      final categories = ["All", ...items.map((i) => i.category).toSet()];

      emit(VendorLoaded(items, filteredMenu: items, categories: categories));
    } catch (e) {
      emit(VendorError(e.toString()));
    }
  }

  void _onSearchMenu(SearchMenuEvent event, Emitter emit) {
    if (state is! VendorLoaded) return;

    final s = state as VendorLoaded;
    final query = event.query.toLowerCase();

    var filtered = s.menu.where((item) {
      return item.name.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query);
    }).toList();

    emit(
      VendorLoaded(
        s.menu,
        filteredMenu: filtered,
        categories: s.categories,
        selectedCategory: s.selectedCategory,
        searchQuery: query,
      ),
    );
  }

  void _onFilterByCategory(FilterByCategoryEvent event, Emitter emit) {
    if (state is! VendorLoaded) return;

    final s = state as VendorLoaded;
    final category = event.category;

    List<MenuItemEntity> filtered = s.menu;

    if (category != null && category != "All") {
      filtered = filtered.where((item) => item.category == category).toList();
    }

    emit(
      VendorLoaded(
        s.menu,
        filteredMenu: filtered,
        categories: s.categories,
        selectedCategory: category,
        searchQuery: s.searchQuery,
      ),
    );
  }

  Future<void> _onUploadImage(UploadImageEvent event, Emitter emit) async {
    try {
      emit(ImageUploading());
      final imageUrl = await storageService.uploadMenuItemImage(
        event.imageFile,
      );
      emit(ImageUploaded(imageUrl));
    } catch (e) {
      emit(ImageUploadError(e.toString()));
    }
  }

  Future<void> _onAddMenu(AddMenuEvent event, Emitter emit) async {
    try {
      String imageUrl = event.item.imageUrl;

      if (event.imageFile != null) {
        emit(ImageUploading());
        imageUrl = await storageService.uploadMenuItemImage(event.imageFile!);
      }

      final item = event.item.copyWith(imageUrl: imageUrl);
      await addMenuItem(item);

      add(LoadMenuEvent());
    } catch (e) {
      emit(VendorError(e.toString()));
    }
  }

  Future<void> _onUpdateMenu(UpdateMenuEvent event, Emitter emit) async {
    try {
      String imageUrl = event.item.imageUrl;

      if (event.imageFile != null) {
        emit(ImageUploading());
        imageUrl = await storageService.uploadMenuItemImage(event.imageFile!);
      }

      final item = event.item.copyWith(imageUrl: imageUrl);
      await updateMenuItem(item);

      add(LoadMenuEvent());
    } catch (e) {
      emit(VendorError(e.toString()));
    }
  }

  Future<void> _onDeleteMenu(DeleteMenuEvent event, Emitter emit) async {
    try {
      await deleteMenuItem(event.id);
      add(LoadMenuEvent());
    } catch (e) {
      emit(VendorError(e.toString()));
    }
  }
}
