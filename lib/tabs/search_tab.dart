
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kazipurprojects/constants.dart';
import 'package:kazipurprojects/services/firebase_services.dart';
import 'package:kazipurprojects/widgets/custom_input.dart';
import 'package:kazipurprojects/widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  FirebaseServices _firebaseServices = FirebaseServices();
  String _searchString = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          if (_searchString.isEmpty)
            Center(
              child: Container(
                child: Text(
                  "Search Results",
                  style: Constants.regularDarkText,
                ),
              ),
            )
          else
            FutureBuilder<QuerySnapshot>(
              future: _firebaseServices.productsRef
                  .orderBy("search_string")
                  .startAt([_searchString]).endAt(
                      ["$_searchString\uf8ff"]).get(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Scaffold(
                    body: Center(
                      child: Text("Error: ${snapshot.error}"),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.done) {
                  // Display the data inside a list view
                  return ListView(
                    padding: EdgeInsets.only(
                      top: 128.0,
                      bottom: 12.0,
                    ),
                    children: snapshot.data.docs.map((document) {
                      return ProductCard(
                        title: document.data()['name'],
                        imageUrl: document.data()['images'][0],
                        price: "\৳${document.data()['price']}",
                        productId: document.id,
                      );
                    }).toList(),
                  );
                }

                // Loading State
                return Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
          Padding(
            padding: const EdgeInsets.only(
              top: 45.0,
            ),
            child: CustomInput(
              hintText: "Search here...",
              onSubmitted: (value) {
                setState(() {
                  _searchString = value.toLowerCase();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
