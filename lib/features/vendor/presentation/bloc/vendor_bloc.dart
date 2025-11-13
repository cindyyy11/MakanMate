import 'package:flutter_bloc/flutter_bloc.dart';
import 'vendor_event.dart';
import 'vendor_state.dart';
import '../../../vendor/domain/usecases/get_menu_items_usecase.dart';
import '../../../vendor/domain/usecases/add_menu_item_usecase.dart';
import '../../../vendor/domain/usecases/update_menu_item_usecase.dart';
import '../../../vendor/domain/usecases/delete_menu_item_usecase.dart';
import '../../../vendor/data/services/storage_service.dart';
import '../../../vendor/domain/entities/menu_item_entity.dart';

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

      // Extract unique categories
      final Set<String> categorySet = {};
      for (var item in items) {
        if (item.category.isNotEmpty) {
          categorySet.add(item.category);
        }
      }

      final categories = ["All", ...categorySet];

      emit(VendorLoaded(
        items,
        filteredMenu: items,
        selectedCategory: null,
        searchQuery: '',
        categories: categories,
      ));
    } catch (e) {
      emit(VendorError(e.toString()));
    }
  }


  void _onSearchMenu(SearchMenuEvent event, Emitter emit) {
    if (state is! VendorLoaded) return;

    final currentState = state as VendorLoaded;
    final query = event.query.toLowerCase().trim();

    List<MenuItemEntity> filtered = currentState.menu;

    // Apply category filter if exists
    if (currentState.selectedCategory != null) {
      filtered = filtered.where((item) =>
          item.category.toLowerCase() ==
          currentState.selectedCategory!.toLowerCase()).toList();
    }

    // Apply search query
    if (query.isNotEmpty) {
      filtered = filtered.where((item) =>
          item.name.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query)).toList();
    }

    emit(VendorLoaded(
      currentState.menu,
      filteredMenu: filtered,
      selectedCategory: currentState.selectedCategory,
      searchQuery: query,
      categories: currentState.categories,
    ));
  }

  void _onFilterByCategory(FilterByCategoryEvent event, Emitter emit) {
    if (state is! VendorLoaded) return;

    final currentState = state as VendorLoaded;
    final category = event.category;

    List<MenuItemEntity> filtered = currentState.menu;

    // Apply category filter
    if (category != null) {
      filtered = filtered.where((item) =>
          item.category.toLowerCase() == category.toLowerCase()).toList();
    }

    // Apply search query
    if (currentState.searchQuery.isNotEmpty) {
      final query = currentState.searchQuery.toLowerCase();
      filtered = filtered.where((item) =>
          item.name.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query)).toList();
    }

    emit(VendorLoaded(
      currentState.menu,
      filteredMenu: filtered,
      selectedCategory: category,
      searchQuery: currentState.searchQuery,
      categories: currentState.categories,
    ));
  }


  Future<void> _onUploadImage(UploadImageEvent event, Emitter emit) async {
    try {
      emit(ImageUploading());
      final imageUrl = await storageService.uploadMenuItemImage(event.imageFile);
      emit(ImageUploaded(imageUrl));
    } catch (e) {
      emit(ImageUploadError('Failed to upload image: ${e.toString()}'));
    }
  }

  Future<void> _onAddMenu(AddMenuEvent event, Emitter emit) async {
    try {
      String imageUrl = event.item.imageUrl;
      
      // Upload image if provided
      if (event.imageFile != null) {
        emit(ImageUploading());
        try {
          imageUrl = await storageService.uploadMenuItemImage(event.imageFile!);
        } catch (e) {
          emit(VendorError('Failed to upload image: ${e.toString()}'));
          return;
        }
      }

      // Create menu item with uploaded image URL
      final menuItem = MenuItemEntity(
        id: event.item.id,
        name: event.item.name,
        description: event.item.description,
        category: event.item.category,
        price: event.item.price,
        calories: event.item.calories,
        imageUrl: imageUrl,
        available: event.item.available,
      );

      await addMenuItem(menuItem);
      add(LoadMenuEvent());
    } catch (e) {
      emit(VendorError('Failed to add menu item: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateMenu(UpdateMenuEvent event, Emitter emit) async {
    try {
      String imageUrl = event.item.imageUrl;
      
      // Upload new image if provided
      if (event.imageFile != null) {
        emit(ImageUploading());
        try {
          imageUrl = await storageService.uploadMenuItemImage(event.imageFile!);
        } catch (e) {
          emit(VendorError('Failed to upload image: ${e.toString()}'));
          return;
        }
      }

      // Update menu item with new image URL
      final menuItem = MenuItemEntity(
        id: event.item.id,
        name: event.item.name,
        description: event.item.description,
        category: event.item.category,
        price: event.item.price,
        calories: event.item.calories,
        imageUrl: imageUrl,
        available: event.item.available,
      );

      await updateMenuItem(menuItem);
      add(LoadMenuEvent());
    } catch (e) {
      emit(VendorError('Failed to update menu: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteMenu(DeleteMenuEvent event, Emitter emit) async {
    try {
      await deleteMenuItem(event.id);
      add(LoadMenuEvent());
    } catch (e) {
      emit(VendorError('Failed to delete menu item.'));
    }
  }
}
