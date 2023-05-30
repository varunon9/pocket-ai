import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pocket_ai/src/constants.dart';
import 'package:pocket_ai/src/modules/chat/chat_actions.dart';
import 'package:pocket_ai/src/modules/chat/models/chat_message.dart';
import 'package:pocket_ai/src/modules/content_generator/widgets/content_image.dart';
import 'package:pocket_ai/src/utils/analytics.dart';
import 'package:pocket_ai/src/utils/common.dart';
import 'package:pocket_ai/src/widgets/bot_or_user_message_bubble.dart';
import 'package:pocket_ai/src/widgets/custom_colors.dart';
import 'package:pocket_ai/src/widgets/custom_popup_menu.dart';
import 'package:pocket_ai/src/widgets/custom_text_form_field.dart';
import 'package:pocket_ai/src/widgets/heading.dart';
import 'package:pocket_ai/src/widgets/system_message.dart';

class TodosManagerScreen extends StatefulWidget {
  static const routeName = '/todos-manager';

  const TodosManagerScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TodosManagerScreen();
}

class _TodosManagerScreen extends State<TodosManagerScreen> {
  List<ChatMessage> chatMessages = [
    ChatMessage(
        content: AiBotConstants.introMessageForTodosManager,
        role: ChatRole.assistant)
  ];
  bool apiCallInProgress = false;

  TextEditingController todosManagerPromptController = TextEditingController();
  ScrollController listViewController = ScrollController();

  @override
  void initState() {
    super.initState();
    logEvent(EventNames.todosManagerScreenViewed, {});
  }

  void onChatMessageLongPress(ChatMessage chatItem) {
    Clipboard.setData(ClipboardData(text: chatItem.content)).then((value) {
      showToastMessage('Copied to Clipboard');
    });
  }

  void onSendPress() {
    String prompt = todosManagerPromptController.text;
    if (prompt.isEmpty) {
      return;
    }
    logEvent(EventNames.sendButtonInTodosManagerClicked, {});

    setState(() {
      chatMessages = [
        ...chatMessages,
        ChatMessage(content: prompt, role: ChatRole.user)
      ];
      apiCallInProgress = true;
    });
    todosManagerPromptController.text = '';

    // adding delay so that list view is scrolled after setState re-render has been completed
    Future.delayed(const Duration(milliseconds: 100), () {
      listViewController.jumpTo(listViewController.position.maxScrollExtent);
    });
    savePromptsToFirestoreCollection(
        prompt, FirestoreCollectionsConst.todosManagerPrompts);

    getResponseFromOpenAi([ChatMessage(content: prompt, role: ChatRole.user)])
        .then((response) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          //automaticallyImplyLeading: false,
          title: const Heading(
            'Todos Manager',
            type: HeadingType.h4,
          ),
          backgroundColor: CustomColors.darkBackground,
          actions: const <Widget>[
            CustomPopupMenu(),
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
                          controller: todosManagerPromptController,
                          minLines: 1,
                          maxLines: 4,
                          textInputType: TextInputType.multiline,
                          hintText: 'A complete and clear instruction to bot'),
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
