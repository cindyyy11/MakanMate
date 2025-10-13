import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class ModelManager {
  static final ModelManager _instance = ModelManager._internal();
  factory ModelManager() => _instance;
  ModelManager._internal();

  final Logger _logger = Logger();
  static const String MODEL_VERSION_KEY = 'model_version';
  static const String LAST_UPDATE_KEY = 'last_model_update';

  Future<String> getModelPath() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final modelDir = Directory('${directory.path}/ml_models');
      
      if (!modelDir.existsSync()) {
        modelDir.createSync(recursive: true);
      }
      
      final modelFile = File('${modelDir.path}/recommendation_model.tflite');
      
      // Check if we need to download/update the model
      if (!modelFile.existsSync() || await _shouldUpdateModel()) {
        await _downloadLatestModel(modelFile);
      }
      
      // Fallback to bundled model if download fails
      if (!modelFile.existsSync()) {
        _logger.w('Using bundled model as fallback');
        return 'assets/ml_models/recommendation_model.tflite';
      }
      
      return modelFile.path;
    } catch (e) {
      _logger.e('Error getting model path: $e');
      return 'assets/ml_models/recommendation_model.tflite';
    }
  }

  Future<bool> _shouldUpdateModel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdate = prefs.getString(LAST_UPDATE_KEY);
      
      if (lastUpdate == null) return true;
      
      final lastUpdateTime = DateTime.parse(lastUpdate);
      final daysSinceUpdate = DateTime.now().difference(lastUpdateTime).inDays;
      
      // Update model if it's older than 7 days
      return daysSinceUpdate >= 7;
    } catch (e) {
      _logger.e('Error checking model update: $e');
      return false;
    }
  }

  Future<void> _downloadLatestModel(File localFile) async {
    try {
      _logger.i('Downloading latest AI model...');
      
      final ref = FirebaseStorage.instance
          .ref()
          .child('ml_models/recommendation_model.tflite');
      
      await ref.writeToFile(localFile);
      
      // Update timestamp
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(LAST_UPDATE_KEY, DateTime.now().toIso8601String());
      
      _logger.i('Latest model downloaded successfully');
    } catch (e) {
      _logger.w('Could not download latest model: $e');
    }
  }

  Future<void> clearModelCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final modelDir = Directory('${directory.path}/ml_models');
      
      if (modelDir.existsSync()) {
        modelDir.deleteSync(recursive: true);
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(LAST_UPDATE_KEY);
      await prefs.remove(MODEL_VERSION_KEY);
      
      _logger.i('Model cache cleared');
    } catch (e) {
      _logger.e('Error clearing model cache: $e');
    }
  }
}