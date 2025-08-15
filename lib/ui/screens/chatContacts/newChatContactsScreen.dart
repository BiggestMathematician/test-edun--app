import 'package:cached_network_image/cached_network_image.dart';
import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/chatUsersCubit.dart';
import 'package:eschool/data/models/chatUser.dart';
import 'package:eschool/data/models/chatUserRole.dart';
import 'package:eschool/ui/screens/chat/chatScreen.dart';
import 'package:eschool/ui/widgets/customAppbar.dart';
import 'package:eschool/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class NewChatContactsScreen extends StatefulWidget {
  const NewChatContactsScreen({super.key});

  static Widget routeInstance() {
    // final args = Get.arguments as Map<String, dynamic>;
    return BlocProvider(
      create: (_) => ChatUsersCubit(),
      child: NewChatContactsScreen(),
    );
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<NewChatContactsScreen> createState() => _NewChatContactsScreenState();
}

class _NewChatContactsScreenState extends State<NewChatContactsScreen> {
  final _scrollController = ScrollController();

  var _search = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fetchChatUsers();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.maxScrollExtent ==
        _scrollController.offset) {
      if (context.read<ChatUsersCubit>().state.searchStatus ==
          ChatUsersSearchStatus.success) {
        if (context.read<ChatUsersCubit>().hasMoreSearch) {
          context.read<ChatUsersCubit>().searchMoreChatUsers(
                role: ChatUserRole.teacher,
                search: _search,
              );
        }
      }
      if (context.read<ChatUsersCubit>().hasMore) {
        context.read<ChatUsersCubit>().fetchMoreChatUsers(
              role: ChatUserRole.teacher,
            );
      }
    }
  }

  void _fetchChatUsers() {
    context.read<ChatUsersCubit>().fetchChatUsers(
          role: ChatUserRole.teacher,
        );
  }

  void _searchChatUsers(String search) {
    context.read<ChatUsersCubit>().searchChatUsers(
          role: ChatUserRole.teacher,
          search: search,
        );
    setState(() => _search = search);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;

        Get.back<bool>(result: false);
      },
      child: Scaffold(
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            BlocBuilder<ChatUsersCubit, ChatUsersState>(
              builder: (context, state) {
                if (state.status == ChatUsersFetchStatus.failure) {
                  return Center(
                    child: ErrorContainer(
                      errorMessageCode: state.errorMessage!,
                      onTapRetry: _fetchChatUsers,
                    ),
                  );
                }

                if (state.status == ChatUsersFetchStatus.success) {
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          right: Utils.screenContentHorizontalPadding,
                          left: Utils.screenContentHorizontalPadding,
                          bottom: 12,
                          top: Utils.getScrollViewTopPadding(
                            context: context,
                            appBarHeightPercentage:
                                Utils.appBarSmallerHeightPercentage,
                          ),
                        ),
                        child: SearchAnchor(
                          builder: (context, controller) {
                            return SearchBar(
                              controller: controller,
                              onSubmitted: _searchChatUsers,
                              elevation: WidgetStatePropertyAll(0),
                              backgroundColor: WidgetStatePropertyAll(
                                Theme.of(context).scaffoldBackgroundColor,
                              ),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  side: BorderSide(
                                    width: 1,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.1),
                                  ),
                                ),
                              ),
                              hintText: Utils.getTranslatedLabel("search"),
                              padding: WidgetStatePropertyAll(
                                EdgeInsets.symmetric(horizontal: 16),
                              ),
                              trailing: [
                                IconButton(
                                  onPressed: () {
                                    if (state.searchStatus ==
                                        ChatUsersSearchStatus.initial) {
                                      _searchChatUsers(controller.text.trim());
                                    } else {
                                      controller.clear();
                                      context
                                          .read<ChatUsersCubit>()
                                          .clearSearch();
                                    }
                                  },
                                  icon: Icon(
                                    state.searchStatus ==
                                            ChatUsersSearchStatus.initial
                                        ? Icons.search_rounded
                                        : Icons.clear_rounded,
                                  ),
                                ),
                              ],
                            );
                          },
                          suggestionsBuilder: (_, __) => [SizedBox()],
                        ),
                      ),

                      ///
                      state.searchStatus == ChatUsersSearchStatus.loading
                          ? Center(
                              child: CustomCircularProgressIndicator(
                                indicatorColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            )
                          : Expanded(
                              child: ListView(
                                controller: _scrollController,
                                padding: EdgeInsets.only(
                                  right: Utils.screenContentHorizontalPadding,
                                  left: Utils.screenContentHorizontalPadding,
                                  bottom: Utils.screenContentHorizontalPadding *
                                      2.5,
                                ),
                                children: [
                                  if (state.searchStatus ==
                                          ChatUsersSearchStatus.success &&
                                      state.searchChatUsersResponse!.chatUsers
                                          .isEmpty) ...[
                                    Center(
                                      child: Text(
                                        Utils.getTranslatedLabel(
                                            "noSearchResults"),
                                        style: TextStyle(
                                          fontSize: 16,
                                          height: 1.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                  ...(state.searchStatus ==
                                              ChatUsersSearchStatus.success
                                          ? state.searchChatUsersResponse!
                                              .chatUsers
                                          : state.chatUsersResponse!.chatUsers)
                                      .map(
                                          (user) => _buildChatUserContact(user))
                                      .toList(),

                                  ///
                                  if (state.searchStatus ==
                                          ChatUsersSearchStatus.success
                                      ? state.loadMoreSearch
                                      : state.loadMore)
                                    Center(
                                      child: CustomCircularProgressIndicator(
                                        indicatorColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                    ],
                  );
                }

                return Center(
                  child: CustomCircularProgressIndicator(
                    indicatorColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),

            ///
            CustomAppBar(
              title: Utils.getTranslatedLabel("contacts"),
              onPressBackButton: () {
                Get.back<bool>(result: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatUserContact(ChatUser chatUser) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        Get.toNamed(
          Routes.chat,
          arguments: ChatScreen.buildArguments(
            receiverId: chatUser.id,
            image: chatUser.image,
            appbarSubtitle:
                chatUser.subjectTeachers.firstOrNull?.subjectWithName ?? "",
            teacherName: chatUser.fullName,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        margin: EdgeInsets.zero,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border(
            top: BorderSide.none,
            left: BorderSide.none,
            right: BorderSide.none,
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(.1),
            ),
          ),
        ),
        child: Row(
          children: [
            /// User profile image
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: colorScheme.tertiary,
              ),
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: chatUser.image,
                  fit: BoxFit.cover,
                  width: 48,
                  height: 48,
                ),
              ),
            ),
            const SizedBox(width: 16),

            ///
            Expanded(
              child: Text(
                chatUser.fullName,
                maxLines: 1,
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
