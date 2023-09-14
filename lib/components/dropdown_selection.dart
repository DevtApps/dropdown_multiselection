import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MultiSelect extends StatelessWidget {
  RxList<SingleItem> items;

  late GlobalKey _key;

  LayerLink link = LayerLink();
  String title = "Selecionar";

  List<SingleItem> auxSearch = [];
  bool unique = false;
  Function(List<SingleItem>) onPressed;
   MultiSelect(
      {super.key, this.title = "Selecionar",
      required this.onPressed,
      required this.items,
      this.unique = false}) {
    _key = GlobalKey();
  }

  RxBool hasFocus = RxBool(false);

  OverlayEntry? entry;
  BuildContext? context;
  RxString text = RxString("");

  RenderBox? box;
  Widget buildEntry() {
    return Positioned(
      width: box!.size.width,
      child: CompositedTransformFollower(
        link: link,
        showWhenUnlinked: false,
        offset: const Offset(0.0, 60),
        child: Center(
          child: Card(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() {
                    auxSearch.clear();
                    if (text.isNotEmpty) {
                      auxSearch.addAll(items.where((element) => element.title
                          .toLowerCase()
                          .contains(text.toLowerCase())));
                    } else {
                      auxSearch.addAll(items);
                    }
                    return SizedBox(
                      height: min(items.length * 55, 240),
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: auxSearch.length,
                          itemBuilder: (c, i) {
                            SingleItem item = auxSearch[i];
                            return unique
                                ? ListTile(
                                    title: Text(item.title),
                                    onTap: () {
                                      onPressed(items);
                                      items.value = items
                                          .map((element) =>
                                              element..checked.value = false)
                                          .toList();
                                      item.checked.value = true;

                                      entry!.remove();
                                      entry!.dispose();
                                      entry = null;
                                      hasFocus.value = false;
                                    },
                                  )
                                : Obx(() => CheckboxListTile(
                                    value: item.checked.value,
                                    title: Text(item.title),
                                    onChanged: (e) {
                                      item.checked.value = e!;
                                    }));
                          }),
                    );
                  }),
                  ListTile(
                    trailing: TextButton(
                      child: const Text("OK"),
                      onPressed: () {
                        onPressed(items.where((e) => e.checked.value).toList());
                        entry!.remove();
                        entry!.dispose();
                        entry = null;
                        hasFocus.value = false;
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  show() {
    if (entry == null) {
      entry = OverlayEntry(builder: (c) => buildEntry());
      box = _key.currentContext!.findRenderObject() as RenderBox;
      Overlay.of(context!).insert(entry!);
      hasFocus.value = true;
    }
    text.value = "";
  }

  @override
  Widget build(BuildContext context) {
    auxSearch.addAll(items);

    this.context = context;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CompositedTransformTarget(
        key: _key,
        link: link,
        child: Card(
          elevation: 0,
          color: Colors.grey.shade100,
          shape: RoundedRectangleBorder(
              side: BorderSide(width: 0.5, color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4)),
          child: Obx(
            () => hasFocus.value
                ? TextFormField(
                    onChanged: (value) => text.value = value,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      hintText: title,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      prefixIcon: const Icon(
                        Icons.search,
                      ),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
                  )
                : TextFormField(
                    onTap: show,
                    readOnly: true,
                    focusNode: FocusNode(canRequestFocus: false),
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      hintText: title,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      prefixIcon: const Icon(
                        Icons.search,
                      ),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
                  ),
          ),
        ),
      ),
      Obx(
        () => Wrap(
          alignment: WrapAlignment.start,
          children: items
              .where((element) => element.checked.value)
              .map(
                (e) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: InkWell(
                    onTap: () {
                      e.checked.value = false;
                      onPressed(items.where((p) => p.checked.value).toList());
                    },
                    child: Chip(
                      backgroundColor: Theme.of(Get.context!).primaryColor,
                      label: Text(
                        e.title,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    ]);
  }
}

class SingleItem {
  String title;
  dynamic value;
  RxBool checked = RxBool(false);

  SingleItem({required this.title, required this.value, checked}) {
    this.checked.value = checked ?? false;
  }
}
