from sklearn.calibration import LabelEncoder
from sklearn.discriminant_analysis import StandardScaler
from sklearn.model_selection import train_test_split
import tensorflow as tf
import numpy as np
import pandas as pd
import firebase_admin
from firebase_admin import credentials, firestore
import json
import pickle
import os
from datetime import datetime, timedelta
import logging

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class MakanMateRecommendationModel:
    def __init__(self, num_users=1000, num_items=500, embedding_dim=64):
        self.num_users = num_users
        self.num_items = num_items
        self.embedding_dim = embedding_dim
        self.user_feature_dim = 15
        self.item_feature_dim = 20
        
        self.model = None
        self.user_scaler = StandardScaler()
        self.item_scaler = StandardScaler()
        self.user_encoder = LabelEncoder()
        self.item_encoder = LabelEncoder()
        
        # Initialize Firebase
        self.init_firebase()
        
    def init_firebase(self):
        """Initialize Firebase Admin SDK"""
        try:
            if not firebase_admin._apps:
                # You need to download the service account key from Firebase Console
                cred = credentials.Certificate('path/to/serviceAccountKey.json')
                firebase_admin.initialize_app(cred)
            
            self.db = firestore.client()
            logger.info("Firebase initialized successfully")
        except Exception as e:
            logger.error(f"Error initializing Firebase: {e}")
            # Use dummy data for training if Firebase is not available
            self.db = None
    
    def fetch_training_data(self):
        """Fetch training data from Firestore"""
        logger.info("Fetching training data from Firestore...")
        
        if self.db is None:
            logger.warning("Firebase not available, using synthetic data")
            return self.generate_synthetic_data()
        
        try:
            # Get users
            users_ref = self.db.collection('users')
            users = list(users_ref.stream())
            
            # Get food items
            items_ref = self.db.collection('food_items')
            items = list(items_ref.stream())
            
            # Get interactions
            interactions_ref = self.db.collection('user_interactions')
            interactions = list(interactions_ref.stream())
            
            logger.info(f"Fetched {len(users)} users, {len(items)} items, {len(interactions)} interactions")
            
            return {
                'users': [doc.to_dict() for doc in users],
                'items': [doc.to_dict() for doc in items],
                'interactions': [doc.to_dict() for doc in interactions],
            }
        except Exception as e:
            logger.error(f"Error fetching data from Firestore: {e}")
            return self.generate_synthetic_data()
    
    def generate_synthetic_data(self):
        """Generate synthetic Malaysian food data for training"""
        logger.info("Generating synthetic Malaysian food data...")
        
        # Malaysian cuisines and food categories
        cuisines = ['malay', 'chinese', 'indian', 'western', 'thai']
        categories = ['rice', 'noodles', 'soup', 'grilled', 'fried', 'dessert', 'beverage']
        interactions_types = ['view', 'like', 'order', 'rate', 'bookmark']
        
        # Generate users
        users = []
        for i in range(self.num_users):
            user = {
                'id': f'user_{i}',
                'name': f'User {i}',
                'culturalBackground': np.random.choice(['malay', 'chinese', 'indian', 'mixed']),
                'spiceTolerance': np.random.uniform(0, 1),
                'dietaryRestrictions': np.random.choice([
                    ['halal'], ['vegetarian'], ['halal', 'vegetarian'], []
                ], p=[0.6, 0.1, 0.05, 0.25]),
                'cuisinePreferences': {
                    cuisine: np.random.uniform(0, 1) for cuisine in cuisines
                },
                'behaviorPatterns': {
                    'morning_activity': np.random.uniform(0, 1),
                    'afternoon_activity': np.random.uniform(0, 1),
                    'evening_activity': np.random.uniform(0, 1),
                    'weekend_activity': np.random.uniform(0, 1),
                }
            }
            users.append(user)
        
        # Generate food items
        items = []
        malaysian_foods = [
            ('Nasi Lemak', 'malay', ['rice', 'breakfast'], 0.6),
            ('Char Kway Teow', 'chinese', ['noodles', 'fried'], 0.4),
            ('Laksa', 'chinese', ['noodles', 'soup'], 0.8),
            ('Roti Canai', 'indian', ['bread', 'breakfast'], 0.3),
            ('Satay', 'malay', ['grilled', 'meat'], 0.5),
            ('Hainanese Chicken Rice', 'chinese', ['rice', 'chicken'], 0.2),
            ('Nasi Goreng', 'malay', ['rice', 'fried'], 0.7),
            ('Teh Tarik', 'malay', ['beverage', 'hot'], 0.1),
            ('Cendol', 'malay', ['dessert', 'cold'], 0.0),
            ('Wonton Noodles', 'chinese', ['noodles', 'soup'], 0.3),
        ]
        
        for i in range(self.num_items):
            if i < len(malaysian_foods):
                name, cuisine, cats, spice = malaysian_foods[i]
            else:
                name = f'Food Item {i}'
                cuisine = np.random.choice(cuisines)
                cats = np.random.choice(categories, size=np.random.randint(1, 4), replace=False).tolist()
                spice = np.random.uniform(0, 1)
            
            item = {
                'id': f'item_{i}',
                'name': name,
                'cuisineType': cuisine,
                'categories': cats,
                'price': np.random.uniform(5.0, 50.0),
                'spiceLevel': spice,
                'isHalal': np.random.choice([True, False], p=[0.7, 0.3]),
                'isVegetarian': np.random.choice([True, False], p=[0.2, 0.8]),
                'averageRating': np.random.uniform(3.0, 5.0),
                'totalRatings': np.random.randint(0, 1000),
                'totalOrders': np.random.randint(0, 500),
                'nutritionalInfo': {
                    'calories': np.random.uniform(200, 800),
                    'protein': np.random.uniform(5, 50),
                    'carbs': np.random.uniform(20, 100),
                    'fat': np.random.uniform(5, 40),
                }
            }
            items.append(item)
        
        # Generate interactions
        interactions = []
        for i in range(self.num_users * 20):  # Average 20 interactions per user
            interaction = {
                'userId': f'user_{np.random.randint(0, self.num_users)}',
                'itemId': f'item_{np.random.randint(0, self.num_items)}',
                'interactionType': np.random.choice(interactions_types),
                'rating': np.random.uniform(1, 5) if np.random.random() < 0.3 else None,
                'timestamp': datetime.now() - timedelta(days=np.random.randint(0, 90)),
            }
            interactions.append(interaction)
        
        return {
            'users': users,
            'items': items,
            'interactions': interactions,
        }
    
    def preprocess_data(self, raw_data):
        """Preprocess raw data for training"""
        logger.info("Preprocessing training data...")
        
        users = raw_data['users']
        items = raw_data['items']
        interactions = raw_data['interactions']
        
        # Create user and item mappings
        user_ids = [user['id'] for user in users]
        item_ids = [item['id'] for item in items]
        
        # Encode user and item IDs
        self.user_encoder.fit(user_ids)
        self.item_encoder.fit(item_ids)
        
        # Extract features
        user_features = []
        item_features = []
        
        # Process user features
        for user in users:
            features = self._extract_user_features(user)
            user_features.append(features)
        
        # Process item features
        for item in items:
            features = self._extract_item_features(item)
            item_features.append(features)
        
        # Scale features
        user_features_scaled = self.user_scaler.fit_transform(user_features)
        item_features_scaled = self.item_scaler.fit_transform(item_features)
        
        # Process interactions
        training_samples = []
        for interaction in interactions:
            try:
                user_idx = self.user_encoder.transform([interaction['userId']])[0]
                item_idx = self.item_encoder.transform([interaction['itemId']])[0]
                rating = self._calculate_rating(interaction)
                
                training_samples.append({
                    'user_idx': user_idx,
                    'item_idx': item_idx,
                    'user_features': user_features_scaled[user_idx],
                    'item_features': item_features_scaled[item_idx],
                    'rating': rating,
                })
            except ValueError:
                # Skip interactions with unknown users/items
                continue
        
        logger.info(f"Preprocessed {len(training_samples)} training samples")
        
        return {
            'training_samples': training_samples,
            'user_features': user_features_scaled,
            'item_features': item_features_scaled,
        }
    
    def _extract_user_features(self, user):
        """Extract numerical features from user profile"""
        features = []
        
        # Cuisine preferences (5 features)
        cuisines = ['malay', 'chinese', 'indian', 'western', 'thai']
        prefs = user.get('cuisinePreferences', {})
        for cuisine in cuisines:
            features.append(prefs.get(cuisine, 0.0))
        
        # Dietary restrictions (3 features)
        restrictions = user.get('dietaryRestrictions', [])
        features.append(1.0 if 'halal' in restrictions else 0.0)
        features.append(1.0 if 'vegetarian' in restrictions else 0.0)
        features.append(1.0 if 'vegan' in restrictions else 0.0)
        
        # Spice tolerance (1 feature)
        features.append(user.get('spiceTolerance', 0.5))
        
        # Cultural background (4 features - one-hot)
        culture = user.get('culturalBackground', 'mixed').lower()
        cultures = ['malay', 'chinese', 'indian', 'mixed']
        for c in cultures:
            features.append(1.0 if culture == c else 0.0)
        
        # Behavioral patterns (2 features)
        patterns = user.get('behaviorPatterns', {})
        features.append(patterns.get('morning_activity', 0.0))
        features.append(patterns.get('evening_activity', 0.0))
        
        return features
    
    def _extract_item_features(self, item):
        """Extract numerical features from food item"""
        features = []
        
        # Basic features (6 features)
        features.append(item.get('price', 0.0) / 100.0)  # Normalize price
        features.append(item.get('spiceLevel', 0.5))
        features.append(1.0 if item.get('isHalal', False) else 0.0)
        features.append(1.0 if item.get('isVegetarian', False) else 0.0)
        features.append(item.get('averageRating', 0.0) / 5.0)
        features.append(min(item.get('totalOrders', 0) / 100.0, 1.0))
        
        # Cuisine type (5 features - one-hot)
        cuisine = item.get('cuisineType', 'western').lower()
        cuisines = ['malay', 'chinese', 'indian', 'western', 'thai']
        for c in cuisines:
            features.append(1.0 if cuisine == c else 0.0)
        
        # Categories (4 features - binary indicators)
        categories = item.get('categories', [])
        common_cats = ['rice', 'noodles', 'soup', 'dessert']
        for cat in common_cats:
            has_cat = any(cat in c.lower() for c in categories)
            features.append(1.0 if has_cat else 0.0)
        
        return features
    
    def _calculate_rating(self, interaction):
        """Calculate rating from interaction"""
        if interaction.get('rating'):
            return interaction['rating']
        
        interaction_type = interaction.get('interactionType', '').lower()
        if interaction_type == 'order':
            return 5.0
        elif interaction_type == 'like':
            return 4.0
        elif interaction_type == 'bookmark':
            return 3.5
        elif interaction_type == 'view':
            return 2.0
        else:
            return 3.0
    
    def build_model(self):
        """Build the recommendation model"""
        logger.info("Building recommendation model...")
        
        # Input layers
        user_id_input = tf.keras.Input(shape=(), name='user_id', dtype='int32')
        item_id_input = tf.keras.Input(shape=(), name='item_id', dtype='int32')
        user_features_input = tf.keras.Input(shape=(self.user_feature_dim,), name='user_features')
        item_features_input = tf.keras.Input(shape=(self.item_feature_dim,), name='item_features')
        
        # Embedding layers
        user_embedding = tf.keras.layers.Embedding(
            self.num_users, self.embedding_dim,
            embeddings_regularizer=tf.keras.regularizers.l2(1e-6),
            name='user_embedding'
        )(user_id_input)
        user_embedding = tf.keras.layers.Flatten()(user_embedding)
        
        item_embedding = tf.keras.layers.Embedding(
            self.num_items, self.embedding_dim,
            embeddings_regularizer=tf.keras.regularizers.l2(1e-6),
            name='item_embedding'
        )(item_id_input)
        item_embedding = tf.keras.layers.Flatten()(item_embedding)
        
        # Feature processing layers
        user_features_dense = tf.keras.layers.Dense(
            32, activation='relu', name='user_features_dense'
        )(user_features_input)
        user_features_dense = tf.keras.layers.Dropout(0.3)(user_features_dense)
        user_features_dense = tf.keras.layers.BatchNormalization()(user_features_dense)
        
        item_features_dense = tf.keras.layers.Dense(
            32, activation='relu', name='item_features_dense'
        )(item_features_input)
        item_features_dense = tf.keras.layers.Dropout(0.3)(item_features_dense)
        item_features_dense = tf.keras.layers.BatchNormalization()(item_features_dense)
        
        # Combine embeddings and features
        user_combined = tf.keras.layers.concatenate([
            user_embedding, user_features_dense
        ], name='user_combined')
        
        item_combined = tf.keras.layers.concatenate([
            item_embedding, item_features_dense
        ], name='item_combined')
        
        # Deep interaction layers
        concat_layer = tf.keras.layers.concatenate([
            user_combined, item_combined
        ], name='concat_layer')
        
        # Hidden layers
        dense_1 = tf.keras.layers.Dense(128, activation='relu', name='dense_1')(concat_layer)
        dense_1 = tf.keras.layers.Dropout(0.4)(dense_1)
        dense_1 = tf.keras.layers.BatchNormalization()(dense_1)
        
        dense_2 = tf.keras.layers.Dense(64, activation='relu', name='dense_2')(dense_1)
        dense_2 = tf.keras.layers.Dropout(0.3)(dense_2)
        dense_2 = tf.keras.layers.BatchNormalization()(dense_2)
        
        dense_3 = tf.keras.layers.Dense(32, activation='relu', name='dense_3')(dense_2)
        dense_3 = tf.keras.layers.Dropout(0.2)(dense_3)
        
        # Output layer
        output = tf.keras.layers.Dense(1, activation='sigmoid', name='output')(dense_3)
        output = tf.keras.layers.Lambda(lambda x: x * 4 + 1, name='rating_scale')(output)
        
        # Create model
        self.model = tf.keras.Model(
            inputs=[user_id_input, item_id_input, user_features_input, item_features_input],
            outputs=output,
            name='MakanMateRecommendationModel'
        )
        
        # Compile model
        self.model.compile(
            optimizer=tf.keras.optimizers.Adam(learning_rate=0.001),
            loss='mse',
            metrics=['mae']
        )
        
        logger.info("Model built successfully")
        self.model.summary()
        
        return self.model
    
    def train_model(self, processed_data, epochs=50, batch_size=512, validation_split=0.2):
        """Train the recommendation model"""
        logger.info("Starting model training...")
        
        training_samples = processed_data['training_samples']
        
        # Prepare training data
        user_ids = np.array([sample['user_idx'] for sample in training_samples])
        item_ids = np.array([sample['item_idx'] for sample in training_samples])
        user_features = np.array([sample['user_features'] for sample in training_samples])
        item_features = np.array([sample['item_features'] for sample in training_samples])
        ratings = np.array([sample['rating'] for sample in training_samples])
        
        # Split data
        indices = np.arange(len(ratings))
        train_idx, val_idx = train_test_split(indices, test_size=validation_split, random_state=42)
        
        # Training data
        X_train = {
            'user_id': user_ids[train_idx],
            'item_id': item_ids[train_idx],
            'user_features': user_features[train_idx],
            'item_features': item_features[train_idx],
        }
        y_train = ratings[train_idx]
        
        # Validation data
        X_val = {
            'user_id': user_ids[val_idx],
            'item_id': item_ids[val_idx],
            'user_features': user_features[val_idx],
            'item_features': item_features[val_idx],
        }
        y_val = ratings[val_idx]
        
        # Callbacks
        callbacks = [
            tf.keras.callbacks.EarlyStopping(
                patience=10, restore_best_weights=True, monitor='val_loss'
            ),
            tf.keras.callbacks.ReduceLROnPlateau(
                factor=0.8, patience=5, monitor='val_loss'
            ),
            tf.keras.callbacks.ModelCheckpoint(
                'best_model.h5', save_best_only=True, monitor='val_loss'
            ),
        ]
        
        # Train model
        history = self.model.fit(
            X_train, y_train,
            validation_data=(X_val, y_val),
            epochs=epochs,
            batch_size=batch_size,
            callbacks=callbacks,
            verbose=1
        )
        
        logger.info("Model training completed")
        return history
    
    def convert_to_tflite(self, model_path='recommendation_model.tflite'):
        """Convert trained model to TensorFlow Lite"""
        logger.info("📱 Converting model to TensorFlow Lite...")
        
        if self.model is None:
            raise ValueError("Model must be trained before conversion")
        
        # Create representative dataset for quantization
        def representative_dataset():
            for i in range(100):
                user_id = np.array([np.random.randint(0, self.num_users)], dtype=np.int32)
                item_id = np.array([np.random.randint(0, self.num_items)], dtype=np.int32)
                user_features = np.random.random((1, self.user_feature_dim)).astype(np.float32)
                item_features = np.random.random((1, self.item_feature_dim)).astype(np.float32)
                
                yield [user_id, item_id, user_features, item_features]
        
        # Convert to TensorFlow Lite
        converter = tf.lite.TFLiteConverter.from_keras_model(self.model)
        
        # Optimization settings
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.representative_dataset = representative_dataset
        converter.target_spec.supported_ops = [
            tf.lite.OpsSet.TFLITE_BUILTINS,
            tf.lite.OpsSet.SELECT_TF_OPS
        ]
        converter.inference_input_type = tf.float32
        converter.inference_output_type = tf.float32
        
        # Convert
        tflite_model = converter.convert()
        
        # Save model
        with open(model_path, 'wb') as f:
            f.write(tflite_model)
        
        logger.info(f"Model converted to TensorFlow Lite: {model_path}")
        
        # Save preprocessing objects
        with open('user_scaler.pkl', 'wb') as f:
            pickle.dump(self.user_scaler, f)
        with open('item_scaler.pkl', 'wb') as f:
            pickle.dump(self.item_scaler, f)
        with open('user_encoder.pkl', 'wb') as f:
            pickle.dump(self.user_encoder, f)
        with open('item_encoder.pkl', 'wb') as f:
            pickle.dump(self.item_encoder, f)
        
        logger.info("Preprocessing objects saved")
        
        return tflite_model
    
    def evaluate_model(self, processed_data):
        """Evaluate model performance"""
        logger.info("Evaluating model performance...")
        
        training_samples = processed_data['training_samples']
        
        # Prepare test data
        user_ids = np.array([sample['user_idx'] for sample in training_samples])
        item_ids = np.array([sample['item_idx'] for sample in training_samples])
        user_features = np.array([sample['user_features'] for sample in training_samples])
        item_features = np.array([sample['item_features'] for sample in training_samples])
        ratings = np.array([sample['rating'] for sample in training_samples])
        
        # Make predictions
        predictions = self.model.predict({
            'user_id': user_ids,
            'item_id': item_ids,
            'user_features': user_features,
            'item_features': item_features,
        })
        
        # Calculate metrics
        mse = np.mean((ratings - predictions.flatten()) ** 2)
        mae = np.mean(np.abs(ratings - predictions.flatten()))
        rmse = np.sqrt(mse)
        
        logger.info(f"Model Performance:")
        logger.info(f"  RMSE: {rmse:.4f}")
        logger.info(f"  MAE: {mae:.4f}")
        logger.info(f"  MSE: {mse:.4f}")
        
        return {
            'rmse': rmse,
            'mae': mae,
            'mse': mse,
        }

def main():
    """Main training function"""
    logger.info("Starting MakanMate AI Model Training Pipeline")
    
    # Create model instance
    model = MakanMateRecommendationModel()
    
    # Fetch and preprocess data
    raw_data = model.fetch_training_data()
    processed_data = model.preprocess_data(raw_data)
    
    # Build and train model
    model.build_model()
    history = model.train_model(processed_data)
    
    # Evaluate model
    metrics = model.evaluate_model(processed_data)
    
    # Convert to TensorFlow Lite
    tflite_model = model.convert_to_tflite()
    
    logger.info("Training pipeline completed successfully!")
    logger.info(f"Model saved as 'recommendation_model.tflite'")
    logger.info(f"Final RMSE: {metrics['rmse']:.4f}")
    
    return model, history, metrics

if __name__ == "__main__":
    main()