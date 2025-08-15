import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/data/models/weeklyAnnouncement.dart';
import 'package:eschool/utils/constants.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class WeeklySliderContainer extends StatefulWidget {
  final List<Weeklyannouncement> sliders;
  const WeeklySliderContainer({Key? key, required this.sliders}) : super(key: key);

  @override
  State<WeeklySliderContainer> createState() => _WeeklySliderContainerState();
}

class _WeeklySliderContainerState extends State<WeeklySliderContainer> {
  int _currentSliderIndex = 0;

  Widget _buildDotIndicator(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      child: CircleAvatar(
        backgroundColor: index == _currentSliderIndex
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
        radius: 3.0,
      ),
    );
  }

  Widget _buildSliderIndicator() {
    return SizedBox(
      height: 6,
      child: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.sliders.length, (index) => index)
              .map((index) => _buildDotIndicator(index))
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.sliders.isEmpty
        ? const SizedBox.shrink()
        : Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height *
                    Utils.appBarBiggerHeightPercentage,
                child: CarouselSlider(
                  items: widget.sliders
                      .map(
                        (slider) => InkWell(
                          onTap: () async {
                            try {
                              final canLaunchLink = await canLaunchUrl(
                                  Uri.parse("https://${context.read<AuthCubit>().getSchoolDetails().domain}.edunotepro.net/"));
                              if (canLaunchLink) {
                                launchUrl(Uri.parse("https://${context.read<AuthCubit>().getSchoolDetails().domain}.edunotepro.net/"));
                              }
                            } catch (e) {}
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * (0.85),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image: CachedNetworkImageProvider(
                                    "$baseUrl/storage/${slider.cover}"),
                              ),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  options: CarouselOptions(
                    viewportFraction: 1.0,
                    autoPlay: true,
                    autoPlayInterval: changeSliderDuration,
                    onPageChanged: (index, _) {
                      setState(() {
                        _currentSliderIndex = index;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              _buildSliderIndicator(),
            ],
          );
  }
}
