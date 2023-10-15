import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';

void main() async{
  await JustAudioBackground.init(
      androidNotificationChannelId:"com.ryanheise.bg_demo.channel.audio",
      androidNotificationChannelName:"Audio playback",
      androidNotificationOngoing: true,

  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Just Audio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AudioPlayerScreen(),
    );
  }
}

class AudioPlayerScreen extends StatefulWidget {
  AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer _audioPlayer;
  final _playlisy = ConcatenatingAudioSource(children: [
    AudioSource.uri(Uri.parse('asset:///assets/audio/nature.mp3'),
        tag: MediaItem(
            id: '0',
            title: "nature sound",
            artist: "Public Domain",
            artUri: Uri.parse(
                'https://images.unsplash.com/photo-1433086966358-54859d0ed716'))),
    AudioSource.uri(
        Uri.parse(
            'http://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3'),
        tag: MediaItem(
            id: '0',
            title: "nature sound",
            artist: "Public Domain",
            artUri: Uri.parse(
                'https://unsplash.com/photos/a-woman-sitting-on-a-ledge-in-front-of-the-eiffel-tower-pXnaYS0Npug'))),
    AudioSource.uri(
        Uri.parse(
            'https://dts.podtrac.com/redirect.mp3/pdst.fm/e/chrt.fm/track/E2G895/pscrb.fm/rss/p/arttrk.com/p/PDPN1/aw.noxsolutions.com/launchpod/adswizz/2142/a038aebf5eb9f6309d9661ad77098454_2a78e475.mp3'),
        tag: MediaItem(
            id: '0',
            title: "nature sound",
            artist: "Public Domain",
            artUri: Uri.parse(
                'https://unsplash.com/photos/a-man-standing-in-front-of-a-wall-holding-a-skateboard-da_x3cCM48g'))),
  ]);

  Stream<PositionData> get _positionDataStrem =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _audioPlayer.positionStream,
          _audioPlayer.bufferedPositionStream,
          _audioPlayer.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
/*
    try {
      //  _audioPlayer = AudioPlayer()..setAsset('assets/audio/nature.mp3');
      //  _audioPlayer = AudioPlayer()..setUrl('http://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3');
      //_audioPlayer = AudioPlayer()..setUrl('https://dts.podtrac.com/redirect.mp3/pdst.fm/e/chrt.fm/track/E2G895/pscrb.fm/rss/p/arttrk.com/p/PDPN1/aw.noxsolutions.com/launchpod/adswizz/2142/a038aebf5eb9f6309d9661ad77098454_2a78e475.mp3?awCollectionId=2142&awEpisodeId=49179e97-c28c-4293-9bb0-184b2a78e475&adwNewID3=true');
      _audioPlayer = AudioPlayer()
        ..setUrl(
            'https://dts.podtrac.com/redirect.mp3/pdst.fm/e/chrt.fm/track/E2G895/pscrb.fm/rss/p/arttrk.com/p/PDPN1/aw.noxsolutions.com/launchpod/adswizz/2142/a038aebf5eb9f6309d9661ad77098454_2a78e475.mp3');
    } catch (e) {
      print('xxxxxxxx Error loading audio: $e');
    }*/
    _audioPlayer = AudioPlayer();
    _init();
  }

  Future<void> _init() async {
    await _audioPlayer.setLoopMode(LoopMode.all);
    await _audioPlayer.setAudioSource(_playlisy);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz))
          ],
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          height: double.infinity,
          width: double.infinity,
          //     color: Colors.red,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF144771), Color(0xFF071A2C)]),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<SequenceState?>(
                  stream: _audioPlayer.sequenceStateStream,
                  builder: (context, snapshot) {
                    final state = snapshot.data;
                    if (state?.sequence.isEmpty ?? true) {
                      return const SizedBox();
                    }
                    final metadata= state!.currentSource!.tag as MediaItem;
                    return MediaMetadata(imageUrl: metadata.artUri.toString(),
                    artist: metadata.artist?? '',
                    title: metadata.title,);
                  }),
              StreamBuilder(
                  stream: _positionDataStrem,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data;
                    return ProgressBar(
                      barHeight: 8,
                      baseBarColor: Colors.grey[600],
                      bufferedBarColor: Colors.grey,
                      progressBarColor: Colors.red,
                      thumbColor: Colors.red,
                      timeLabelTextStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      progress: positionData?.position ?? Duration.zero,
                      buffered: positionData?.buffrefPosition ?? Duration.zero,
                      total: positionData?.duration ?? Duration.zero,
                      onSeek: _audioPlayer.seek,
                    );
                  }),
              Controls(audioPlayer: _audioPlayer)
            ],
          ),
        ));
  }
}

class Controls extends StatelessWidget {
  const Controls({
    super.key,
    required this.audioPlayer,
  });

  final AudioPlayer audioPlayer;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(onPressed: audioPlayer.seekToPrevious,iconSize: 60,color: Colors.white, icon: Icon(Icons.skip_previous_rounded)),
        StreamBuilder(
            stream: audioPlayer.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final processingState = playerState?.processingState;
              final playing = playerState?.playing;
              if (!(playing ?? false)) {
                return IconButton(
                    onPressed: audioPlayer.play,
                    iconSize: 80,
                    color: Colors.white,
                    icon: Icon(Icons.play_arrow_rounded));
              } else if (processingState != ProcessingState.completed) {
                return IconButton(
                    onPressed: audioPlayer.pause,
                    iconSize: 80,
                    color: Colors.white,
                    icon: Icon(Icons.pause_rounded));
              }
              return Icon(
                Icons.play_arrow_rounded,
                size: 80,
                color: Colors.white,
              );
            }),
        IconButton(onPressed: audioPlayer.seekToNext,iconSize: 60,color: Colors.white, icon: Icon(Icons.skip_next_rounded)),

      ],
    );
  }
}

class PositionData {
  const PositionData(this.position, this.buffrefPosition, this.duration);

  final Duration position;
  final Duration buffrefPosition;
  final Duration duration;
}

class MediaMetadata extends StatelessWidget {
  const MediaMetadata(
      {super.key, required this.imageUrl, this.title, this.artist});

  final String imageUrl;

  final title;

  final artist;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(2, 4),
                blurRadius: 4,
              )
            ],
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: 300,
              width: 300,
              fit: BoxFit.cover,
            ),
          ),
        )
      ],
    );
  }
}
