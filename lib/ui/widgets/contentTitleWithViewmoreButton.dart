import 'package:eschool/ui/widgets/customTextContainer.dart';
import 'package:eschool/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContentTitleWithViewMoreButton extends StatelessWidget {
  final String contentTitleKey;
  final bool? showViewMoreButton;
  final Function? viewMoreOnTap;
  const ContentTitleWithViewMoreButton(
      {super.key,
      required this.contentTitleKey,
      this.showViewMoreButton,
      this.viewMoreOnTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
      child: Row(
        children: [
          CustomTextContainer(
            textKey: contentTitleKey,
            style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          (showViewMoreButton ?? false)
              ? GestureDetector(
                  onTap: () {
                    viewMoreOnTap?.call();
                  },
                  child: Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.transparent)),
                      child: Row(
                        children: [
                          CustomTextContainer(
                            textKey: "",
                            style: TextStyle(
                                fontSize: 12.0,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.76)),
                          ),
                          const SizedBox(
                            width: 2.5,
                          ),
                          Icon( CupertinoIcons.arrow_right,
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.76),
                          )
                        ],
                      )),
                )
              : const SizedBox()
        ],
      ),
    );
  }
}
