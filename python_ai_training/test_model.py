"""
Test the TensorFlow Lite model to ensure it works correctly
"""

import tensorflow as tf
import numpy as np
import os

def _index_by_name(input_details, target_name_startswith):
    """Find input index by matching the beginning of the tensor name."""
    for d in input_details:
        name = d["name"]
        if name.startswith(target_name_startswith):
            return d["index"]
    raise KeyError(f"Input with name starting '{target_name_startswith}' not found. "
                   f"Available: {[d['name'] for d in input_details]}")

def test_tflite_model(model_path='recommendation_model.tflite'):
    """Test the TFLite model with sample inputs"""

    print("=" * 60)
    print("Testing MakanMate Recommendation Model")
    print("=" * 60)

    # 1) Load model
    print("\n1. Loading model...")
    try:
        interpreter = tf.lite.Interpreter(model_path=model_path)
        interpreter.allocate_tensors()
        print(" Model loaded successfully")
    except Exception as e:
        print(f" Failed to load model: {e}")
        return False

    # 2) Inspect I/O
    print("\n2. Checking model structure...")
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    print(f"   Number of inputs: {len(input_details)}")
    print(f"   Number of outputs: {len(output_details)}")

    print("\n   Input Details:")
    for i, detail in enumerate(input_details):
        print(f"     Input {i}:")
        print(f"       Name:  {detail['name']}")
        print(f"       Shape: {detail['shape']}")
        print(f"       Type:  {detail['dtype']}")

    print("\n   Output Details:")
    for i, detail in enumerate(output_details):
        print(f"     Output {i}:")
        print(f"       Name:  {detail['name']}")
        print(f"       Shape: {detail['shape']}")
        print(f"       Type:  {detail['dtype']}")

    # 3) Resolve input indices by NAME (not position)
    #   serving_default_user_features:0
    #   serving_default_item_features:0
    #   serving_default_user_id:0
    #   serving_default_item_id:0
    try:
        idx_user_features = _index_by_name(input_details, "serving_default_user_features")
        idx_item_features = _index_by_name(input_details, "serving_default_item_features")
        idx_user_id       = _index_by_name(input_details, "serving_default_user_id")
        idx_item_id       = _index_by_name(input_details, "serving_default_item_id")
    except KeyError as e:
        print(f"\n Could not resolve input indices: {e}")
        return False

    # 4) Create sample inputs with CORRECT shapes/dtypes
    print("\n3. Creating sample inputs...")

    # Expected:
    # - user_id:        int32 [1]
    # - item_id:        int32 [1]
    # - user_features:  float32 [1, 15]
    # - item_features:  float32 [1, 15]
    sample_user_id = np.array([1], dtype=np.int32)
    sample_item_id = np.array([3], dtype=np.int32)
    sample_user_features = np.random.random((1, 15)).astype(np.float32)
    sample_item_features = np.random.random((1, 15)).astype(np.float32)  # <-- 15, not 20

    print("   ✓ Sample user ID:", sample_user_id, sample_user_id.dtype)
    print("   ✓ Sample item ID:", sample_item_id, sample_item_id.dtype)
    print("   ✓ User features shape:", sample_user_features.shape, sample_user_features.dtype)
    print("   ✓ Item features shape:", sample_item_features.shape, sample_item_features.dtype)

    # 5) Run inference (feed tensors by resolved indices)
    print("\n4. Running inference...")
    try:
        interpreter.set_tensor(idx_user_features, sample_user_features)  # float32 [1,15]
        interpreter.set_tensor(idx_item_features, sample_item_features)  # float32 [1,15]
        interpreter.set_tensor(idx_user_id,       sample_user_id)        # int32   [1]
        interpreter.set_tensor(idx_item_id,       sample_item_id)        # int32   [1]

        interpreter.invoke()

        output = interpreter.get_tensor(output_details[0]['index'])
        print("    Inference successful!")
        print(f"   Predicted rating: {float(output[0][0]):.2f} / 5.0")

        if 1.0 <= output[0][0] <= 5.0:
            print("    Output is in valid range (1-5)")
        else:
            print(f"     Warning: Output {output[0][0]} is outside expected range")

    except Exception as e:
        print(f"    Inference failed: {e}")
        return False

    # 6) Multiple test cases
    print("\n5. Running multiple test cases...")
    test_results = []
    for i in range(10):
        user_id = np.array([np.random.randint(0, 50)], dtype=np.int32)
        item_id = np.array([np.random.randint(0, 50)], dtype=np.int32)
        user_feat = np.random.random((1, 15)).astype(np.float32)
        item_feat = np.random.random((1, 15)).astype(np.float32)

        interpreter.set_tensor(idx_user_features, user_feat)
        interpreter.set_tensor(idx_item_features, item_feat)
        interpreter.set_tensor(idx_user_id,       user_id)
        interpreter.set_tensor(idx_item_id,       item_id)

        interpreter.invoke()
        out = interpreter.get_tensor(output_details[0]['index'])
        test_results.append(float(out[0][0]))
        print(f"   Test {i+1}: User {user_id[0]}, Item {item_id[0]} → Rating: {out[0][0]:.2f}")

    # 7) Stats + size
    print(f"\n6. Test Statistics:")
    print(f"   Average prediction: {np.mean(test_results):.2f}")
    print(f"   Min prediction:     {np.min(test_results):.2f}")
    print(f"   Max prediction:     {np.max(test_results):.2f}")
    print(f"   Std deviation:      {np.std(test_results):.2f}")

    model_size = os.path.getsize(model_path) / (1024 * 1024)
    print(f"\n7. Model Info:")
    print(f"   File size: {model_size:.2f} MB")
    print("    Model size is optimized for mobile" if model_size < 5.0
          else "     Model size is large, consider optimization")

    print("\n" + "=" * 60)
    print(" MODEL VERIFICATION COMPLETE")
    return True

if __name__ == "__main__":
    ok = test_tflite_model('recommendation_model.tflite')
    print("\n SUCCESS!" if ok else "\n Model verification failed. Please check the errors above.")
