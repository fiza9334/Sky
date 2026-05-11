import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = "";

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() => _searchQuery = query.trim());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1B3022)),
        title: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Search users...",
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = "");
              },
            ),
          ),
        ),
      ),
      body: _searchQuery.isEmpty
          ? const Center(child: Text("Type a username to search", style: TextStyle(color: Colors.grey)))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('username', isGreaterThanOrEqualTo: _searchQuery)
                  .where('username', isLessThanOrEqualTo: '$_searchQuery\uf8ff')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF6B8E23)));
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No users found"));

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: data['profilePic'] != null && data['profilePic'].toString().isNotEmpty 
                            ? CachedNetworkImageProvider(data['profilePic']) : null,
                        child: data['profilePic'] == null ? const Icon(Icons.person) : null,
                      ),
                      title: Text(data['username'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                      onTap: () {
                        // TODO: Navigate to User Profile
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}