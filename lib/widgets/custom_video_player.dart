import 'package:flutter/material.dart';
import 'package:social/helpers/app_color.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

enum VideoSourceType { asset, network }

enum VideoPlayerMode {
  standard, // Normal video player with controls
  reels, // TikTok/Reels style with overlay actions
  feed, // Feed içinde küçük preview
}

class CustomVideoPlayer extends StatefulWidget {
  final String url;
  final VideoSourceType sourceType;
  final VideoPlayerMode mode;
  final bool autoPlay;
  final bool loop;
  final bool startMuted;
  final double? aspectRatio;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final Color primaryColor;

  // Callbacks
  final Function(Duration)? onPositionChanged;
  final Function()? onVideoEnd;
  final Function(bool)? onPlayPause;
  final Function(bool)? onMuteChanged;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  // Reels mode specific
  final Widget? reelsActionButtons;
  final Widget? reelsBottomInfo;
  final Widget? reelsTopInfo;

  // Standard mode specific
  final bool showControls;
  final bool enableDoubleTapToSeek;
  final int doubleTapSeekSeconds;

  // Visibility
  final bool enableVisibilityDetection;
  final bool pauseOnInvisible;
  final double visibilityThreshold;

  const CustomVideoPlayer({
    super.key,
    required this.url,
    this.sourceType = VideoSourceType.network,
    this.mode = VideoPlayerMode.standard,
    this.autoPlay = true,
    this.loop = true,
    this.startMuted = false,
    this.aspectRatio,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.primaryColor = AppColors.primary,
    this.onPositionChanged,
    this.onVideoEnd,
    this.onPlayPause,
    this.onMuteChanged,
    this.onTap,
    this.onDoubleTap,
    // Reels specific
    this.reelsActionButtons,
    this.reelsBottomInfo,
    this.reelsTopInfo,
    // Standard specific
    this.showControls = true,
    this.enableDoubleTapToSeek = true,
    this.doubleTapSeekSeconds = 10,
    // Visibility
    this.enableVisibilityDetection = true,
    this.pauseOnInvisible = true,
    this.visibilityThreshold = 0.5,
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  VideoPlayerController? _controller;
  late AnimationController _controlsAnimationController;
  late AnimationController _seekAnimationController;
  late Animation<double> _controlsAnimation;
  late Animation<double> _seekAnimation;

  bool _isMuted = false;
  bool _showControls = false;
  bool _isBuffering = false;
  bool _isError = false;
  bool _isInitialized = false;
  bool _wasPlayingBeforeBackground = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // Double tap seek
  bool _showSeekIndicator = false;
  bool _isSeekingForward = true;
  String _seekText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isMuted = widget.startMuted;
    _initAnimations();
    _initializeVideo();
  }

  void _initAnimations() {
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _seekAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _controlsAnimation = CurvedAnimation(
      parent: _controlsAnimationController,
      curve: Curves.easeInOut,
    );

    _seekAnimation = CurvedAnimation(
      parent: _seekAnimationController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (_controller == null || !_isInitialized) return;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _wasPlayingBeforeBackground = _controller!.value.isPlaying;
        if (_controller!.value.isPlaying) {
          _controller!.pause();
        }
        break;
      case AppLifecycleState.resumed:
        if (_wasPlayingBeforeBackground && widget.autoPlay) {
          _controller!.play();
        }
        break;
      default:
        break;
    }
  }

  void _initializeVideo() {
    try {
      if (widget.sourceType == VideoSourceType.network) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      } else {
        _controller = VideoPlayerController.asset(widget.url);
      }

      _controller!
          .initialize()
          .then((_) {
            if (!mounted) return;

            setState(() {
              _isInitialized = true;
              _duration = _controller!.value.duration;
            });

            _controller!.setLooping(widget.loop);
            _controller!.setVolume(_isMuted ? 0.0 : 1.0);

            if (widget.autoPlay && mounted) {
              _controller!.play();
            }

            _controller!.addListener(_videoListener);
          })
          .catchError((error) {
            if (!mounted) return;
            setState(() {
              _isError = true;
            });
          });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isError = true;
      });
    }
  }

  void _videoListener() {
    if (!mounted || _controller == null) return;

    final value = _controller!.value;

    setState(() {
      _position = value.position;
      _isBuffering = value.isBuffering;
    });

    widget.onPositionChanged?.call(_position);

    if (_position >= _duration &&
        _duration > Duration.zero &&
        !value.isPlaying) {
      widget.onVideoEnd?.call();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.removeListener(_videoListener);
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    _controlsAnimationController.dispose();
    _seekAnimationController.dispose();
    super.dispose();
  }

  // Public methods for external control
  void play() {
    if (_controller?.value.isInitialized == true) {
      _controller!.play();
    }
  }

  void pause() {
    if (_controller?.value.isInitialized == true) {
      _controller!.pause();
    }
  }

  void togglePlayPause() {
    if (_controller == null || !_isInitialized) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });

    widget.onPlayPause?.call(_controller!.value.isPlaying);
  }

  void toggleMute() {
    if (_controller == null || !_isInitialized) return;

    setState(() {
      _isMuted = !_isMuted;
      _controller!.setVolume(_isMuted ? 0.0 : 1.0);
    });

    widget.onMuteChanged?.call(_isMuted);
  }

  void seekTo(Duration position) {
    if (_controller == null || !_isInitialized) return;
    _controller!.seekTo(position);
  }

  // Getters
  bool get isPlaying => _controller?.value.isPlaying ?? false;
  bool get isMuted => _isMuted;
  bool get isInitialized => _isInitialized;
  Duration get position => _position;
  Duration get duration => _duration;

  void _onTap() {
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }

    switch (widget.mode) {
      case VideoPlayerMode.reels:
        togglePlayPause();
        break;
      case VideoPlayerMode.standard:
        _toggleControls();
        break;
      case VideoPlayerMode.feed:
        togglePlayPause();
        break;
    }
  }

  void _onDoubleTap(TapDownDetails details) {
    if (widget.onDoubleTap != null) {
      widget.onDoubleTap!();
      return;
    }

    if (!widget.enableDoubleTapToSeek || widget.mode == VideoPlayerMode.feed) {
      return;
    }

    _handleDoubleTapSeek(details);
  }

  void _handleDoubleTapSeek(TapDownDetails details) {
    if (_controller == null || !_isInitialized) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final tapPosition = details.localPosition;
    final screenWidth = renderBox.size.width;
    final isLeftSide = tapPosition.dx < screenWidth / 2;

    Duration newPosition;
    if (isLeftSide) {
      newPosition = _position - Duration(seconds: widget.doubleTapSeekSeconds);
      if (newPosition < Duration.zero) newPosition = Duration.zero;
      _isSeekingForward = false;
      _seekText = '-${widget.doubleTapSeekSeconds}s';
    } else {
      newPosition = _position + Duration(seconds: widget.doubleTapSeekSeconds);
      if (newPosition > _duration) newPosition = _duration;
      _isSeekingForward = true;
      _seekText = '+${widget.doubleTapSeekSeconds}s';
    }

    seekTo(newPosition);
    _showSeekAnimation();
  }

  void _toggleControls() {
    if (widget.mode == VideoPlayerMode.reels ||
        widget.mode == VideoPlayerMode.feed) {
      return;
    }

    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _controlsAnimationController.forward();
      _hideControlsAfterDelay();
    } else {
      _controlsAnimationController.reverse();
    }
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showControls) {
        setState(() {
          _showControls = false;
        });
        _controlsAnimationController.reverse();
      }
    });
  }

  void _showSeekAnimation() {
    setState(() {
      _showSeekIndicator = true;
    });

    _seekAnimationController.forward().then((_) {
      if (mounted) {
        _seekAnimationController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _showSeekIndicator = false;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget videoPlayer = _buildVideoPlayer();

    // Wrap with visibility detector if enabled
    if (widget.enableVisibilityDetection) {
      videoPlayer = VisibilityDetector(
        key: Key('video_${widget.url}'),
        onVisibilityChanged: (visibilityInfo) {
          if (!mounted || _controller == null || !_isInitialized) return;

          if (visibilityInfo.visibleFraction > widget.visibilityThreshold) {
            if (!_controller!.value.isPlaying && widget.autoPlay) {
              _controller!.play();
            }
          } else {
            if (_controller!.value.isPlaying && widget.pauseOnInvisible) {
              _controller!.pause();
            }
          }
        },
        child: videoPlayer,
      );
    }

    // Wrap with padding if provided
    if (widget.padding != null) {
      videoPlayer = Padding(padding: widget.padding!, child: videoPlayer);
    }

    return videoPlayer;
  }

  Widget _buildVideoPlayer() {
    if (_isError) {
      return _buildErrorState();
    }

    if (!_isInitialized) {
      return _buildLoadingState();
    }

    return _buildVideoContainer();
  }

  Widget _buildVideoContainer() {
    return AspectRatio(
      aspectRatio: _getAspectRatio(),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: widget.borderRadius,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video Player
            GestureDetector(
              onTap: _onTap,
              onDoubleTapDown: _onDoubleTap,
              child: VideoPlayer(_controller!),
            ),

            // Mode specific overlays
            ..._buildModeSpecificOverlays(),

            // Common overlays
            ..._buildCommonOverlays(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildModeSpecificOverlays() {
    switch (widget.mode) {
      case VideoPlayerMode.reels:
        return _buildReelsOverlays();
      case VideoPlayerMode.standard:
        return _buildStandardOverlays();
      case VideoPlayerMode.feed:
        return _buildFeedOverlays();
    }
  }

  List<Widget> _buildReelsOverlays() {
    return [
      // Top info
      if (widget.reelsTopInfo != null)
        Positioned(top: 16, left: 16, right: 16, child: widget.reelsTopInfo!),

      // Right action buttons
      if (widget.reelsActionButtons != null)
        Positioned(right: 12, bottom: 150, child: widget.reelsActionButtons!),

      // Bottom info
      if (widget.reelsBottomInfo != null)
        Positioned(
          left: 16,
          right: 80,
          bottom: 32,
          child: widget.reelsBottomInfo!,
        ),
    ];
  }

  List<Widget> _buildStandardOverlays() {
    return [
      // Controls overlay
      if (_showControls && widget.showControls)
        AnimatedBuilder(
          animation: _controlsAnimation,
          builder:
              (context, child) => Opacity(
                opacity: _controlsAnimation.value,
                child: _buildStandardControls(),
              ),
        ),

      // Simple progress bar (when controls hidden)
      if (!_showControls && _duration.inMilliseconds > 0)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: LinearProgressIndicator(
            value: _position.inMilliseconds / _duration.inMilliseconds,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(widget.primaryColor),
            minHeight: 2,
          ),
        ),
    ];
  }

  List<Widget> _buildFeedOverlays() {
    return [
      // Play/pause overlay for feed
      if (!isPlaying)
        Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: togglePlayPause,
              iconSize: 32,
              icon: const Icon(Icons.play_arrow, color: Colors.white),
            ),
          ),
        ),
    ];
  }

  List<Widget> _buildCommonOverlays() {
    return [
      // Seek indicator
      if (_showSeekIndicator) _buildSeekIndicator(),

      // Buffering indicator
      if (_isBuffering) _buildBufferingIndicator(),
    ];
  }

  Widget _buildStandardControls() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        children: [
          // Top controls
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Spacer(),
                IconButton(
                  onPressed: toggleMute,
                  icon: Icon(
                    _isMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Center play/pause
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: togglePlayPause,
                iconSize: 48,
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const Spacer(),

          // Bottom controls
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Progress bar
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: widget.primaryColor,
                    inactiveTrackColor: Colors.white.withOpacity(0.3),
                    thumbColor: widget.primaryColor,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value:
                        _duration.inMilliseconds > 0
                            ? _position.inMilliseconds /
                                _duration.inMilliseconds
                            : 0.0,
                    onChanged: (value) {
                      final newPosition = Duration(
                        milliseconds:
                            (_duration.inMilliseconds * value).round(),
                      );
                      seekTo(newPosition);
                    },
                  ),
                ),

                // Time indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeekIndicator() {
    return AnimatedBuilder(
      animation: _seekAnimation,
      builder: (context, child) {
        return Center(
          child: Transform.scale(
            scale: _seekAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isSeekingForward ? Icons.fast_forward : Icons.fast_rewind,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _seekText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBufferingIndicator() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(widget.primaryColor),
                strokeWidth: 2,
              ),
            ),
            if (widget.mode != VideoPlayerMode.feed) ...[
              const SizedBox(height: 8),
              const Text(
                'Yükleniyor...',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: widget.borderRadius,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white70, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Video yüklenemedi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.mode != VideoPlayerMode.feed) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isError = false;
                    _isInitialized = false;
                  });
                  _controller?.dispose();
                  _controller = null;
                  _initializeVideo();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Yeniden Dene'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: widget.borderRadius,
      ),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(widget.primaryColor),
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  double _getAspectRatio() {
    if (widget.aspectRatio != null) return widget.aspectRatio!;

    switch (widget.mode) {
      case VideoPlayerMode.reels:
        return 9 / 16;
      case VideoPlayerMode.standard:
      case VideoPlayerMode.feed:
        return _controller?.value.aspectRatio ?? 16 / 9;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
