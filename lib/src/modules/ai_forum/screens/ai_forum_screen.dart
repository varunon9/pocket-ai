import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pocket_ai/src/constants.dart';
import 'package:pocket_ai/src/globals.dart';
import 'package:pocket_ai/src/modules/ai_forum/models/ai_forum_message.dart';
import 'package:pocket_ai/src/modules/ai_forum/models/pocket_ai_ad.dart';
import 'package:pocket_ai/src/modules/ai_forum/widgets/ai_forum_message_bubble.dart';
import 'package:pocket_ai/src/modules/ai_forum/widgets/pocket_ai_ads_list.dart';
import 'package:pocket_ai/src/utils/analytics.dart';
import 'package:pocket_ai/src/utils/common.dart';
import 'package:pocket_ai/src/widgets/custom_colors.dart';
import 'package:pocket_ai/src/widgets/custom_popup_menu.dart';
import 'package:pocket_ai/src/widgets/custom_text.dart';
import 'package:pocket_ai/src/widgets/custom_text_form_field.dart';
import 'package:pocket_ai/src/widgets/heading.dart';

class AiForumScreen extends StatefulWidget {
  static const routeName = '/ai-forum';

  const AiForumScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AiForumScreen();
}

class _AiForumScreen extends State<AiForumScreen> {
  final Stream<QuerySnapshot> aiForumMessagesStream = FirebaseFirestore.instance
      .collection(FirestoreCollectionsConst.aiForumMessages)
      .where('time',
          isGreaterThanOrEqualTo:
              DateTime.now().subtract(const Duration(hours: 24)))
      .orderBy('time', descending: false)
      .snapshots();

  final Stream<QuerySnapshot> onlineUserSessionsStream = FirebaseFirestore
      .instance
      .collection(FirestoreCollectionsConst.userSessionsCount)
      .where('online', isEqualTo: true)
      .snapshots();
  final List<PocketAiAd> pocketAiAds = [];

  TextEditingController aiForumMessageController = TextEditingController();

  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    logEvent(EventNames.aiForumScreenViewed, {});

    db
        .collection(FirestoreCollectionsConst.pocketAiAds)
        .where('visible', isEqualTo: true)
        .orderBy('index')
        .get()
        .then((response) {
      for (var doc in response.docs) {
        pocketAiAds.add(PocketAiAd.fromJson(doc.data()));
      }
      // re-render
      setState(() {});
    }).catchError((error) {
      showSnackBar(context, message: error.toString());
      logGenericError(error);
    });
  }

  void onAiForumMessageLongPress(AiForumMessage messageItem) {
    Clipboard.setData(ClipboardData(text: messageItem.content)).then((value) {
      showToastMessage('Copied to Clipboard');
    });
  }

  void onSendPress() {
    String message = aiForumMessageController.text;
    if (message.isEmpty) {
      return;
    }
    logEvent(EventNames.sendAiForumMessageClicked, {});
    String? deviceId = Globals.deviceId;
    if (deviceId != null) {
      db.collection(FirestoreCollectionsConst.aiForumMessages).doc().set({
        'content': message,
        'deviceId': Globals.deviceId,
        'username': Globals.appSettings.aiForumUsername,
        'time': FieldValue.serverTimestamp()
      });
    }
    aiForumMessageController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Heading(
                'AI Forum',
                type: HeadingType.h4,
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: onlineUserSessionsStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    return Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: CustomText(
                        "(Online users: ${snapshot.data?.docs.length ?? 0})",
                        size: CustomTextSize.small,
                        style: const TextStyle(color: CustomColors.primary),
                      ),
                    );
                  })
            ],
          ),
          backgroundColor: CustomColors.darkBackground,
          actions: const <Widget>[
            CustomPopupMenu(),
          ]),
      body: Stack(children: [
        PocketAiAdsList(
          pocketAiAds: pocketAiAds,
        ),
        Container(
            margin:
                EdgeInsets.only(bottom: 72, top: pocketAiAds.isEmpty ? 0 : 96),
            child: StreamBuilder<QuerySnapshot>(
              stream: aiForumMessagesStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: CustomColors.primary,
                    ),
                  );
                }

                return ListView(
                  children: snapshot.data!.docs
                      .map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        AiForumMessage messageItem =
                            AiForumMessage.fromJson(data);
                        bool messageFromSelf =
                            messageItem.deviceId == Globals.deviceId;
                        String? username = isEmpty(messageItem.username)
                            ? messageItem.deviceId
                            : messageItem.username;
                        return GestureDetector(
                          onLongPress: () {
                            onAiForumMessageLongPress(messageItem);
                          },
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  margin:
                                      const EdgeInsets.only(top: 12, left: 12),
                                  decoration: BoxDecoration(
                                      color: CustomColors.secondary,
                                      shape: BoxShape.circle,
                                      border: Border.all()),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                Expanded(
                                    child: AiForumMessageBubble(
                                  messageFromSelf: messageFromSelf,
                                  message: messageItem,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 8),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CustomText(
                                                '@$username',
                                                size: CustomTextSize.tiny,
                                              )
                                            ],
                                          )),
                                      MarkdownBody(
                                          data: messageItem.content ?? 'Null'),
                                      Container(
                                          margin: const EdgeInsets.only(top: 8),
                                          child: CustomText(
                                            messageItem.time == null
                                                ? ''
                                                : getFormattedTime(
                                                    messageItem.time!),
                                            size: CustomTextSize.tiny,
                                          ))
                                    ],
                                  ),
                                ))
                              ]),
                        );
                      })
                      .toList()
                      .cast(),
                );
              },
            )),
        Align(
          alignment: Alignment.bottomLeft,
          child: Container(
              margin:
                  const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: CustomTextFormField(
                          onChanged: (value) => {},
                          controller: aiForumMessageController,
                          minLines: 1,
                          maxLines: 4,
                          textInputType: TextInputType.multiline,
                          hintText: 'Your message to Forum'),
                    ),
                  ),
                  Ink(
                    decoration: const ShapeDecoration(
                      color: CustomColors.secondary,
                      shape: CircleBorder(),
                    ),
                    width: 48,
                    height: 48,
                    child: IconButton(
                        tooltip: 'Send',
                        onPressed: onSendPress,
                        color: CustomColors.primary,
                        icon: const Icon(Icons.send_rounded)),
                  )
                ],
              )),
        )
      ]),
    );
  }
}
