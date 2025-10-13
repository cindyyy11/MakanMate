import subprocess
import sys
import os
from pathlib import Path

def setup_environment():
    """Set up the Python environment"""
    print("Setting up Python environment...")
    
    # Check if virtual environment exists
    venv_path = Path("venv")
    if not venv_path.exists():
        print("Creating virtual environment...")
        subprocess.run([sys.executable, "-m", "venv", "venv"])
    
    # Install requirements
    pip_path = "venv/Scripts/pip" if os.name == "nt" else "venv/bin/pip"
    subprocess.run([pip_path, "install", "-r", "requirements.txt"])
    
    print("Environment setup complete")

def run_training():
    """Run the training script"""
    print("Starting model training...")
    
    python_path = "venv/Scripts/python" if os.name == "nt" else "venv/bin/python"
    result = subprocess.run([python_path, "train_recommendation_model.py"])
    
    if result.returncode == 0:
        print("Training completed successfully")
    else:
        print("Training failed")
        sys.exit(1)

def copy_models():
    """Copy trained models to Flutter assets"""
    import shutil
    
    print("Copying models to Flutter assets...")
    
    # Create assets directory if it doesn't exist
    assets_dir = Path("../assets/ml_models")
    assets_dir.mkdir(parents=True, exist_ok=True)
    
    # Copy model files
    if Path("recommendation_model.tflite").exists():
        shutil.copy("recommendation_model.tflite", assets_dir)
        print("Model copied to assets")
    else:
        print("Model file not found")

if __name__ == "__main__":
    setup_environment()
    run_training()
    copy_models()
    print("Training pipeline completed!")