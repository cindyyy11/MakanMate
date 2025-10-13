import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:logger/logger.dart';

abstract class AIEngineBase {
  final Logger _logger = Logger();
  
  Interpreter? _interpreter;
  List<List<int>>? _inputShapes;
  List<List<int>>? _outputShapes;
  List<TensorType>? _inputTypes;
  List<TensorType>? _outputTypes;
  
  bool get isModelLoaded => _interpreter != null;
  
  Future<void> loadModel(String modelPath) async {
    try {
      _logger.i('Loading AI model: $modelPath');
      
      final options = InterpreterOptions()
        ..threads = 4
        ..useNnApiForAndroid = true;
        
      _interpreter = await Interpreter.fromAsset(modelPath, options: options);
      
      // Get tensor information
      _inputShapes = [];
      _outputShapes = [];
      _inputTypes = [];
      _outputTypes = [];
      
      for (int i = 0; i < _interpreter!.getInputTensors().length; i++) {
        _inputShapes!.add(_interpreter!.getInputTensor(i).shape);
        _inputTypes!.add(_interpreter!.getInputTensor(i).type);
      }
      
      for (int i = 0; i < _interpreter!.getOutputTensors().length; i++) {
        _outputShapes!.add(_interpreter!.getOutputTensor(i).shape);
        _outputTypes!.add(_interpreter!.getOutputTensor(i).type);
      }
      
      _logger.i('Model loaded successfully');
      _logger.i('Input shapes: $_inputShapes');
      _logger.i('Output shapes: $_outputShapes');
      
    } catch (e) {
      _logger.e('Error loading model: $e');
      throw Exception('Failed to load AI model: $e');
    }
  }
  
  // Abstract method to be implemented by subclasses
  List<Object> runInference(List<Object> inputs);
  
  // Utility methods
  List<List<double>> reshape2D(List<double> input, List<int> shape) {
    if (shape.length != 2) {
      throw ArgumentError('Shape must have 2 dimensions');
    }
    
    int rows = shape[0];
    int cols = shape[1];
    
    if (input.length != rows * cols) {
      throw ArgumentError('Input length does not match shape');
    }
    
    List<List<double>> result = [];
    for (int i = 0; i < rows; i++) {
      List<double> row = [];
      for (int j = 0; j < cols; j++) {
        row.add(input[i * cols + j]);
      }
      result.add(row);
    }
    
    return result;
  }
  
  List<double> normalizeFeatures(List<double> features) {
    if (features.isEmpty) return features;
    
    // Min-max normalization
    double min = features.reduce((a, b) => a < b ? a : b);
    double max = features.reduce((a, b) => a > b ? a : b);
    
    if (max == min) return features.map((e) => 0.5).toList();
    
    return features.map((x) => (x - min) / (max - min)).toList();
  }
  
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _logger.i('AI model disposed');
  }
  
  // Getters for subclasses
  Interpreter? get interpreter => _interpreter;
  List<List<int>>? get inputShapes => _inputShapes;
  List<List<int>>? get outputShapes => _outputShapes;
  List<TensorType>? get inputTypes => _inputTypes;
  List<TensorType>? get outputTypes => _outputTypes;
  Logger get logger => _logger;
}