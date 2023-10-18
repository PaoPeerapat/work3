import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class PhotoAlbum {
  final int userId;
  final int id;
  final String title;

  PhotoAlbum({
    required this.userId,
    required this.id,
    required this.title,
  });

  factory PhotoAlbum.fromJson(Map<String, dynamic> json) {
    return PhotoAlbum(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _dio = Dio(BaseOptions(responseType: ResponseType.plain));
  List<PhotoAlbum>? _albumList;
  String? _error;

  void getPhotoAlbums() async {
    try {
      setState(() {
        _error = null;
      });

      final response = await _dio.get('https://jsonplaceholder.typicode.com/albums');
      debugPrint(response.data.toString());

      List list = jsonDecode(response.data.toString());
      Set<int> uniqueUserIds = Set();
      setState(() {
        _albumList = list.map((item) {
          final album = PhotoAlbum.fromJson(item);
          uniqueUserIds.add(album.userId);
          return album;
        }).toList();
      });

      debugPrint('Number of unique user IDs: ${uniqueUserIds.length}');
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      debugPrint('Error: ${e.toString()}');
    }
  }

  @override
  void initState() {
    super.initState();
    getPhotoAlbums();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Albums'),
        backgroundColor: Colors.blue, // Set app bar background color
      ),
      body: _buildBody(),
      backgroundColor: Colors.grey[200], // Set background color
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return _buildErrorWidget();
    } else if (_albumList == null) {
      return _buildLoadingWidget();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Number of unique user IDs: ${_getUniqueUserIdsCount()}',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green), // Set text color
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _albumList!.length,
              itemBuilder: (context, index) {
                var album = _albumList![index];
                return Card(
                  color: Colors.white, // Set card background color
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(
                        album.title,
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), // Set text color
                      ),
                      subtitle: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.pink[200], // Set lighter pink background color
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              'Album ID: ${album.id}',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.lightBlueAccent, // Set light blue background color
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              'User ID: ${album.userId}',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }
  }

  Widget _buildErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _error!,
          style: TextStyle(color: Colors.red),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            getPhotoAlbums();
          },
          child: const Text('RETRY'),
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  int _getUniqueUserIdsCount() {
    return _albumList?.map((album) => album.userId).toSet().length ?? 0;
  }
}
