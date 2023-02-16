import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:pocket_ai/src/constants.dart';
import 'package:pocket_ai/src/modules/chat/chat_actions.dart';
import 'package:pocket_ai/src/modules/chat/models/chat_message.dart';
import 'package:pocket_ai/src/utils/analytics.dart';
import 'package:pocket_ai/src/utils/common.dart';
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
    ChatMessage(message: AIBotConstants.introMessage, bot: true)
  ];
  bool apiCallInProgress = false;

  // consider last n messages for building context
  int lastMessagesCountForContext = 4;

  TextEditingController userMessageController = TextEditingController();
  ScrollController listViewontroller = ScrollController();

  void onSendPress() {
    String userMessage = userMessageController.text;
    if (userMessage.isEmpty) {
      return;
    }
    logEvent(EventNames.ctaClicked,
        {EventParams.ctaName: 'send', EventParams.userMessage: userMessage});

    // create context from previous chat, consider only last n messages
    // so that we don't run out of tokens limit
    String chatContext = '';
    int messageStartIndex =
        chatMessages.length - lastMessagesCountForContext >= 0
            ? (chatMessages.length - lastMessagesCountForContext)
            : 0;
    for (int i = messageStartIndex; i < chatMessages.length; i++) {
      ChatMessage chatMessage = chatMessages[i];
      chatContext +=
          "${chatMessage.bot ? 'AI:' : 'Human:'} ${chatMessage.message}\n";
    }

    setState(() {
      chatMessages = [
        ...chatMessages,
        ChatMessage(message: userMessage, bot: false)
      ];
      apiCallInProgress = true;
    });
    userMessageController.text = '';
    Future.delayed(const Duration(milliseconds: 100), () {
      listViewontroller.jumpTo(listViewontroller.position.maxScrollExtent);
    });
    getResponseFromOpenAi(chatContext, userMessage).then((response) {
      String botMessage = '${response['choices'][0]['text']}';
      setState(() {
        chatMessages = [
          ...chatMessages,
          ChatMessage(message: botMessage, bot: true)
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
        listViewontroller.jumpTo(listViewontroller.position.maxScrollExtent);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Heading(
            'Pocket AI',
            type: HeadingType.h4,
          ),
          backgroundColor: CustomColors.darkBackground,
          actions: <Widget>[
            IconButton(
                tooltip: 'Help',
                onPressed: (() {}),
                icon: const Icon(Icons.help)),
            IconButton(
                tooltip: 'Settings',
                onPressed: (() {}),
                icon: const Icon(Icons.settings))
          ]),
      body: Stack(children: [
        Container(
            margin: const EdgeInsets.only(bottom: 72),
            child: ListView.builder(
                controller: listViewontroller,
                itemCount: chatMessages.length,
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                itemBuilder: (context, index) {
                  var chatItem = chatMessages[index];
                  return Bubble(
                      nip:
                          chatItem.bot ? BubbleNip.leftTop : BubbleNip.rightTop,
                      margin:
                          const BubbleEdges.only(top: 16, left: 8, right: 16),
                      color:
                          chatItem.bot ? Colors.white : CustomColors.lightText,
                      alignment:
                          chatItem.bot ? Alignment.topLeft : Alignment.topRight,
                      child: CustomText(chatItem.message));
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
