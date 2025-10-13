import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  // Sample data for testing
  final List<Map<String, dynamic>> _foodCategories = [
    {
      'name': 'Popular',
      'icon': Icons.local_fire_department,
      'color': Colors.orange,
    },
    {'name': 'Halal', 'icon': Icons.mosque, 'color': Colors.green},
    {'name': 'Vegetarian', 'icon': Icons.eco, 'color': Colors.lightGreen},
    {'name': 'Nearby', 'icon': Icons.location_on, 'color': Colors.blue},
  ];

  final List<Map<String, dynamic>> _recommendedFood = [
    {
      'name': 'Nasi Lemak',
      'restaurant': 'Village Park Restaurant',
      'rating': 4.8,
      'price': 'RM 8.50',
      'image': 'https://via.placeholder.com/150/FF6B6B/FFFFFF?text=Nasi+Lemak',
      'tags': ['Halal', 'Local', 'Spicy'],
    },
    {
      'name': 'Char Kway Teow',
      'restaurant': 'Penang Street Food',
      'rating': 4.6,
      'price': 'RM 12.00',
      'image':
          'https://via.placeholder.com/150/4ECDC4/FFFFFF?text=Char+Kway+Teow',
      'tags': ['Local', 'Spicy', 'Popular'],
    },
    {
      'name': 'Laksa',
      'restaurant': 'Authentic Malaysian',
      'rating': 4.7,
      'price': 'RM 10.50',
      'image': 'https://via.placeholder.com/150/45B7D1/FFFFFF?text=Laksa',
      'tags': ['Halal', 'Soup', 'Spicy'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Icon(Icons.restaurant_menu, color: Colors.orange, size: 28),
          SizedBox(width: 8),
          Text(
            'MakanMate',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: Colors.black54),
          onPressed: () {
            // TODO: Navigate to notifications
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Notifications feature coming soon!')),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.person_outline, color: Colors.black54),
          onPressed: () {
            // TODO: Navigate to profile
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Profile feature coming soon!')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          SizedBox(height: 20),
          _buildSearchBar(),
          SizedBox(height: 24),
          _buildCategoriesSection(),
          SizedBox(height: 24),
          _buildRecommendationsSection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, Foodie! 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Discover amazing local food around you',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.restaurant, color: Colors.white, size: 50),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for food, restaurants...',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          suffixIcon: IconButton(
            icon: Icon(Icons.mic, color: Colors.orange),
            onPressed: () {
              // TODO: Implement voice search
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Voice search coming soon!')),
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onSubmitted: (value) {
          // TODO: Implement search functionality
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Search for: $value')));
        },
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _foodCategories.length,
            itemBuilder: (context, index) {
              final category = _foodCategories[index];
              return Container(
                width: 80,
                margin: EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${category['name']} category selected'),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: category['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          category['icon'],
                          color: category['color'],
                          size: 28,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        category['name'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recommended for You',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('See all recommendations')),
                );
              },
              child: Text('See All'),
            ),
          ],
        ),
        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _recommendedFood.length,
          itemBuilder: (context, index) {
            final food = _recommendedFood[index];
            return _buildFoodCard(food);
          },
        ),
      ],
    );
  }

  Widget _buildFoodCard(Map<String, dynamic> food) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            // Food Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  food['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.image, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 12),
            // Food Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food['name'],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    food['restaurant'],
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text(
                        food['rating'].toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Spacer(),
                      Text(
                        food['price'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: (food['tags'] as List<String>).take(2).map((tag) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            // Action Buttons
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.favorite_border, color: Colors.grey),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added ${food['name']} to favorites!'),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.add_shopping_cart, color: Colors.orange),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${food['name']} added to cart!')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });

        // Handle navigation
        switch (index) {
          case 0:
            // Already on home
            break;
          case 1:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Explore feature coming soon!')),
            );
            break;
          case 2:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('AR Hunt feature coming soon!')),
            );
            break;
          case 3:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Profile feature coming soon!')),
            );
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'AR Hunt'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
