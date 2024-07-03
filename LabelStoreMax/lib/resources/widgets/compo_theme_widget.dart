//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/resources/pages/categories_page.dart';
import 'package:flutter_app/resources/pages/settings_page.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

import '/app/models/bottom_nav_item.dart';
import '/bootstrap/app_helper.dart';
import '/resources/pages/cart_page.dart';
import '/resources/pages/wishlist_page_widget.dart';
import '/resources/widgets/app_loader_widget.dart';
import '/resources/widgets/compo_home_widget.dart';

class CompoThemeWidget extends StatefulWidget {
  CompoThemeWidget({super.key, required this.wooSignalApp});
  final WooSignalApp? wooSignalApp;

  @override
  CompoThemeWidgetState createState() => CompoThemeWidgetState();
}

class CompoThemeWidgetState extends State<CompoThemeWidget> with TickerProviderStateMixin {
  Widget? activeWidget;

  int _currentIndex = 0;
  List<BottomNavItem> allNavWidgets = [];

  late AnimationController _hideBottomBarAnimationController;

  final iconList = [
    Icons.home,
    Icons.favorite,
    Icons.shopping_bag,
    Icons.settings,
  ];

  _loadTabs() async {
    allNavWidgets = await bottomNavWidgets();
    setState(() {});
  }

  _loadAnimations() {
    _hideBottomBarAnimationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void initState() {
    super.initState();

    activeWidget = CompoHomeWidget(wooSignalApp: widget.wooSignalApp);
    _loadTabs();
    _loadAnimations();
  }

  bool onScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification && notification.metrics.axis == Axis.vertical) {
      switch (notification.direction) {
        case ScrollDirection.forward:
          _hideBottomBarAnimationController.reverse();
          break;
        case ScrollDirection.reverse:
          _hideBottomBarAnimationController.forward();
          break;
        case ScrollDirection.idle:
          break;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: onScrollNotification,
        child: activeWidget!,
      ),
      resizeToAvoidBottomInset: false,
      extendBody: true,
      floatingActionButton: FloatingActionButton.small(
        shape: CircleBorder(),
        backgroundColor: Colors.blue,
        child: Icon(
          Icons.menu,
          color: Colors.white,
        ),
        onPressed: () {
          _hideBottomBarAnimationController.reset();
          _changeMainWidget(2, allNavWidgets, updateCurrentIndex: false);
        },
        //params
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: allNavWidgets.isEmpty
          ? AppLoaderWidget()
          : AnimatedBottomNavigationBar.builder(
              itemCount: iconList.length,
              tabBuilder: (int index, bool isActive) {
                return Icon(
                  iconList[index],
                  size: 24,
                  color: isActive ? Colors.blue : Colors.white,
                );
              },
              backgroundColor: Colors.black54,
              activeIndex: _currentIndex,
              gapLocation: GapLocation.center,
              splashSpeedInMilliseconds: 300,
              notchSmoothness: NotchSmoothness.softEdge,
              leftCornerRadius: 32,
              rightCornerRadius: 32,
              hideAnimationController: _hideBottomBarAnimationController,
              onTap: (index) => _changeMainWidget(index, allNavWidgets),
              //other params
            ),
    );
  }

  Future<List<BottomNavItem>> bottomNavWidgets() async {
    List<BottomNavItem> items = [];
    items.add(
      BottomNavItem(
          id: 1,
          bottomNavigationBarItem: BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home'.tr(),
          ),
          tabWidget: CompoHomeWidget(wooSignalApp: widget.wooSignalApp)),
    );

    if (AppHelper.instance.appConfig!.wishlistEnabled == true) {
      items.add(BottomNavItem(
        id: 3,
        bottomNavigationBarItem: BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Wishlist'.tr(),
        ),
        tabWidget: WishListPageWidget(),
      ));
    }

    items.add(BottomNavItem(
      id: 4,
      bottomNavigationBarItem: BottomNavigationBarItem(icon: Icon(Icons.search_outlined), label: 'Categories'.tr()),
      tabWidget: CategoriesPage(
        wooSignalApp: AppHelper.instance.appConfig,
      ),
    ));

    items.add(BottomNavItem(
      id: 5,
      bottomNavigationBarItem: BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'.tr()),
      tabWidget: CartPage(),
    ));

    /*if (AppHelper.instance.appConfig!.wpLoginEnabled == 1) {
      items.add(BottomNavItem(
        id: 5,
        bottomNavigationBarItem: BottomNavigationBarItem(
            icon: Icon(Icons.person), label: 'Account'.tr()),
        tabWidget: (await WPJsonAPI.wpUserLoggedIn())
            ? AccountDetailPage(showLeadingBackButton: false)
            : AccountLoginPage(
                showBackButton: false,
              ),
      ));
    }*/

    items.add(BottomNavItem(
      id: 6,
      bottomNavigationBarItem: BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'.tr()),
      tabWidget: SettingsPage(
        wooSignalApp: AppHelper.instance.appConfig,
      ),
    ));

    return items;
  }

  _changeMainWidget(int currentIndex, List<BottomNavItem> bottomNavWidgets, {bool updateCurrentIndex = true}) async {
    if (updateCurrentIndex) _currentIndex = currentIndex;
    activeWidget = bottomNavWidgets[currentIndex].tabWidget;
    setState(() {});
  }
}
