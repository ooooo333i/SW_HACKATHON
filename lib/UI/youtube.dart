import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void showYoutubePlayerFromUrl(BuildContext context, String youtubeUrl) {
  final videoId = YoutubePlayer.convertUrlToId(youtubeUrl);
  if (videoId == null) return;

  // YoutubePlayerController 초기화
  YoutubePlayerController controller = YoutubePlayerController(
    initialVideoId: videoId,
    flags: YoutubePlayerFlags(autoPlay: true),
  );

  // 다이얼로그에서 Controller를 dispose 하기 위한 처리
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: YoutubePlayer(
        controller: controller,
        showVideoProgressIndicator: true,
      ),
    ),
  ).then((_) {
    // 다이얼로그가 닫히면 controller를 dispose
    controller.dispose();
  });
}