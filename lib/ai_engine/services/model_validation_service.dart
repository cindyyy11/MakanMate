import 'dart:io';
import 'package:logger/logger.dart';
import 'package:makan_mate/ai_engine/ai_engine_base.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Service responsible for validating TensorFlow Lite models
/// 
/// Provides comprehensive testing and validation of model:
/// - Model file existence and integrity
/// - Input/output tensor shapes and types
/// - Inference execution with sample data
/// - Performance benchmarking
class ModelValidationService {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 80,
    ),
  );

  /// Validate model file exists and is accessible
  Future<ModelValidationResult> validateModelFile(String modelPath) async {
    try {
      _logger.i('Validating model file: $modelPath');

      // Check if file exists (for asset paths, this will be checked during load)
      if (modelPath.startsWith('assets/')) {
        _logger.i('Model is an asset, will be validated during loading');
        return ModelValidationResult(
          isValid: true,
          message: 'Asset model path validated',
          fileSize: null,
        );
      }

      final file = File(modelPath);
      if (!await file.exists()) {
        return ModelValidationResult(
          isValid: false,
          message: 'Model file does not exist at path: $modelPath',
          fileSize: null,
        );
      }

      final fileSize = await file.length();
      if (fileSize == 0) {
        return ModelValidationResult(
          isValid: false,
          message: 'Model file is empty',
          fileSize: fileSize,
        );
      }

      _logger.i('Model file validated: ${fileSize / 1024 / 1024} MB');
      return ModelValidationResult(
        isValid: true,
        message: 'Model file is valid',
        fileSize: fileSize,
      );
    } catch (e, stackTrace) {
      _logger.e('Error validating model file: $e\n$stackTrace');
      return ModelValidationResult(
        isValid: false,
        message: 'Error validating model file: $e',
        fileSize: null,
      );
    }
  }

  /// Validate model structure (tensors, shapes, types)
  Future<ModelStructureValidation> validateModelStructure(
    Interpreter interpreter,
  ) async {
    try {
      _logger.i('Validating model structure...');

      final inputTensors = interpreter.getInputTensors();
      final outputTensors = interpreter.getOutputTensors();

      if (inputTensors.isEmpty) {
        return ModelStructureValidation(
          isValid: false,
          message: 'Model has no input tensors',
          inputShapes: [],
          outputShapes: [],
        );
      }

      if (outputTensors.isEmpty) {
        return ModelStructureValidation(
          isValid: false,
          message: 'Model has no output tensors',
          inputShapes: [],
          outputShapes: [],
        );
      }

      final inputShapes = inputTensors.map((t) => t.shape).toList();
      final outputShapes = outputTensors.map((t) => t.shape).toList();
      final inputTypes = inputTensors.map((t) => t.type).toList();
      final outputTypes = outputTensors.map((t) => t.type).toList();

      _logger.i('Input tensors: ${inputTensors.length}');
      for (int i = 0; i < inputTensors.length; i++) {
        _logger.i('  Input $i: shape=${inputShapes[i]}, type=${inputTypes[i]}');
      }

      _logger.i('Output tensors: ${outputTensors.length}');
      for (int i = 0; i < outputTensors.length; i++) {
        _logger.i('  Output $i: shape=${outputShapes[i]}, type=${outputTypes[i]}');
      }

      return ModelStructureValidation(
        isValid: true,
        message: 'Model structure is valid',
        inputShapes: inputShapes,
        outputShapes: outputShapes,
        inputTypes: inputTypes,
        outputTypes: outputTypes,
      );
    } catch (e, stackTrace) {
      _logger.e('Error validating model structure: $e\n$stackTrace');
      return ModelStructureValidation(
        isValid: false,
        message: 'Error validating model structure: $e',
        inputShapes: [],
        outputShapes: [],
      );
    }
  }

  /// Test model inference with sample data
  Future<InferenceTestResult> testInference(
    Interpreter interpreter,
    List<List<double>> sampleInputs,
  ) async {
    try {
      _logger.i('Testing model inference with ${sampleInputs.length} samples...');

      final inputTensors = interpreter.getInputTensors();
      if (inputTensors.isEmpty) {
        return InferenceTestResult(
          isValid: false,
          message: 'No input tensors found',
          inferenceTimes: [],
          outputs: [],
        );
      }

      final outputTensors = interpreter.getOutputTensors();
      if (outputTensors.isEmpty) {
        return InferenceTestResult(
          isValid: false,
          message: 'No output tensors found',
          inferenceTimes: [],
          outputs: [],
        );
      }

      final inputShape = inputTensors[0].shape;
      final outputShape = outputTensors[0].shape;

      List<Duration> inferenceTimes = [];
      List<List<List<double>>> outputs = [];

      for (var sampleInput in sampleInputs) {
        // Validate input shape
        if (inputShape.length == 2) {
          final expectedSize = inputShape[0] * inputShape[1];
          if (sampleInput.length != expectedSize) {
            _logger.w(
              'Input size mismatch: expected $expectedSize, got ${sampleInput.length}',
            );
            continue;
          }
        }

        // Prepare input tensor
        final inputTensor = [sampleInput];

        // Prepare output tensor
        final output = List.filled(
          outputShape[0],
          List.filled(outputShape[1], 0.0),
        );

        // Run inference and measure time
        final stopwatch = Stopwatch()..start();
        interpreter.run(inputTensor, output);
        stopwatch.stop();

        inferenceTimes.add(stopwatch.elapsed);
        outputs.add(output);

        _logger.d(
          'Inference completed in ${stopwatch.elapsedMicroseconds}μs, '
          'output: ${output[0][0]}',
        );
      }

      if (inferenceTimes.isEmpty) {
        return InferenceTestResult(
          isValid: false,
          message: 'No successful inferences',
          inferenceTimes: [],
          outputs: [],
        );
      }

      final avgTime = inferenceTimes
              .map((d) => d.inMicroseconds)
              .reduce((a, b) => a + b) /
          inferenceTimes.length;

      _logger.i(
        'Inference test completed: ${inferenceTimes.length} successful, '
        'avg time: ${avgTime.toStringAsFixed(2)}μs',
      );

      return InferenceTestResult(
        isValid: true,
        message: 'Inference test passed',
        inferenceTimes: inferenceTimes,
        outputs: outputs,
        averageTimeMicroseconds: avgTime,
      );
    } catch (e, stackTrace) {
      _logger.e('Error testing inference: $e\n$stackTrace');
      return InferenceTestResult(
        isValid: false,
        message: 'Error testing inference: $e',
        inferenceTimes: [],
        outputs: [],
      );
    }
  }

  /// Comprehensive model validation
  Future<CompleteValidationResult> validateModel(
    AIEngineBase engine,
    String modelPath, {
    List<List<double>>? testInputs,
  }) async {
    _logger.i('Starting comprehensive model validation...');

    final fileValidation = await validateModelFile(modelPath);
    if (!fileValidation.isValid) {
      return CompleteValidationResult(
        isValid: false,
        message: 'Model file validation failed: ${fileValidation.message}',
        fileValidation: fileValidation,
        structureValidation: null,
        inferenceTest: null,
      );
    }

    if (!engine.isModelLoaded) {
      return CompleteValidationResult(
        isValid: false,
        message: 'Model is not loaded in engine',
        fileValidation: fileValidation,
        structureValidation: null,
        inferenceTest: null,
      );
    }

    final interpreter = engine.interpreter;
    if (interpreter == null) {
      return CompleteValidationResult(
        isValid: false,
        message: 'Interpreter is null',
        fileValidation: fileValidation,
        structureValidation: null,
        inferenceTest: null,
      );
    }

    final structureValidation = await validateModelStructure(interpreter);
    if (!structureValidation.isValid) {
      return CompleteValidationResult(
        isValid: false,
        message: 'Model structure validation failed: ${structureValidation.message}',
        fileValidation: fileValidation,
        structureValidation: structureValidation,
        inferenceTest: null,
      );
    }

    InferenceTestResult? inferenceTest;
    if (testInputs != null && testInputs.isNotEmpty) {
      inferenceTest = await testInference(interpreter, testInputs);
      if (!inferenceTest.isValid) {
        return CompleteValidationResult(
          isValid: false,
          message: 'Inference test failed: ${inferenceTest.message}',
          fileValidation: fileValidation,
          structureValidation: structureValidation,
          inferenceTest: inferenceTest,
        );
      }
    }

    _logger.i('Model validation completed successfully');
    return CompleteValidationResult(
      isValid: true,
      message: 'Model validation passed all tests',
      fileValidation: fileValidation,
      structureValidation: structureValidation,
      inferenceTest: inferenceTest,
    );
  }
}

/// Result of model file validation
class ModelValidationResult {
  final bool isValid;
  final String message;
  final int? fileSize;

  ModelValidationResult({
    required this.isValid,
    required this.message,
    this.fileSize,
  });
}

/// Result of model structure validation
class ModelStructureValidation {
  final bool isValid;
  final String message;
  final List<List<int>> inputShapes;
  final List<List<int>> outputShapes;
  final List<TensorType>? inputTypes;
  final List<TensorType>? outputTypes;

  ModelStructureValidation({
    required this.isValid,
    required this.message,
    required this.inputShapes,
    required this.outputShapes,
    this.inputTypes,
    this.outputTypes,
  });
}

/// Result of inference testing
class InferenceTestResult {
  final bool isValid;
  final String message;
  final List<Duration> inferenceTimes;
  final List<List<List<double>>> outputs;
  final double? averageTimeMicroseconds;

  InferenceTestResult({
    required this.isValid,
    required this.message,
    required this.inferenceTimes,
    required this.outputs,
    this.averageTimeMicroseconds,
  });
}

/// Complete validation result
class CompleteValidationResult {
  final bool isValid;
  final String message;
  final ModelValidationResult fileValidation;
  final ModelStructureValidation? structureValidation;
  final InferenceTestResult? inferenceTest;

  CompleteValidationResult({
    required this.isValid,
    required this.message,
    required this.fileValidation,
    this.structureValidation,
    this.inferenceTest,
  });
}

