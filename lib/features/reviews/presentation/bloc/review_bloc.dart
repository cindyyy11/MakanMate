// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:makan_mate/features/reviews/domain/usecases/flag_review_usecase.dart';
// import 'package:makan_mate/features/reviews/domain/usecases/get_item_reviews_usecase.dart';
// import 'package:makan_mate/features/reviews/domain/usecases/get_restaurant_reviews_usecase.dart';
// import 'package:makan_mate/features/reviews/domain/usecases/submit_review_usecase.dart';
// import 'package:makan_mate/features/reviews/presentation/bloc/review_event.dart';
// import 'package:makan_mate/features/reviews/presentation/bloc/review_state.dart';
// import 'package:logger/logger.dart';

// /// BLoC for managing review state
// class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
//   final SubmitReviewUseCase submitReview;
//   final GetRestaurantReviewsUseCase getRestaurantReviews;
//   final GetItemReviewsUseCase getItemReviews;
//   final FlagReviewUseCase flagReview;
//   final Logger logger;

//   ReviewBloc({
//     required this.submitReview,
//     required this.getRestaurantReviews,
//     required this.getItemReviews,
//     required this.flagReview,
//     required this.logger,
//   }) : super(ReviewInitial()) {
//     on<SubmitReviewEvent>(_onSubmitReview);
//     on<GetRestaurantReviewsEvent>(_onGetRestaurantReviews);
//     on<GetItemReviewsEvent>(_onGetItemReviews);
//     on<FlagReviewEvent>(_onFlagReview);
//     on<MarkReviewAsHelpfulEvent>(_onMarkReviewAsHelpful);
//     on<DeleteReviewEvent>(_onDeleteReview);
//   }

//   Future<void> _onSubmitReview(
//     SubmitReviewEvent event,
//     Emitter<ReviewState> emit,
//   ) async {
//     emit(ReviewLoading());

//     final result = await submitReview(
//       userId: event.userId,
//       userName: event.userName,
//       restaurantId: event.restaurantId,
//       itemId: event.itemId,
//       rating: event.rating,
//       comment: event.comment,
//       imageUrls: event.imageUrls,
//       aspectRatings: event.aspectRatings,
//       tags: event.tags,
//     );

//     result.fold(
//       (failure) => emit(ReviewError(failure.message)),
//       (review) => emit(ReviewSubmitted(review)),
//     );
//   }

//   Future<void> _onGetRestaurantReviews(
//     GetRestaurantReviewsEvent event,
//     Emitter<ReviewState> emit,
//   ) async {
//     emit(ReviewLoading());

//     final result = await getRestaurantReviews(
//       GetRestaurantReviewsParams(
//         restaurantId: event.restaurantId,
//         limit: event.limit,
//       ),
//     );

//     result.fold(
//       (failure) => emit(ReviewError(failure.message)),
//       (reviews) => emit(ReviewLoaded(reviews)),
//     );
//   }

//   Future<void> _onGetItemReviews(
//     GetItemReviewsEvent event,
//     Emitter<ReviewState> emit,
//   ) async {
//     emit(ReviewLoading());

//     final result = await getItemReviews(
//       GetItemReviewsParams(itemId: event.itemId, limit: event.limit),
//     );

//     result.fold(
//       (failure) => emit(ReviewError(failure.message)),
//       (reviews) => emit(ReviewLoaded(reviews)),
//     );
//   }

//   Future<void> _onFlagReview(
//     FlagReviewEvent event,
//     Emitter<ReviewState> emit,
//   ) async {
//     final result = await flagReview(
//       reviewId: event.reviewId,
//       reason: event.reason,
//       reportedBy: event.reportedBy,
//     );

//     result.fold(
//       (failure) => emit(ReviewError(failure.message)),
//       (_) => emit(ReviewFlagged()),
//     );
//   }

//   Future<void> _onMarkReviewAsHelpful(
//     MarkReviewAsHelpfulEvent event,
//     Emitter<ReviewState> emit,
//   ) async {
//     // TODO: Implement mark review as helpful use case
//     emit(ReviewMarkedAsHelpful());
//   }

//   Future<void> _onDeleteReview(
//     DeleteReviewEvent event,
//     Emitter<ReviewState> emit,
//   ) async {
//     // TODO: Implement delete review use case
//     emit(ReviewDeleted());
//   }
// }
