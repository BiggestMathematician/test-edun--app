import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/notificationsCubit.dart';
import 'package:eschool/data/models/notificationModel.dart';
import 'package:eschool/data/repositories/notificationRepository.dart';
import 'package:eschool/ui/screens/home/widgets/readMoreTextContainer.dart';
import 'package:eschool/ui/widgets/customAppbar.dart';
import 'package:eschool/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool/ui/widgets/customTextContainer.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/noDataContainer.dart';
import 'package:eschool/utils/api.dart';
import 'package:eschool/utils/constants.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  static Widget routeInstance() {
    return BlocProvider(
      create: (context) => NotificationsCubit(NotificationRepository()),
      child: NotificationsScreen(),
    );
  }

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<NotificationsModel>> databaseNotifications;
  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('fr', timeago.FrMessages());
    //Future.delayed(Duration.zero, () {
    //  context.read<NotificationsCubit>().fetchNotifications();
    //});
    databaseNotifications = fetchNotificationFromDatabase();
  }

  // Récupérer les notifications depuis la base de données
  Future<List<NotificationsModel>> fetchNotificationFromDatabase() async {
    try {
      final response = await Api.post(
          url: Api.getNotificationFromDatabase,
          useAuthToken: true,
          body: {
            "user_id": context.read<AuthCubit>().isParent()
                ? context.read<AuthCubit>().getParentDetails().id
                : context.read<AuthCubit>().getStudentDetails().id
          });

      // Vérifiez si la réponse est déjà une liste
      List<dynamic> jsonList = response['data'] is List
          ? response['data']
          : json.decode(response['data']);

      return jsonList.map((json) => NotificationsModel.fromJson(json)).toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<List<NotificationsModel>>(
            future:
                databaseNotifications, // ta fonction qui récupère les notifications
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Si les données sont en train de charger, on affiche un indicateur de progression
                return Center(
                  child: CustomCircularProgressIndicator(
                    indicatorColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              } else if (snapshot.hasError) {
                // En cas d'erreur, on affiche un message d'erreur
                return Center(
                  child: ErrorContainer(
                    errorMessageCode: snapshot.error.toString(),
                    onTapRetry: () {
                      // On peut redemander les notifications en cas d'erreur
                      databaseNotifications = fetchNotificationFromDatabase();
                    },
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                // Si il n'y a pas de notifications ou que la liste est vide
                return const Align(
                  alignment: Alignment.center,
                  child: NoDataContainer(titleKey: noNotificationsKey),
                );
              } else {
                // Si on a des données, on construit la liste
                final notifications =
                    snapshot.data!; // Les notifications récupérées
                return Align(
                  alignment: Alignment.topCenter,
                  child: RefreshIndicator(
                    displacement: Utils.getScrollViewTopPadding(
                        context: context,
                        appBarHeightPercentage:
                            Utils.appBarSmallerHeightPercentage),
                    onRefresh: () async {
                      setState(() {
                        databaseNotifications = fetchNotificationFromDatabase();
                      });
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.only(
                        bottom: 25,
                        left: MediaQuery.of(context).size.width *
                            (Utils.screenContentHorizontalPaddingInPercentage),
                        right: MediaQuery.of(context).size.width *
                            (Utils.screenContentHorizontalPaddingInPercentage),
                        top: Utils.getScrollViewTopPadding(
                          context: context,
                          appBarHeightPercentage:
                              Utils.appBarSmallerHeightPercentage,
                        ),
                      ),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return Container(
                          margin: EdgeInsets.only(
                              bottom: appContentHorizontalPadding,),
                          padding: EdgeInsets.all(appContentHorizontalPadding),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context).colorScheme.surface,
                            border: Border.all(
                                color: Theme.of(context).colorScheme.tertiary),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  notification.image == null
                                      ? Container(
                                          height: 80,
                                          width: 80,
                                          decoration: BoxDecoration(
                                            image: const DecorationImage(
                                              fit: BoxFit.cover,
                                              image: AssetImage(
                                                  'assets/images/no_image_available.jpg'), // Remplacer par ton chemin d'image
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        )
                                      : Container(
                                          height: 80,
                                          width: 80,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: CachedNetworkImageProvider(
                                                notification.image,
                                              ),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        ReadMoreTextContainer(
                                          text:
                                              notification.title ?? "-",
                                          trimLines: 1,
                                          //overflow: TextOverflow.ellipsis,
                                          textStyle: const TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        ReadMoreTextContainer(
                                          text: notification.message ??
                                              "-",
                                          trimLines: 3,
                                          textStyle: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            fontSize: 14,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              CustomTextContainer(
                                textKey: timeago.format(
                                    notification.createdAt!,
                                    locale: "fr"),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              ),
                            ],
                          ),
                        )
                        /*Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 15.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          width: MediaQuery.of(context).size.width * (0.85),
                          child: LayoutBuilder(
                            builder: (context, boxConstraints) {
                              return Row(
                                children: [
                                  SizedBox(
                                    width: boxConstraints.maxWidth *
                                        (notification.image != null
                                            ? 1.0
                                            : 0.725),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notification.title ?? "-",
                                          style: TextStyle(
                                            height: 1.2,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            fontSize: 15.0,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          notification.message ?? "-",
                                          style: TextStyle(
                                            height: 1.2,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 11.5,
                                          ),
                                        ),
                                        CustomTextContainer(
                                          textKey: timeago.format(
                                              notification.createdAt!,
                                              locale: "fr"),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 12.0,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  notification.image != null
                                      ? const Spacer()
                                      : const SizedBox(),
                                  notification.image != null
                                      ? Container(
                                          width:
                                              boxConstraints.maxWidth * (0.25),
                                          height:
                                              boxConstraints.maxWidth * (0.25),
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: CachedNetworkImageProvider(
                                                notification.image,
                                              ),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        )
                                      : const SizedBox(),
                                ],
                              );
                            },
                          ),
                        )*/;
                      },
                    ),
                  ),
                );
              }
            },
          ),
          const Align(
            alignment: Alignment.topCenter,
            child: CustomAppBar(title: notificationsKey),
          ),
        ],
      ),
    );
  }
}
