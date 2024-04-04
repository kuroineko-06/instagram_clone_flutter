import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/featured/screen/group_chats.dart';
import 'package:instagram_clone/featured/screen/mrz_nfc.dart';
import 'package:instagram_clone/featured/screen/page_test_2.dart';
import 'package:instagram_clone/featured/screen/profile_page.dart';
import 'package:instagram_clone/featured/widgets/post_card.dart';
import 'package:instagram_clone/featured/widgets/profile_card.dart';
import 'package:instagram_clone/featured/widgets/reels_items.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final String uid;
  const HomePage({super.key, required this.uid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _result = '';
  var id = '';
  var uid_id = '';
  var userData = {};

  Future<Null> _pullRefresh() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      FirebaseFirestore.instance
          .collection('posts')
          .orderBy("datePublished", descending: true)
          .get();
      FirebaseFirestore.instance.collection('users').get();
    });
    return null;
  }

  Future<void> data() async {
    NFCTag? _tag;
    var test = '';
    try {
      NFCTag tag = await FlutterNfcKit.poll(timeout: Duration(seconds: 10));
      setState(() {
        _tag = tag;
      });
      var ndefRecords = await FlutterNfcKit.readNDEFRecords(cached: false);
      var ndefString = '';
      for (int i = 0; i < ndefRecords.length; i++) {
        ndefString += '${i + 1}: ${ndefRecords[0]}\n';
      }
      setState(() {
        _result = ndefString;
        test = _result.substring(108, 120).toString();
      });
    } catch (e) {
      setState(() {
        _result = 'error: $e';
      });
    }
    print('test_results: ${test}');
    if (test.toString() != "") {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PageTest2(test_2: test.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          centerTitle: false,
          title: SvgPicture.asset('assets/images/Instagram_logo.svg',
              height: 40, width: 112, color: getSvgColor(context)),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                  onPressed: () async {
                    await data();
                  },
                  icon: Icon(Icons.scanner)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MRZ_NFC(
                              uid: FirebaseAuth.instance.currentUser!.uid,
                            )));
                  },
                  icon: Icon(Icons.nfc)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Container(
                                height: 100,
                                width: 300,
                                child: GroupsChat(
                                    uid: FirebaseAuth
                                        .instance.currentUser!.uid))));
                  },
                  icon: Icon(Icons.message_outlined)),
            )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _pullRefresh,
          child: SingleChildScrollView(
            child: Container(
              color: mobileBackgroundColor,
              constraints: BoxConstraints(maxHeight: double.infinity),
              child: Column(
                children: [
                  Container(
                    height: 110,
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return SizedBox.shrink();
                        }

                        return Row(
                          children: [
                            Container(
                                height: 120,
                                constraints:
                                    BoxConstraints(maxWidth: double.infinity),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    physics: AlwaysScrollableScrollPhysics(),
                                    itemCount:
                                        (snapshot.data! as dynamic).docs.length,
                                    itemBuilder: (context, index) =>
                                        FirebaseAuth.instance.currentUser!
                                                    .uid ==
                                                (snapshot.data! as dynamic)
                                                    .docs[index]['uid']
                                            ? Container(
                                                width: 100,
                                                height: 110,
                                                child: ReelsItems(
                                                    name: (snapshot.data!
                                                            as dynamic)
                                                        .docs[index]['name'],
                                                    photoURL: (snapshot.data!
                                                            as dynamic)
                                                        .docs[index]['photoURL']
                                                        .toString(),
                                                    uid: (snapshot.data!
                                                            as dynamic)
                                                        .docs[index]['uid']),
                                              )
                                            : Container(height: 0))),
                            Container(
                                height: 120,
                                constraints: BoxConstraints(maxWidth: 311),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    physics: AlwaysScrollableScrollPhysics(),
                                    itemCount:
                                        (snapshot.data! as dynamic).docs.length,
                                    itemBuilder: (context, index) =>
                                        FirebaseAuth.instance.currentUser!
                                                    .uid !=
                                                (snapshot.data! as dynamic)
                                                    .docs[index]['uid']
                                            ? Container(
                                                width: 100,
                                                height: 110,
                                                child: ReelsItems2(
                                                    photoURL: (snapshot.data!
                                                            as dynamic)
                                                        .docs[index]['photoURL']
                                                        .toString(),
                                                    uid: (snapshot.data!
                                                            as dynamic)
                                                        .docs[index]['uid']),
                                              )
                                            : Container(height: 0)))
                          ],
                        );
                      },
                    ),
                  ),
                  Container(
                    height: 10,
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      border: Border(
                          bottom:
                              BorderSide(width: 0.2, color: Colors.blueGrey)),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Suggested for You",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 305,
                    decoration: BoxDecoration(
                        border: Border.symmetric(
                            horizontal:
                                BorderSide(width: 0.2, color: Colors.grey))),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return SizedBox.shrink();
                        }
                        return Container(
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: (snapshot.data! as dynamic).docs.length,
                            itemBuilder: (context, index) =>
                                FirebaseAuth.instance.currentUser!.uid ==
                                        (snapshot.data! as dynamic).docs[index]
                                            ['uid']
                                    ? SizedBox.shrink()
                                    : Container(
                                        height: 300,
                                        width: 202,
                                        child: ProfileCard(
                                            uid: (snapshot.data! as dynamic)
                                                .docs[index]['uid']),
                                      ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    color: mobileBackgroundColor,
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .orderBy("datePublished", descending: true)
                          .snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (!snapshot.hasData) {
                          return SizedBox.shrink();
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            color: mobileBackgroundColor,
                          );
                        }
                        return Container(
                          color: mobileBackgroundColor,
                          constraints:
                              BoxConstraints(maxHeight: double.infinity),
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) => Container(
                              color: mobileBackgroundColor,
                              child: PostCard(
                                snap: snapshot.data!.docs[index].data(),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
