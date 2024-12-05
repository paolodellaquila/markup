import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_app/resources/widgets/cart_quantity_widget.dart';

class TabBarCartIcon extends StatefulWidget {
  TabBarCartIcon({super.key, required this.icon});

  final Widget icon;

  @override
  createState() => _TabBarCartIconState();
}

class _TabBarCartIconState extends State<TabBarCartIcon> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: badges.Badge(
        badgeContent: CartQuantity(color: Colors.white),
        badgeAnimation: badges.BadgeAnimation.scale(animationDuration: Duration(milliseconds: 100)),
        badgeStyle: badges.BadgeStyle(
          shape: badges.BadgeShape.circle,
          badgeColor: Colors.redAccent,
          elevation: 0,
        ),
        showBadge: true,
        child: widget.icon,
      ),
    );
  }
}
