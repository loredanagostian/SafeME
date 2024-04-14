import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/managers/chat_manager.dart';
import 'package:safe_me/models/account.dart';

class ChatScreen extends StatefulWidget {
  final Account friendAccount;
  final String currentUserImageUrl;
  const ChatScreen(
      {super.key,
      required this.friendAccount,
      required this.currentUserImageUrl});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await ChatManager.sendMessage(
          widget.friendAccount.userId, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          titleSpacing: 0.0,
          title: Row(
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: Padding(
                    padding:
                        const EdgeInsets.only(right: AppSizes.smallDistance),
                    child: CircleAvatar(
                        backgroundImage:
                            FileImage(File(widget.friendAccount.imageURL)))),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.friendAccount.firstName} ${widget.friendAccount.lastName}",
                    style: AppStyles.notificationTitleStyle
                        .copyWith(color: AppColors.mainDarkGray),
                  ),
                  Text(AppStrings.activeNow,
                      style: AppStyles.notificationBodyStyle
                          .copyWith(color: AppColors.mediumBlue)),
                ],
              )
            ],
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.mainDarkGray,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSizes.smallDistance),
          child: Column(
            children: [
              Expanded(child: _buildMessageList()),
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildMessageInput(),
              ),
            ],
          ),
        ));
  }

  Widget _buildMessageList() {
    return StreamBuilder(
        stream: ChatManager.getMessages(
            widget.friendAccount.userId, _firebaseAuth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs
                .map((document) => _buildListItem(document))
                .toList(),
          );
        });
  }

  Widget _buildListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    bool isMessageSentByCurrentUser =
        data["senderId"] == _firebaseAuth.currentUser!.uid;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.smallDistance),
      child: Row(
        mainAxisAlignment: isMessageSentByCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Visibility(
              visible: !isMessageSentByCurrentUser,
              child: SizedBox(
                  height: 50,
                  width: 50,
                  child: CircleAvatar(
                      backgroundImage:
                          FileImage(File(widget.friendAccount.imageURL))))),
          Visibility(
              visible: !isMessageSentByCurrentUser,
              child: SizedBox(width: AppSizes.smallDistance)),
          Container(
            height: 70,
            width: 220,
            alignment: isMessageSentByCurrentUser
                ? Alignment.centerLeft
                : Alignment.centerRight,
            padding: const EdgeInsets.all(AppSizes.mediumDistance),
            decoration: BoxDecoration(
              color: isMessageSentByCurrentUser
                  ? AppColors.lightBlue
                  : AppColors.mediumBlue,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.borders),
                  topRight: Radius.circular(AppSizes.borders),
                  bottomLeft: isMessageSentByCurrentUser
                      ? Radius.circular(AppSizes.borders)
                      : Radius.zero,
                  bottomRight: isMessageSentByCurrentUser
                      ? Radius.zero
                      : Radius.circular(
                          AppSizes.borders,
                        )),
            ),
            child: Center(
              child: Text(
                data["message"],
                style: AppStyles.hintComponentStyle.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          Visibility(
              visible: isMessageSentByCurrentUser,
              child: SizedBox(width: AppSizes.smallDistance)),
          Visibility(
            visible: isMessageSentByCurrentUser,
            child: SizedBox(
                height: 50,
                width: 50,
                child: CircleAvatar(
                    backgroundImage:
                        FileImage(File(widget.currentUserImageUrl)))),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Expanded(
        child: TextFormField(
      controller: _messageController,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.fromLTRB(
          AppSizes.mediumDistance,
          AppSizes.smallDistance,
          AppSizes.mediumDistance,
          AppSizes.smallDistance,
        ),
        hintText: "Type a message",
        hintStyle: AppStyles.bodyStyle.copyWith(color: AppColors.mediumGray),
        fillColor: AppColors.componentGray,
        filled: true,
        suffixIcon:
            IconButton(icon: Icon(Icons.send_outlined), onPressed: sendMessage),
        suffixIconColor: AppColors.mainDarkGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borders),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.componentGray),
          borderRadius: BorderRadius.circular(AppSizes.borders),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.componentGray),
          borderRadius: BorderRadius.circular(AppSizes.borders),
        ),
      ),
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.text,
    ));
  }
}
