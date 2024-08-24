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
import 'package:flutter/services.dart';
import 'package:flutter_app/resources/pages/categories_page.dart';
import 'package:flutter_app/resources/pages/settings_page.dart';
import 'package:flutter_app/utils/colors_manager.dart';
import 'package:flutter_app/utils/video_manager.dart';
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
  int _currentIndex = 0;
  bool isMainMenuSelected = false;
  List<BottomNavItem> allNavWidgets = [];

  late AnimationController _hideBottomBarAnimationController;
  late TabController tabController;

  final iconList = [
    Icons.home,
    Icons.favorite,
    Icons.shopping_bag,
    Icons.settings,
  ];

  _loadTabs() async {
    allNavWidgets = bottomNavWidgets();
    setState(() {});

    tabController = TabController(
      initialIndex: 0,
      length: 5,
      vsync: this,
    );
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

    _loadTabs();
    _loadAnimations();

    ColorsManager().syncColors();
    VideoManager().initialize();
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
          child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: tabController,
            children: allNavWidgets.map((e) => e.tabWidget).toList(),
          )),
      resizeToAvoidBottomInset: false,
      extendBody: true,
      floatingActionButton: FloatingActionButton.small(
        shape: CircleBorder(),
        backgroundColor: Colors.white,
        child: Icon(Icons.menu, color: Colors.black),
        onPressed: () {
          HapticFeedback.mediumImpact();
          _hideBottomBarAnimationController.reset();
          isMainMenuSelected = !isMainMenuSelected;
          setState(() {});
          tabController.animateTo(2);
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
                  color: isActive && !isMainMenuSelected ? Colors.black : Colors.black26,
                );
              },
              backgroundColor: Colors.white,
              activeIndex: _currentIndex,
              gapLocation: GapLocation.center,
              splashSpeedInMilliseconds: 300,
              notchSmoothness: NotchSmoothness.softEdge,
              leftCornerRadius: 32,
              rightCornerRadius: 32,
              hideAnimationController: _hideBottomBarAnimationController,
              onTap: (index) => _changeMainWidget(index >= 2 ? index + 1 : index, allNavWidgets, index >= 2 ? false : true),
              //other params
            ),
    );
  }

  List<BottomNavItem> bottomNavWidgets() {
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

  _changeMainWidget(int currentIndex, List<BottomNavItem> bottomNavWidgets, bool updateIconIndex) async {
    HapticFeedback.mediumImpact();
    _currentIndex = currentIndex - (updateIconIndex ? 0 : 1);
    isMainMenuSelected = false;
    tabController.animateTo(currentIndex);
    setState(() {});
  }
}
