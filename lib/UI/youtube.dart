import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void showYoutubePlayerFromUrl(BuildContext context, String youtubeUrl) {
  final videoId = YoutubePlayer.convertUrlToId(youtubeUrl);
  if (videoId == null) return;

  YoutubePlayerController controller = YoutubePlayerController(
    initialVideoId: videoId,
    flags: YoutubePlayerFlags(autoPlay: true),
  );

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: YoutubePlayer(
        controller: controller,
        showVideoProgressIndicator: true,
      ),
    ),
  );
}