import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/featured/screen/profile_page.dart';

class PageTest2 extends StatefulWidget {
  final String test_2;
  const PageTest2({super.key, required this.test_2});

  @override
  State<PageTest2> createState() => _PageTest2State();
}

class _PageTest2State extends State<PageTest2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('id_document')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SizedBox.shrink();
              }
              return Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: (snapshot.data! as dynamic).docs.length,
                    itemBuilder: (context, index) {
                      return widget.test_2.toString() ==
                              (snapshot.data! as dynamic).docs[index]
                                  ['id_number']
                          ? Container(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              child: ProfilePage(
                                  uid: (snapshot.data! as dynamic).docs[index]
                                      ['uid']),
                            )
                          : SizedBox.shrink();
                    }),
              );
            }),
      ),
    );
  }
}
