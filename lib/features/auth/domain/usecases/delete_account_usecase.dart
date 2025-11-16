import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/core/errors/failures.dart';

class DeleteAccountUseCase {
  Future<Either<Failure, void>> call() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return const Right(null);

      final uid = user.uid;

      // Delete vendor Firestore data
      await FirebaseFirestore.instance.collection('vendors').doc(uid).delete();

      // Delete Auth user
      await user.delete();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure("Delete failed: $e"));
    }
  }
}
