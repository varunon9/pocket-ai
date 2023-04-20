import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pocket_ai/src/constants.dart';
import 'package:pocket_ai/src/globals.dart';
import 'package:pocket_ai/src/modules/chat/chat_actions.dart';
import 'package:pocket_ai/src/modules/chat/models/chat_message.dart';
import 'package:pocket_ai/src/modules/content_generator/widgets/content_image.dart';
import 'package:pocket_ai/src/modules/faqs/screens/faqs_screen.dart';
import 'package:pocket_ai/src/modules/settings/screens/settings_screen.dart';
import 'package:pocket_ai/src/utils/analytics.dart';
import 'package:pocket_ai/src/utils/common.dart';
import 'package:pocket_ai/src/widgets/bot_or_user_message_bubble.dart';
import 'package:pocket_ai/src/widgets/custom_colors.dart';
import 'package:pocket_ai/src/widgets/custom_text_form_field.dart';
import 'package:pocket_ai/src/widgets/heading.dart';
import 'package:pocket_ai/src/widgets/system_message.dart';

class ContentGeneratorScreen extends StatefulWidget {
  static const routeName = '/content-generator';

  const ContentGeneratorScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ContentGeneratorScreen();
}

class _ContentGeneratorScreen extends State<ContentGeneratorScreen> {
  List<ChatMessage> chatMessages = [
    ChatMessage(
        content: AiBotConstants.introMessageForContentGenerator,
        role: ChatRole.assistant)
  ];
  bool apiCallInProgress = false;
  FirebaseFirestore db = FirebaseFirestore.instance;

  TextEditingController contentGeneratorPromptController =
      TextEditingController();
  ScrollController listViewController = ScrollController();

  @override
  void initState() {
    super.initState();
    logEvent(EventNames.contentGeneratorScreenViewed, {});
  }

  void onChatMessageLongPress(ChatMessage chatItem) {
    Clipboard.setData(ClipboardData(text: chatItem.content)).then((value) {
      showToastMessage('Copied to Clipboard');
    });
  }

  void saveContentGeneratorPromptsToFirestore(String prompt) {
    // store prompts to Firestore for study & analytics
    String? deviceId = Globals.deviceId;
    if (deviceId != null) {
      db
          .collection(FirestoreCollectionsConst.contentGeneratorPrompts)
          .doc(deviceId)
          .collection(FirestoreCollectionsConst.prompts)
          .doc()
          .set({'prompt': prompt, 'time': FieldValue.serverTimestamp()});
    }
  }

  void onSendPress() {
    String prompt = contentGeneratorPromptController.text;
    if (prompt.isEmpty) {
      return;
    }
    logEvent(EventNames.generateContentClicked, {});

    // create context from previous chat, consider only last 4 messages
    // so that we don't run out of tokens limit
    List<ChatMessage> lastNMessages = getLastNMessagesFromChat(chatMessages);

    setState(() {
      chatMessages = [
        ...chatMessages,
        ChatMessage(content: prompt, role: ChatRole.user)
      ];
      apiCallInProgress = true;
    });
    contentGeneratorPromptController.text = '';

    // adding delay so that list view is scrolled after setState re-render has been completed
    Future.delayed(const Duration(milliseconds: 100), () {
      listViewController.jumpTo(listViewController.position.maxScrollExtent);
    });
    saveContentGeneratorPromptsToFirestore(prompt);

    getResponseFromOpenAi([
      ...lastNMessages,
      ChatMessage(content: prompt, role: ChatRole.user)
    ]).then((response) {
      String botMessage = '${response['choices'][0]['message']['content']}';
      setState(() {
        chatMessages = [
          ...chatMessages,
          ChatMessage(content: botMessage, role: ChatRole.assistant)
        ];
      });
      logEvent(EventNames.openAiResponseSuccess, {});
    }).catchError((error) {
      logApiErrorAndShowMessage(context, exception: error);
      logEvent(EventNames.openAiResponseFailed, {});
    }).then((value) {
      setState(() {
        apiCallInProgress = false;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        listViewController.jumpTo(listViewController.position.maxScrollExtent);
      });
    });
  }

  void handlePopupMenuClick(int item) {
    switch (item) {
      case 0:
        logEvent(EventNames.helpIconClicked, {});
        navigateToScreen(context, FaqsScreen.routeName);
        break;
      case 1:
        logEvent(EventNames.settingsIconClicked, {});
        navigateToScreen(context, SettingsScreen.routeName);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Heading(
            'Content Generator',
            type: HeadingType.h4,
          ),
          backgroundColor: CustomColors.darkBackground,
          actions: <Widget>[
            PopupMenuButton<int>(
              onSelected: (item) => handlePopupMenuClick(item),
              itemBuilder: (context) => [
                const PopupMenuItem<int>(value: 0, child: Text('Help')),
                const PopupMenuItem<int>(value: 1, child: Text('Settings')),
              ],
            ),
          ]),
      body: Stack(children: [
        Container(
            margin: const EdgeInsets.only(bottom: 72),
            child: ListView.builder(
                controller: listViewController,
                itemCount: chatMessages.length,
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                itemBuilder: (context, index) {
                  var chatItem = chatMessages[index];
                  bool fromBot = chatItem.role == ChatRole.assistant;
                  bool fromSystem = chatItem.role == ChatRole.system;
                  return GestureDetector(
                    onLongPress: () {
                      onChatMessageLongPress(chatItem);
                    },
                    child: fromSystem
                        ? SystemMessage(content: chatItem.content)
                        : BotOrUserMessageBubble(
                            fromBot: fromBot,
                            child: fromBot && index != 0
                                ? ContentImage(content: chatItem.content)
                                : MarkdownBody(data: chatItem.content),
                          ),
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
                          controller: contentGeneratorPromptController,
                          minLines: 1,
                          maxLines: 4,
                          textInputType: TextInputType.multiline,
                          hintText: 'Your prompt to generate content'),
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
