import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pocket_ai/src/constants.dart';
import 'package:pocket_ai/src/db/chat_with_bot_provider.dart';
import 'package:pocket_ai/src/globals.dart';
import 'package:pocket_ai/src/modules/ai_forum/screens/ai_forum_screen.dart';
import 'package:pocket_ai/src/modules/chat/chat_actions.dart';
import 'package:pocket_ai/src/modules/chat/models/chat_message.dart';
import 'package:pocket_ai/src/modules/chat/models/drawer_menu_item.dart';
import 'package:pocket_ai/src/modules/chat/widgets/custom_navigation_drawer.dart';
import 'package:pocket_ai/src/modules/content_generator/screens/content_generator_screen.dart';
import 'package:pocket_ai/src/modules/faqs/screens/faqs_screen.dart';
import 'package:pocket_ai/src/modules/settings/screens/settings_screen.dart';
import 'package:pocket_ai/src/modules/todos_manager/todos_manager_screen.dart';
import 'package:pocket_ai/src/utils/analytics.dart';
import 'package:pocket_ai/src/utils/common.dart';
import 'package:pocket_ai/src/widgets/bot_or_user_message_bubble.dart';
import 'package:pocket_ai/src/widgets/custom_colors.dart';
import 'package:pocket_ai/src/widgets/custom_text.dart';
import 'package:pocket_ai/src/widgets/custom_text_form_field.dart';
import 'package:pocket_ai/src/widgets/heading.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat';

  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatScreen();
}

class _ChatScreen extends State<ChatScreen> {
  List<ChatMessage> chatMessages = [
    ChatMessage(content: AiBotConstants.introMessage, role: ChatRole.assistant)
  ];
  bool apiCallInProgress = false;
  FirebaseFirestore db = FirebaseFirestore.instance;

  TextEditingController userMessageController = TextEditingController();
  ScrollController listViewontroller = ScrollController();

  ChatWithBotProvider chatWithBotProvider = ChatWithBotProvider();

  int? sessionsCount;

  @override
  void initState() {
    super.initState();
    logEvent(EventNames.chatScreenViewed, {});

    // if user hasn't set his own api key then get one from Firestore
    // only upto maxFreeSession sessions

    String? deviceId = Globals.deviceId;
    if (deviceId != null) {
      DocumentReference<Map<String, dynamic>> documentRef = db
          .collection(FirestoreCollectionsConst.userSessionsCount)
          .doc(deviceId);
      // get session count
      documentRef.get().then((response) {
        Map<String, dynamic>? data = response.data();
        int sessionsCountFromFirestore = data == null ? 0 : data['count'];
        setState(() {
          sessionsCount = sessionsCountFromFirestore;
        });
        if (isEmpty(Globals.appSettings.openAiApiKey) &&
            sessionsCountFromFirestore <= Globals.maxFreeSessions) {
          // get open AI key and set to Globals
          db
              .collection(FirestoreCollectionsConst.openAiApiKeys)
              .get()
              .then((response) {
            if (response.docs.isNotEmpty) {
              Map<String, dynamic>? data = response.docs[0].data();
              Globals.freeOpenAiApiKey = data['apiKey'];
              Globals.appSettings.openAiApiKey = data['apiKey'];
            }
          }).catchError((error) {
            showSnackBar(context, message: error.toString());
          });
        }
        // increase the session count in Firestore
        documentRef.set({
          'count': sessionsCountFromFirestore + 1,
          'createdAt': (data == null || data['createdAt'] == null)
              ? FieldValue.serverTimestamp()
              : data['createdAt'],
          'lastSeen': FieldValue.serverTimestamp(),
          'online': true
        });
      }).catchError((error) {
        showSnackBar(context, message: error.toString());
        logGenericError(error);
      });
    }

    chatWithBotProvider.open().then((value) {
      chatWithBotProvider.getChats().then((value) {
        if (value.isNotEmpty) {
          setState(() {
            chatMessages = value;
          });
          scrollListToBottom();
        } else {
          chatWithBotProvider.insertChat(ChatMessage(
              content: AiBotConstants.introMessage, role: ChatRole.assistant));
        }
      }).catchError((error) {
        showSnackBar(context, message: error.toString());
        logGenericError(error);
      });
    }).catchError((error) {
      showSnackBar(context, message: error.toString());
      logGenericError(error);
    });
  }

  void onChatMessageLongPress(ChatMessage chatItem) {
    Clipboard.setData(ClipboardData(text: chatItem.content)).then((value) {
      showToastMessage('Copied to Clipboard');
    });
  }

  void saveUserMessageToFirestore(String userMessage) {
    // store user queries to Firestore for study & analytics
    String? deviceId = Globals.deviceId;
    if (deviceId != null) {
      db
          .collection(FirestoreCollectionsConst.userMessagesToBot)
          .doc(deviceId)
          .collection(FirestoreCollectionsConst.messages)
          .doc()
          .set({'message': userMessage, 'time': FieldValue.serverTimestamp()});
    }
  }

  void scrollListToBottom() {
    // adding delay so that list view is scrolled after setState re-render has been completed
    Future.delayed(const Duration(milliseconds: 100), () {
      listViewontroller.jumpTo(listViewontroller.position.maxScrollExtent);
    });
  }

  void onSendPress() {
    String userMessage = userMessageController.text;
    if (userMessage.isEmpty) {
      return;
    }
    logEvent(EventNames.sendMessageClicked, {});

    // create context from previous chat, consider only last 4 messages
    // so that we don't run out of tokens limit
    List<ChatMessage> lastNMessages = getLastNMessagesFromChat(chatMessages);

    setState(() {
      chatMessages = [
        ...chatMessages,
        ChatMessage(content: userMessage, role: ChatRole.user)
      ];
      apiCallInProgress = true;
    });
    userMessageController.text = '';

    scrollListToBottom();
    saveUserMessageToFirestore(userMessage);
    chatWithBotProvider
        .insertChat(ChatMessage(content: userMessage, role: ChatRole.user));

    getResponseFromOpenAi([
      ...lastNMessages,
      ChatMessage(content: userMessage, role: ChatRole.user)
    ]).then((response) {
      String botMessage = '${response['choices'][0]['message']['content']}';
      setState(() {
        chatMessages = [
          ...chatMessages,
          ChatMessage(content: botMessage, role: ChatRole.assistant)
        ];
      });
      chatWithBotProvider.insertChat(
          ChatMessage(content: botMessage, role: ChatRole.assistant));
      logEvent(EventNames.openAiResponseSuccess, {});
    }).catchError((error) {
      logApiErrorAndShowMessage(context, exception: error);
      logEvent(EventNames.openAiResponseFailed, {});
    }).then((value) {
      setState(() {
        apiCallInProgress = false;
      });
      scrollListToBottom();
    });
  }

  void onDrawerItemTapped(DrawerMenuItemsIds id) {
    switch (id) {
      case DrawerMenuItemsIds.aiForum:
        {
          navigateToScreen(context, AiForumScreen.routeName);
          break;
        }
      case DrawerMenuItemsIds.contentGenerator:
        {
          navigateToScreen(context, ContentGeneratorScreen.routeName);
          break;
        }
      case DrawerMenuItemsIds.todosManager:
        {
          navigateToScreen(context, TodosManagerScreen.routeName);
          break;
        }
      case DrawerMenuItemsIds.help:
        {
          navigateToScreen(context, FaqsScreen.routeName);
          break;
        }
      case DrawerMenuItemsIds.settings:
        {
          navigateToScreen(context, SettingsScreen.routeName);
          break;
        }
      case DrawerMenuItemsIds.rateApp:
        {
          onRatePocketAiPressed();
          break;
        }
      case DrawerMenuItemsIds.shareApp:
        {
          onSharePocketAiPressed();
          break;
        }
    }
  }

  void handlePopupMenuClick(BuildContext context, int item) {
    switch (item) {
      case 0:
        logEvent(EventNames.resetChatWithBotClicked, {});
        chatWithBotProvider.deleteChatMessages();
        setState(() {
          chatMessages = [
            ChatMessage(
                content: AiBotConstants.introMessage, role: ChatRole.assistant)
          ];
        });
        break;
    }
  }

  void onFreeSessionsInfoTextTap() {
    logEvent(EventNames.freeSessionsInfoKnowMoreClicked, {});
    navigateToScreen(context, FaqsScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    bool showFreeSessionsInfoBanner =
        sessionsCount != null && isEmpty(Globals.appSettings.openAiApiKey);
    return Scaffold(
      drawer: CustomNavigationDrawer(onItemTapped: onDrawerItemTapped),
      appBar: AppBar(
          title: const Heading(
            'Pocket AI',
            type: HeadingType.h4,
          ),
          backgroundColor: CustomColors.darkBackground,
          actions: <Widget>[
            PopupMenuButton<int>(
              onSelected: (item) => handlePopupMenuClick(context, item),
              itemBuilder: (context) => [
                const PopupMenuItem<int>(
                    value: 0, child: Text('Reset Chat with Assistant')),
              ],
            ),
          ]),
      body: Stack(children: [
        showFreeSessionsInfoBanner
            ? Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: CustomColors.lightText),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      sessionsCount! > Globals.maxFreeSessions
                          ? "You do not have any free sessions left. Please use your own OpenAI API key in Settings to keep using PocketAI"
                          : "You have ${Globals.maxFreeSessions - sessionsCount!} free sessions remaining out of ${Globals.maxFreeSessions}",
                      size: CustomTextSize.small,
                    ),
                    GestureDetector(
                        onTap: onFreeSessionsInfoTextTap,
                        child: Container(
                            padding: const EdgeInsets.only(top: 4),
                            child: const CustomText(
                              'Know more',
                              size: CustomTextSize.small,
                              style: TextStyle(
                                  color: CustomColors.hyperlink,
                                  decoration: TextDecoration.underline),
                            )))
                  ],
                ))
            : Container(),
        Container(
            margin: EdgeInsets.only(
                bottom: 72, top: (showFreeSessionsInfoBanner ? 72 : 0)),
            child: ListView.builder(
                controller: listViewontroller,
                itemCount: chatMessages.length,
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                itemBuilder: (context, index) {
                  var chatItem = chatMessages[index];
                  bool fromBot = chatItem.role == ChatRole.assistant;
                  return GestureDetector(
                    onLongPress: () {
                      onChatMessageLongPress(chatItem);
                    },
                    child: BotOrUserMessageBubble(
                        fromBot: fromBot,
                        child: MarkdownBody(data: chatItem.content)),
                  );
                })),
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
                          controller: userMessageController,
                          minLines: 1,
                          maxLines: 4,
                          textInputType: TextInputType.multiline,
                          hintText: 'Ask anything to Pocket AI bot'),
                    ),
                  ),
                  Ink(
                    decoration: const ShapeDecoration(
                      color: CustomColors.secondary,
                      shape: CircleBorder(),
                    ),
                    width: 48,
                    height: 48,
                    child: apiCallInProgress
                        ? const CircularProgressIndicator(
                            color: CustomColors.primary,
                          )
                        : IconButton(
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
