import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pocket_ai/src/constants.dart';
import 'package:pocket_ai/src/utils/analytics.dart';
import 'package:pocket_ai/src/utils/common.dart';
import 'package:pocket_ai/src/widgets/custom_colors.dart';
import 'package:pocket_ai/src/widgets/custom_text.dart';
import 'package:pocket_ai/src/widgets/heading.dart';

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({Key? key}) : super(key: key);

  static const routeName = '/faqs';

  @override
  State<StatefulWidget> createState() => _FaqsScreen();
}

class _FaqsScreen extends State<FaqsScreen> {
  bool isLoading = false;
  List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    logEvent(EventNames.faqScreenViewed, {});
    FirebaseFirestore db = FirebaseFirestore.instance;
    setState(() {
      isLoading = true;
    });
    db
        .collection(FirestoreCollectionsConst.faqs)
        .orderBy('index')
        .get()
        .then((response) {
      for (var doc in response.docs) {
        data.add(doc.data());
      }
    }).catchError((error) {
      showSnackBar(context, message: error.toString());
    }).then((value) => setState(() {
              isLoading = false;
            }));
  }

  Widget renderFooter() {
    return (Column(
      children: [
        Container(
            margin: const EdgeInsets.only(top: 12),
            child: const CustomText(
              'For more inforamtion, reach out to',
              style: TextStyle(color: Colors.white),
            )),
        Container(
            margin: const EdgeInsets.only(top: 0),
            child: const CustomText(
              'varunon9@gmail.com',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
            ))
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
            title: const Heading(
              'Knowledge Center & FAQs',
              type: HeadingType.h4,
            ),
            backgroundColor: CustomColors.darkBackground),
        body: Container(
            //padding: const EdgeInsets.all(16),
            color: CustomColors.darkBackground,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: data.length + 1, // extra 1 for footer
                    itemBuilder: ((context, index) => index == data.length
                        ? renderFooter()
                        : Column(
                            children: [
                              ExpansionTile(
                                iconColor: Colors.white,
                                collapsedIconColor: Colors.white,
                                title: CustomText(
                                  data[index]['question'],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700),
                                ),
                                children: [
                                  Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.only(
                                          left: 16, right: 16),
                                      child: CustomText(
                                        (data[index]['answer'] as String)
                                            .replaceAll('\\n', '\n')
                                            .replaceAll('\\t', '\t'),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400),
                                      ))
                                ],
                              ),
                              Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  child: const Divider(
                                    color: CustomColors.lightSecondary,
                                    indent: 16,
                                    endIndent: 16,
                                  ))
                            ],
                          ))))));
  }
}
