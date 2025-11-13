import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages TensorFlow Lite model lifecycle
/// 
/// Responsibilities:
/// - Model versioning and updates
/// - Downloading models from Firebase Storage
/// - Caching and storage management
/// - Model integrity validation
class ModelManagerService {
  static final ModelManagerService _instance = ModelManagerService._internal();
  factory ModelManagerService() => _instance;
  ModelManagerService._internal();

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
    ),
  );

  static const String _modelVersionKey = 'recommendation_model_version';
  static const String _lastUpdateKey = 'recommendation_model_last_update';
  static const String _modelPathKey = 'recommendation_model_path';
  static const String _modelFileName = 'recommendation_model.tflite';
  static const String _firebaseModelPath = 'ml_models/recommendation_model.tflite';

  /// Get model path (downloaded or bundled)
  Future<ModelPathResult> getModelPath({
    bool forceDownload = false,
    Duration cacheDuration = const Duration(days: 7),
  }) async {
    try {
      _logger.i('Getting model path...');

      // Try to get cached model first (unless force download)
      if (!forceDownload) {
        final cachedPath = await _getCachedModelPath();
        if (cachedPath != null && await _isModelValid(cachedPath)) {
          _logger.i('Using cached model: $cachedPath');
          return ModelPathResult(
            path: cachedPath,
            source: ModelSource.cache,
            version: await _getCachedVersion(),
          );
        }
      }

      // Try to download from Firebase
      try {
        final downloadedPath = await _downloadModelFromFirebase();
        if (downloadedPath != null && await _isModelValid(downloadedPath)) {
          _logger.i('Using downloaded model: $downloadedPath');
          await _updateCacheMetadata(downloadedPath);
          return ModelPathResult(
            path: downloadedPath,
            source: ModelSource.firebase,
            version: await _getCachedVersion(),
          );
        }
      } catch (e) {
        _logger.w('Failed to download model from Firebase: $e');
      }

      // Fallback to bundled asset
      _logger.i('Falling back to bundled model');
      return ModelPathResult(
        path: 'assets/ml_models/$_modelFileName',
        source: ModelSource.asset,
        version: null,
      );
    } catch (e, stackTrace) {
      _logger.e('Error getting model path: $e\n$stackTrace');
      return ModelPathResult(
        path: 'assets/ml_models/$_modelFileName',
        source: ModelSource.asset,
        version: null,
      );
    }
  }

  /// Download model from Firebase Storage
  Future<String?> _downloadModelFromFirebase() async {
    try {
      _logger.i('Downloading model from Firebase Storage...');

      final appDir = await getApplicationDocumentsDirectory();
      final modelDir = Directory('${appDir.path}/ml_models');

      if (!modelDir.existsSync()) {
        modelDir.createSync(recursive: true);
      }

      final localFile = File('${modelDir.path}/$_modelFileName');

      final ref = FirebaseStorage.instance.ref(_firebaseModelPath);

      // Get metadata to check version
      try {
        final metadata = await ref.getMetadata();
        final remoteVersion = metadata.customMetadata?['version'] ?? 
            metadata.updated.toString();
        
        _logger.i('Remote model version: $remoteVersion');
        
        // Check if we need to update
        final cachedVersion = await _getCachedVersion();
        if (cachedVersion == remoteVersion && localFile.existsSync()) {
          _logger.i('Model is up to date, skipping download');
          return localFile.path;
        }
      } catch (e) {
        _logger.w('Could not get model metadata: $e');
      }

      // Download the model
      await ref.writeToFile(localFile);

      // Get metadata after download
      try {
        final metadata = await ref.getMetadata();
        final version = metadata.customMetadata?['version'] ?? 
            metadata.updated.toString();
        await _setCachedVersion(version);
      } catch (e) {
        _logger.w('Could not get metadata after download: $e');
      }

      await _setLastUpdateTime(DateTime.now());
      await _setCachedModelPath(localFile.path);

      _logger.i('Model downloaded successfully to ${localFile.path}');
      return localFile.path;
    } on FirebaseException catch (e) {
      _logger.w('Firebase error downloading model: ${e.code} - ${e.message}');
      return null;
    } catch (e, stackTrace) {
      _logger.e('Error downloading model: $e\n$stackTrace');
      return null;
    }
  }

  /// Check if model file is valid
  Future<bool> _isModelValid(String path) async {
    try {
      if (path.startsWith('assets/')) {
        return true; // Asset validation happens during load
      }

      final file = File(path);
      if (!await file.exists()) {
        return false;
      }

      final fileSize = await file.length();
      return fileSize > 0;
    } catch (e) {
      _logger.w('Error validating model: $e');
      return false;
    }
  }

  /// Get cached model path
  Future<String?> _getCachedModelPath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final path = prefs.getString(_modelPathKey);
      
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          return path;
        }
      }
      
      return null;
    } catch (e) {
      _logger.w('Error getting cached model path: $e');
      return null;
    }
  }

  /// Set cached model path
  Future<void> _setCachedModelPath(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_modelPathKey, path);
    } catch (e) {
      _logger.w('Error setting cached model path: $e');
    }
  }

  /// Get cached model version
  Future<String?> _getCachedVersion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_modelVersionKey);
    } catch (e) {
      _logger.w('Error getting cached version: $e');
      return null;
    }
  }

  /// Set cached model version
  Future<void> _setCachedVersion(String version) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_modelVersionKey, version);
    } catch (e) {
      _logger.w('Error setting cached version: $e');
    }
  }

  /// Get last update time
  Future<DateTime?> _getLastUpdateTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeString = prefs.getString(_lastUpdateKey);
      if (timeString != null) {
        return DateTime.parse(timeString);
      }
      return null;
    } catch (e) {
      _logger.w('Error getting last update time: $e');
      return null;
    }
  }

  /// Set last update time
  Future<void> _setLastUpdateTime(DateTime time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastUpdateKey, time.toIso8601String());
    } catch (e) {
      _logger.w('Error setting last update time: $e');
    }
  }

  /// Update cache metadata
  Future<void> _updateCacheMetadata(String path) async {
    await _setCachedModelPath(path);
    await _setLastUpdateTime(DateTime.now());
  }

  /// Clear model cache
  Future<void> clearCache() async {
    try {
      _logger.i('Clearing model cache...');

      final appDir = await getApplicationDocumentsDirectory();
      final modelDir = Directory('${appDir.path}/ml_models');

      if (modelDir.existsSync()) {
        modelDir.deleteSync(recursive: true);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_modelVersionKey);
      await prefs.remove(_lastUpdateKey);
      await prefs.remove(_modelPathKey);

      _logger.i('Model cache cleared');
    } catch (e, stackTrace) {
      _logger.e('Error clearing cache: $e\n$stackTrace');
    }
  }

  /// Get model info
  Future<ModelInfo> getModelInfo() async {
    try {
      final path = await _getCachedModelPath();
      final version = await _getCachedVersion();
      final lastUpdate = await _getLastUpdateTime();

      int? fileSize;
      if (path != null && !path.startsWith('assets/')) {
        final file = File(path);
        if (await file.exists()) {
          fileSize = await file.length();
        }
      }

      return ModelInfo(
        path: path ?? 'assets/ml_models/$_modelFileName',
        version: version,
        lastUpdate: lastUpdate,
        fileSize: fileSize,
        source: path != null 
            ? (path.startsWith('assets/') ? ModelSource.asset : ModelSource.cache)
            : ModelSource.asset,
      );
    } catch (e) {
      _logger.w('Error getting model info: $e');
      return ModelInfo(
        path: 'assets/ml_models/$_modelFileName',
        version: null,
        lastUpdate: null,
        fileSize: null,
        source: ModelSource.asset,
      );
    }
  }
}

/// Model path result
class ModelPathResult {
  final String path;
  final ModelSource source;
  final String? version;

  ModelPathResult({
    required this.path,
    required this.source,
    this.version,
  });
}

/// Model source
enum ModelSource {
  asset,
  cache,
  firebase,
}

/// Model information
class ModelInfo {
  final String path;
  final String? version;
  final DateTime? lastUpdate;
  final int? fileSize;
  final ModelSource source;

  ModelInfo({
    required this.path,
    this.version,
    this.lastUpdate,
    this.fileSize,
    required this.source,
  });
}






