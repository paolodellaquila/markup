import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/scalapay/order_response.dart';
import 'package:flutter_app/app/networking/scalapay/scalapay_api.dart';

class ScalapayPage extends StatefulWidget {
  static const String route = '/order';

  @override
  _ScalapayPageState createState() => _ScalapayPageState();
}

class _ScalapayPageState extends State<ScalapayPage> {
  ScalapayOrderResponse? order;
  bool showToken = false;
  final _api = ScalapayApi();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
    // return Scaffold(
    //   backgroundColor: Color(0xff232336),
    //   body: SingleChildScrollView(
    //     child: Column(
    //       children: <Widget>[
    //         Container(
    //           height: MediaQuery.of(context).size.height * 0.1,
    //         ),
    //         Text(
    //           "Consumer details".toUpperCase(),
    //           style: TextStyle(color: Colors.white, fontSize: 20),
    //         ),
    //         Container(
    //           height: 20,
    //         ),
    //         Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             DisplayDetails(header: "Name", content: order.consumer.givenNames + " " + order.consumer.surname),
    //             Container(
    //               height: 4,
    //             ),
    //             DisplayDetails(header: "Contact Number", content: order.consumer.phoneNumber),
    //             Container(
    //               height: 4,
    //             ),
    //             DisplayDetails(header: "Email", content: order.consumer.email),
    //             Container(
    //               height: 20,
    //             ),
    //             Text("Shipping and billing details".toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 20)),
    //             Container(
    //               height: 20,
    //             ),
    //             DisplayDetails(header: "Address", content: order.billing.line1),
    //             Container(
    //               height: 4,
    //             ),
    //             DisplayDetails(header: "Suburb", content: order.billing.suburb),
    //             Container(
    //               height: 4,
    //             ),
    //             DisplayDetails(header: "Post Code", content: order.billing.postcode),
    //             Container(
    //               height: 4,
    //             ),
    //             DisplayDetails(header: "Country Code", content: order.billing.countryCode),
    //             DisplayDetails(header: "Total amount", content: order.totalAmount.amount + " " + order.totalAmount.currency),
    //             DisplayDetails(header: "Tax amount", content: order.taxAmount.amount + " " + order.taxAmount.currency),
    //             DisplayDetails(header: "Shipping amount", content: order.shippingAmount.amount + " " + order.shippingAmount.currency),
    //           ],
    //         ),
    //         Container(
    //           height: 20,
    //         ),
    //         Text(
    //           "Items ordered".toUpperCase(),
    //           style: TextStyle(color: Colors.white, fontSize: 20),
    //         ),
    //         Container(
    //           height: 20,
    //         ),
    //         Padding(
    //           padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
    //           child: Row(
    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             children: [
    //               Text("Name", style: TextStyle(color: Colors.white)),
    //               Text("Brand", style: TextStyle(color: Colors.white)),
    //               Text("Quantity", style: TextStyle(color: Colors.white)),
    //               Text("Price", style: TextStyle(color: Colors.white)),
    //             ],
    //           ),
    //         ),
    //         ListView.builder(
    //           shrinkWrap: true,
    //           itemCount: order.items.length,
    //           itemBuilder: (context, index) {
    //             final item = order.items[index];
    //             return Padding(
    //               padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
    //               child: Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [
    //                   Text(item.name, style: TextStyle(color: Colors.white)),
    //                   Text(item.brand, style: TextStyle(color: Colors.white)),
    //                   Text(item.quantity.toString(), style: TextStyle(color: Colors.white)),
    //                   Text(
    //                     item.price.amount + " " + item.price.currency,
    //                     style: TextStyle(color: Colors.white),
    //                   ),
    //                 ],
    //               ),
    //             );
    //           },
    //         ),
    //         Container(
    //           height: 20,
    //         ),
    //         Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [],
    //         ),
    //         Padding(
    //           padding: const EdgeInsets.fromLTRB(16.0, 0, 16, 0),
    //           child: ButtonWidget(
    //             content: showToken ? "CLICK ME TO HIDE TOKEN" : "CLICK ME TO SHOW TOKEN",
    //             backGroundColor: Colors.white,
    //             textColor: Colors.black,
    //             onPressed: () {
    //               setState(() {
    //                 showToken = !showToken;
    //               });
    //             },
    //           ),
    //         ),
    //         showToken
    //             ? Container(
    //                 child: FutureBuilder<OrderResponse>(
    //                   future: API().orders(),
    //                   builder: (context, snapshot) {
    //                     if (snapshot.hasData) {
    //                       return Padding(
    //                         padding: const EdgeInsets.all(32),
    //                         child: Column(children: [
    //                           showToken
    //                               ? Column(
    //                                   children: [
    //                                     Text(
    //                                       'Your token code is \'${snapshot.data.token}\'',
    //                                       style: TextStyle(color: Colors.white),
    //                                     ),
    //                                     GestureDetector(
    //                                       onTap: () async {
    //                                         launch(snapshot.data.checkoutUrl);
    //                                       },
    //                                       child: Text(
    //                                         snapshot.data.checkoutUrl,
    //                                         style: TextStyle(fontSize: 16, color: Colors.white, decoration: TextDecoration.underline),
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 )
    //                               : Container()
    //                         ]),
    //                       );
    //                     } else if (snapshot.hasError) {
    //                       return Center(child: Text("${snapshot.error}"));
    //                     }
    //                     return CircularProgressIndicator();
    //                   },
    //                 ),
    //               )
    //             : Container(),
    //         Padding(
    //           padding: const EdgeInsets.fromLTRB(16.0, 0, 16, 0),
    //           child: ButtonWidget(
    //             content: "BACK",
    //             backGroundColor: Colors.white,
    //             textColor: Colors.black,
    //             onPressed: () {
    //               Navigator.pushReplacementNamed(context, MyHomePage.route);
    //             },
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
