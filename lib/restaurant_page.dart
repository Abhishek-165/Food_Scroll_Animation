import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_autoscroll_menu/components/menu_card.dart';
import 'package:grocery_autoscroll_menu/components/restaruant_categories.dart';
import 'package:grocery_autoscroll_menu/components/restaurant_info.dart';
import 'package:grocery_autoscroll_menu/models/menu.dart';

class RestaurantCategories extends SliverPersistentHeaderDelegate {
  final ValueChanged<int> onChanged;
  final int selectedIndex;

  RestaurantCategories({required this.onChanged, required this.selectedIndex});
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: 52,
      decoration: const BoxDecoration(color: Colors.white),
      child: Categories(
        onChanged: onChanged,
        selectedIndex: selectedIndex,
      ),
    );
  }

  @override
  double get maxExtent => 52;

  @override
  double get minExtent => 52;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class RestaurantPage extends StatefulWidget {
  const RestaurantPage({Key? key}) : super(key: key);

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  int selectedCategoryIndex = 0;
  ScrollController scrollController = ScrollController();

  double restuarantHeight = 200 + 170 - kToolbarHeight;

  @override
  void initState() {
    createBreakPoints();
    scrollController.addListener(() {
      scrollOnBreakPoints(scrollController.offset);
    });
    super.initState();
  }

  List<double> breakPoints = [];

  void createBreakPoints() {
    double firstBreakPoint =
        restuarantHeight + (132 * demoCategoryMenus.first.items.length) + 50;

    breakPoints.add(firstBreakPoint);

    for (int i = 1; i < demoCategoryMenus.length; i++) {
      double breakPoint =
          breakPoints.last + (132 * demoCategoryMenus[i].items.length) + 50;
      breakPoints.add(breakPoint);
    }
  }

  void scrollOnBreakPoints(double offset) {
    for (int i = 0; i < demoCategoryMenus.length; i++) {
      if (i == 0) {
        if ((offset < breakPoints.first) && (selectedCategoryIndex != 0)) {
          setState(() {
            selectedCategoryIndex = 0;
          });
        }
      } else if ((breakPoints[i - 1] <= offset) && (offset < breakPoints[i])) {
        if (selectedCategoryIndex != i) {
          setState(() {
            selectedCategoryIndex = i;
          });
        }
      }
    }
  }

  void onScrollChanged(int index) {
    if (selectedCategoryIndex != index) {
      int totalItems = 0;
      for (int i = 0; i < index; i++) {
        totalItems += demoCategoryMenus[i].items.length;
      }
      // 116 = 100 Menu item height = 16 bottom padding
      //50 = 18 title font size + 32 (vertical 16 + horizontal  16)
      scrollController.animateTo(
          restuarantHeight + (132 * totalItems) + (50 * index),
          duration: const Duration(microseconds: 500),
          curve: Curves.ease);

      setState(() {
        selectedCategoryIndex = index;
      });
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                "assets/images/Header-image.png",
                fit: BoxFit.cover,
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: SvgPicture.asset("assets/icons/back.svg"),
              ),
            ),
            actions: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: SvgPicture.asset(
                  "assets/icons/share.svg",
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: SvgPicture.asset(
                    "assets/icons/search.svg",
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SliverToBoxAdapter(child: RestaurantInfo()),
          SliverPersistentHeader(
            pinned: true,
            delegate: RestaurantCategories(
                onChanged: onScrollChanged,
                selectedIndex: selectedCategoryIndex),
          ),
          SliverList(
              delegate: SliverChildBuilderDelegate(((context, index) {
            List<Menu> items = demoCategoryMenus[index].items;
            return MenuCategoryItem(
              title: demoCategoryMenus[index].category,
              items: List.generate(
                  items.length,
                  (index) => Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: MenuCard(
                          title: items[index].title,
                          image: items[index].image,
                          price: items[index].price,
                          items: null,
                        ),
                      )),
            );
          }), childCount: demoCategoryMenus.length))
        ],
      ),
    );
  }
}
