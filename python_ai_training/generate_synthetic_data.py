"""
MakanMate Synthetic Data Generator
===================================
Generates realistic Malaysian food recommendation training data

This script creates:
- 50 diverse user profiles with Malaysian food preferences
- 15 authentic Malaysian food items
- 1000+ realistic user-food interactions

Usage:
    python generate_synthetic_data.py

Requirements:
    - Firebase project with Firestore enabled
    - firebase-credentials.json file in the same directory
"""

import firebase_admin
from firebase_admin import credentials, firestore
import random
from datetime import datetime, timedelta

# ============================================
# CONFIGURATION - EDIT THESE IF NEEDED
# ============================================
FIREBASE_CREDENTIALS_FILE = 'firebase-credentials.json'
NUM_USERS = 50
NUM_INTERACTIONS_PER_USER = 20  # Will create ~1000 total interactions

# ============================================
# MALAYSIAN FOOD DATABASE
# ============================================
MALAYSIAN_FOODS = [
    {
        "name": "Nasi Lemak",
        "cuisine": "malay",
        "spice": 2,
        "price": 1,
        "halal": True,
        "tags": ["breakfast", "rice", "coconut", "local"]
    },
    {
        "name": "Char Kway Teow",
        "cuisine": "chinese",
        "spice": 3,
        "price": 2,
        "halal": False,
        "tags": ["noodles", "wok-fried", "lunch"]
    },
    {
        "name": "Roti Canai",
        "cuisine": "indian",
        "spice": 2,
        "price": 1,
        "halal": True,
        "tags": ["breakfast", "bread", "flatbread"]
    },
    {
        "name": "Laksa",
        "cuisine": "peranakan",
        "spice": 4,
        "price": 2,
        "halal": True,
        "tags": ["noodles", "soup", "spicy", "local"]
    },
    {
        "name": "Satay",
        "cuisine": "malay",
        "spice": 2,
        "price": 2,
        "halal": True,
        "tags": ["grilled", "skewers", "dinner", "snack"]
    },
    {
        "name": "Rendang",
        "cuisine": "malay",
        "spice": 3,
        "price": 3,
        "halal": True,
        "tags": ["curry", "beef", "coconut", "dinner"]
    },
    {
        "name": "Dim Sum",
        "cuisine": "chinese",
        "spice": 1,
        "price": 2,
        "halal": False,
        "tags": ["breakfast", "dumplings", "steamed"]
    },
    {
        "name": "Rojak",
        "cuisine": "local",
        "spice": 2,
        "price": 1,
        "halal": True,
        "tags": ["fruit", "salad", "sweet", "snack"]
    },
    {
        "name": "Mee Goreng",
        "cuisine": "malay",
        "spice": 3,
        "price": 1,
        "halal": True,
        "tags": ["noodles", "fried", "lunch", "dinner"]
    },
    {
        "name": "Chicken Rice",
        "cuisine": "chinese",
        "spice": 1,
        "price": 2,
        "halal": True,
        "tags": ["rice", "chicken", "lunch", "dinner"]
    },
    {
        "name": "Cendol",
        "cuisine": "local",
        "spice": 0,
        "price": 1,
        "halal": True,
        "tags": ["dessert", "coconut", "sweet"]
    },
    {
        "name": "Nasi Goreng",
        "cuisine": "malay",
        "spice": 2,
        "price": 1,
        "halal": True,
        "tags": ["rice", "fried", "lunch", "dinner"]
    },
    {
        "name": "Popiah",
        "cuisine": "chinese",
        "spice": 1,
        "price": 1,
        "halal": True,
        "tags": ["spring roll", "vegetables", "snack"]
    },
    {
        "name": "Asam Pedas",
        "cuisine": "malay",
        "spice": 4,
        "price": 2,
        "halal": True,
        "tags": ["fish", "sour", "spicy", "dinner"]
    },
    {
        "name": "Hokkien Mee",
        "cuisine": "chinese",
        "spice": 2,
        "price": 2,
        "halal": False,
        "tags": ["noodles", "dark soy", "lunch", "dinner"]
    },
]

# ============================================
# INITIALIZATION
# ============================================
def initialize_firebase():
    """Initialize Firebase Admin SDK"""
    try:
        if not firebase_admin._apps:
            cred = credentials.Certificate(FIREBASE_CREDENTIALS_FILE)
            firebase_admin.initialize_app(cred)
        
        db = firestore.client()
        print("Firebase initialized successfully")
        return db
    except FileNotFoundError:
        print(f"ERROR: '{FIREBASE_CREDENTIALS_FILE}' not found!")
        print("\nHow to fix:")
        print("1. Go to Firebase Console → Project Settings → Service Accounts")
        print("2. Click 'Generate New Private Key'")
        print(f"3. Save the file as '{FIREBASE_CREDENTIALS_FILE}' in this directory")
        exit(1)
    except Exception as e:
        print(f"ERROR initializing Firebase: {e}")
        exit(1)

# ============================================
# DATA GENERATORS
# ============================================
def generate_users(db, num_users=NUM_USERS):
    """Generate diverse user profiles with Malaysian preferences"""
    print(f"\n Generating {num_users} users...")
    
    user_profiles = []
    cuisine_options = ["malay", "chinese", "indian", "local", "peranakan", "western"]
    locations = ["Kuala Lumpur", "Penang", "Johor Bahru", "Melaka", "Ipoh", "Kota Kinabalu"]
    
    for i in range(num_users):
        user_id = f"user_{i+1:03d}"
        
        # Create diverse preferences
        cuisine_prefs = random.sample(cuisine_options, k=random.randint(2, 4))
        spice_tolerance = random.randint(1, 5)
        price_sensitivity = random.randint(1, 3)
        
        # Determine dietary restrictions
        dietary_restrictions = []
        if random.random() < 0.7:  # 70% require halal (Malaysia is Muslim-majority)
            dietary_restrictions.append("halal")
        if random.random() < 0.15:  # 15% vegetarian
            dietary_restrictions.append("vegetarian")
        if random.random() < 0.10:  # 10% no seafood
            dietary_restrictions.append("no-seafood")
        
        user_data = {
            "userId": user_id,
            "createdAt": datetime.now() - timedelta(days=random.randint(1, 180)),
            "preferences": {
                "cuisineTypes": cuisine_prefs,
                "spiceLevel": spice_tolerance,
                "priceRange": [1, price_sensitivity],
                "dietaryRestrictions": dietary_restrictions,
            },
            "profile": {
                "age": random.randint(18, 55),
                "location": random.choice(locations),
                "explorationLevel": round(random.uniform(0.3, 0.9), 2),
                "activityScore": round(random.uniform(0.1, 1.0), 2),
            },
            "stats": {
                "totalReviews": 0,
                "averageRating": 0.0,
                "locationsVisited": random.randint(1, 10),
            }
        }
        
        # Save to Firestore
        db.collection('users').document(user_id).set(user_data)
        user_profiles.append(user_data)
        
        # Progress indicator
        if (i + 1) % 10 == 0:
            print(f"  Created {i + 1}/{num_users} users...")
    
    print(f" {num_users} users created")
    return user_profiles

def generate_foods(db, foods_data=MALAYSIAN_FOODS):
    """Add Malaysian food items to Firestore"""
    print(f"\n Generating {len(foods_data)} food items...")
    
    created_foods = []
    
    for idx, food in enumerate(foods_data):
        food_id = f"food_{idx+1:03d}"
        
        food_data = {
            "foodId": food_id,
            "name": food["name"],
            "cuisineType": food["cuisine"],
            "spiceLevel": food["spice"],
            "priceRange": food["price"],
            "isHalal": food["halal"],
            "tags": food["tags"],
            "rating": round(random.uniform(3.5, 5.0), 1),
            "popularity": random.randint(50, 500),
            "reviewCount": random.randint(10, 200),
            "createdAt": datetime.now() - timedelta(days=random.randint(30, 365)),
        }
        
        db.collection('foods').document(food_id).set(food_data)
        created_foods.append((food_id, food_data))
        
        print(f"  ✓ {food['name']} ({food['cuisine']})")
    
    print(f" {len(foods_data)} foods created")
    return created_foods

def generate_interactions(db, users, foods, interactions_per_user=NUM_INTERACTIONS_PER_USER):
    """Generate realistic user-food interactions based on preferences"""
    print(f"\n Generating user interactions...")
    
    total_interactions = 0
    
    for user_idx, user in enumerate(users):
        user_id = user["userId"]
        spice_pref = user["preferences"]["spiceLevel"]
        cuisine_prefs = user["preferences"]["cuisineTypes"]
        dietary_restrictions = user["preferences"]["dietaryRestrictions"]
        exploration_level = user["profile"]["explorationLevel"]
        
        # Generate interactions for this user
        num_interactions = random.randint(
            int(interactions_per_user * 0.5), 
            int(interactions_per_user * 1.5)
        )
        
        for _ in range(num_interactions):
            # Select food based on preferences (70%) or random exploration (30%)
            if random.random() < (1 - exploration_level):
                # Match preferences
                suitable_foods = [
                    (food_id, food_data) for food_id, food_data in foods
                    if food_data["cuisineType"] in cuisine_prefs
                    and abs(food_data["spiceLevel"] - spice_pref) <= 2
                    and (
                        not dietary_restrictions 
                        or ("halal" in dietary_restrictions and food_data["isHalal"])
                        or "halal" not in dietary_restrictions
                    )
                ]
                
                if not suitable_foods:
                    suitable_foods = foods
                
                food_id, selected_food = random.choice(suitable_foods)
            else:
                # Random exploration
                food_id, selected_food = random.choice(foods)
            
            # Generate rating based on match quality
            spice_match = 1 - (abs(selected_food["spiceLevel"] - spice_pref) / 5.0)
            cuisine_match = 1.0 if selected_food["cuisineType"] in cuisine_prefs else 0.5
            
            # Base rating influenced by preferences
            base_rating = (spice_match * 0.4 + cuisine_match * 0.6) * 4.5 + 0.5
            
            # Add randomness
            rating = max(1.0, min(5.0, base_rating + random.uniform(-1.0, 1.0)))
            rating = round(rating, 1)
            
            # Create interaction
            timestamp = datetime.now() - timedelta(days=random.randint(1, 90))
            interaction_id = f"{user_id}_{food_id}_{int(timestamp.timestamp())}"
            
            interaction_data = {
                "userId": user_id,
                "foodId": food_id,
                "rating": rating,
                "timestamp": timestamp,
                "action": random.choice(["rated", "rated", "rated", "viewed", "bookmarked"])
            }
            
            # Save to Firestore
            db.collection('interactions').document(interaction_id).set(interaction_data)
            total_interactions += 1
        
        # Progress indicator
        if (user_idx + 1) % 10 == 0:
            print(f"  Processed {user_idx + 1}/{len(users)} users...")
    
    print(f" {total_interactions} interactions created")
    return total_interactions

# ============================================
# MAIN EXECUTION
# ============================================
def main():
    """Main data generation pipeline"""
    print("=" * 60)
    print("     MakanMate Synthetic Data Generator")
    print("=" * 60)
    
    # Initialize Firebase
    db = initialize_firebase()
    
    # Generate data
    print("\n Starting data generation...\n")
    
    users = generate_users(db, num_users=NUM_USERS)
    foods = generate_foods(db, foods_data=MALAYSIAN_FOODS)
    interactions = generate_interactions(db, users, foods, interactions_per_user=NUM_INTERACTIONS_PER_USER)
    
    # Summary
    print("\n" + "=" * 60)
    print("Data generation complete!")
    print("=" * 60)
    print(f"  Users: {len(users)}")
    print(f"  Foods: {len(foods)}")
    print(f"  Interactions: {interactions}")
    print("=" * 60)
    
    print("\nData Distribution:")
    print(f"  • Average interactions per user: {interactions / len(users):.1f}")
    print(f"  • Average interactions per food: {interactions / len(foods):.1f}")
    
    print("\nNext Steps:")
    print("  1. Verify data in Firebase Console (Firestore Database)")
    print("  2. Run training script:")
    print("     python train_recommendation_model.py")
    
    print("\n Happy Training!")

if __name__ == "__main__":
    main()