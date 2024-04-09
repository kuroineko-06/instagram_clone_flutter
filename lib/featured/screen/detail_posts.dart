import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/featured/widgets/post_card.dart';

class DetailPage extends StatefulWidget {
  final String name;
  final String uid;
  final String postId; // Add postId parameter
  const DetailPage(
      {Key? key, required this.uid, required this.name, required this.postId})
      : super(key: key); // Fix constructor syntax

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(widget.name.toUpperCase(),
                  style: TextStyle(fontSize: 14, color: Colors.white54)),
              Text("Posts", style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where(
              'uid',
              isEqualTo: widget.uid,
            )
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToPost(widget.postId);
          });

          return ListView.builder(
            controller: _scrollController,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) => PostCard(
              snap: snapshot.data!.docs[index].data(),
            ),
          );
        },
      ),
    );
  }

  void _scrollToPost(String postId) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: widget.uid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var index = 0;
      for (var i = 0; i < querySnapshot.docs.length; i++) {
        if (querySnapshot.docs[i]['postId'] == postId) {
          index = i;
          break;
        }
      }

      _scrollController.animateTo(
        index * 720, // Adjust the scroll position based on your item height
        duration: Duration(milliseconds: 2),
        curve: Curves.easeIn,
      );
      print({querySnapshot});
      print(index);
      print('success');
    } else
      print('error');
  }
}
