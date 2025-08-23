import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

enum VideoSourceType { asset, network }

class CustomVideoPlayer extends StatefulWidget {
  final String url;
  final VideoSourceType sourceType;
  final bool autoPlay;
  final bool loop;
  final bool showControls;
  final bool allowFullscreen;
  final double? aspectRatio;
  final Function(Duration)? onPositionChanged;
  final Function()? onVideoEnd;
  final Function(bool)? onPlayPause;
  final Color primaryColor;
  final bool enableDoubleTapToSeek;
  final int doubleTapSeekSeconds;

  const CustomVideoPlayer({
    super.key,
    required this.url,
    this.sourceType = VideoSourceType.network,
    this.autoPlay = true,
    this.loop = true,
    this.showControls = true,
    this.allowFullscreen = true,
    this.aspectRatio,
    this.onPositionChanged,
    this.onVideoEnd,
    this.onPlayPause,
    this.primaryColor = Colors.red,
    this.enableDoubleTapToSeek = true,
    this.doubleTapSeekSeconds = 10,
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer>
    with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  late AnimationController _controlsAnimationController;
  late AnimationController _seekAnimationController;
  late Animation<double> _controlsAnimation;
  late Animation<double> _seekAnimation;

  bool _isMuted = true;
  bool _showControls = false;
  bool _isFullscreen = false;
  bool _isBuffering = false;
  bool _isError = false;
  String? _errorMessage;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // Double tap seek
  bool _showSeekIndicator = false;
  bool _isSeekingForward = true;
  String _seekText = '';

  @override
  void initState() {
    super.initState();

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

    _initializeVideo();
  }

  void _initializeVideo() {
    if (widget.sourceType == VideoSourceType.network) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    } else {
      _controller = VideoPlayerController.asset(widget.url);
    }

    _controller
        .initialize()
        .then((_) {
          _controller.setLooping(widget.loop);
          _controller.setVolume(_isMuted ? 0.0 : 1.0);

          if (widget.autoPlay) {
            _controller.play();
          }

          // Duration listener
          setState(() {
            _duration = _controller.value.duration;
          });

          // Position listener
          _controller.addListener(_videoListener);
        })
        .catchError((error) {
          setState(() {
            _isError = true;
            _errorMessage = error.toString();
          });
        });
  }

  void _videoListener() {
    if (!mounted) return;

    setState(() {
      _position = _controller.value.position;
      _isBuffering = _controller.value.isBuffering;
    });

    widget.onPositionChanged?.call(_position);

    // Video ended
    if (_position >= _duration && _duration > Duration.zero) {
      widget.onVideoEnd?.call();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    _controlsAnimationController.dispose();
    _seekAnimationController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
    widget.onPlayPause?.call(_controller.value.isPlaying);
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _toggleControls() {
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

  void _seek(Duration position) {
    _controller.seekTo(position);
  }

  void _onDoubleTap(TapDownDetails details) {
    if (!widget.enableDoubleTapToSeek) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final tapPosition = details.localPosition;
    final screenWidth = renderBox.size.width;
    final isLeftSide = tapPosition.dx < screenWidth / 2;

    Duration newPosition;
    if (isLeftSide) {
      // Seek backward
      newPosition = _position - Duration(seconds: widget.doubleTapSeekSeconds);
      if (newPosition < Duration.zero) newPosition = Duration.zero;
      _isSeekingForward = false;
      _seekText = '-${widget.doubleTapSeekSeconds}s';
    } else {
      // Seek forward
      newPosition = _position + Duration(seconds: widget.doubleTapSeekSeconds);
      if (newPosition > _duration) newPosition = _duration;
      _isSeekingForward = true;
      _seekText = '+${widget.doubleTapSeekSeconds}s';
    }

    _seek(newPosition);
    _showSeekAnimation();
  }

  void _showSeekAnimation() {
    setState(() {
      _showSeekIndicator = true;
    });

    _seekAnimationController.forward().then((_) {
      _seekAnimationController.reverse().then((_) {
        setState(() {
          _showSeekIndicator = false;
        });
      });
    });
  }

  void _toggleFullscreen() {
    if (_isFullscreen) {
      Navigator.pop(context);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => _FullscreenVideoPlayer(
                controller: _controller,
                primaryColor: widget.primaryColor,
                onClose: () => Navigator.pop(context),
              ),
        ),
      );
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

  Widget _buildError() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.white70, size: 48),
            const SizedBox(height: 16),
            Text(
              'Video yüklenemedi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isError = false;
                  _errorMessage = null;
                });
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
        ),
      ),
    );
  }

  Widget _buildControls() {
    if (!widget.showControls) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controlsAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _controlsAnimation.value,
          child: Container(
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
                      if (widget.allowFullscreen)
                        IconButton(
                          onPressed: _toggleFullscreen,
                          icon: const Icon(
                            Icons.fullscreen,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      const Spacer(),
                      IconButton(
                        onPressed: _toggleMute,
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
                      onPressed: _togglePlayPause,
                      iconSize: 48,
                      icon: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
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
                            _seek(newPosition);
                          },
                        ),
                      ),

                      // Time indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatDuration(_duration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeekIndicator() {
    if (!_showSeekIndicator) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _seekAnimation,
      builder: (context, child) {
        return Center(
          child: Transform.scale(
            scale: _seekAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _seekText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
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
    if (!_isBuffering) return const SizedBox.shrink();

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
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(widget.primaryColor),
            ),
            const SizedBox(height: 8),
            const Text(
              'Yükleniyor...',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return _buildError();
    }

    return VisibilityDetector(
      key: Key(widget.url),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction > 0.5) {
          if (!_controller.value.isPlaying && widget.autoPlay) {
            _controller.play();
          }
        } else {
          if (_controller.value.isPlaying) {
            _controller.pause();
          }
        }
      },
      child:
          _controller.value.isInitialized
              ? AspectRatio(
                aspectRatio:
                    widget.aspectRatio ?? _controller.value.aspectRatio,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Video Player
                        GestureDetector(
                          onTap: _toggleControls,
                          onDoubleTapDown: _onDoubleTap,
                          child: VideoPlayer(_controller),
                        ),

                        // Controls overlay
                        if (_showControls) _buildControls(),

                        // Seek indicator
                        _buildSeekIndicator(),

                        // Buffering indicator
                        _buildBufferingIndicator(),

                        // Simple progress bar (when controls hidden)
                        if (!_showControls && _duration.inMilliseconds > 0)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: LinearProgressIndicator(
                              value:
                                  _position.inMilliseconds /
                                  _duration.inMilliseconds,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.primaryColor,
                              ),
                              minHeight: 2,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              )
              : Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.primaryColor,
                    ),
                  ),
                ),
              ),
    );
  }
}

// Fullscreen Video Player Widget
class _FullscreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final Color primaryColor;
  final VoidCallback onClose;

  const _FullscreenVideoPlayer({
    required this.controller,
    required this.primaryColor,
    required this.onClose,
  });

  @override
  State<_FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<_FullscreenVideoPlayer>
    with TickerProviderStateMixin {
  late AnimationController _controlsAnimationController;
  late Animation<double> _controlsAnimation;

  bool _showControls = true;
  bool _isMuted = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();

    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _controlsAnimation = CurvedAnimation(
      parent: _controlsAnimationController,
      curve: Curves.easeInOut,
    );

    _controlsAnimationController.forward();
    _hideControlsAfterDelay();

    widget.controller.addListener(_videoListener);
    _duration = widget.controller.value.duration;
    _isMuted = widget.controller.value.volume == 0.0;
  }

  void _videoListener() {
    if (!mounted) return;
    setState(() {
      _position = widget.controller.value.position;
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_videoListener);
    _controlsAnimationController.dispose();
    super.dispose();
  }

  void _toggleControls() {
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

  void _togglePlayPause() {
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      widget.controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _seek(Duration position) {
    widget.controller.seekTo(position);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Video Player - Full screen
            Center(
              child: AspectRatio(
                aspectRatio: widget.controller.value.aspectRatio,
                child: GestureDetector(
                  onTap: _toggleControls,
                  child: VideoPlayer(widget.controller),
                ),
              ),
            ),

            // Controls Overlay
            if (_showControls)
              AnimatedBuilder(
                animation: _controlsAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _controlsAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                            Colors.transparent,
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
                                IconButton(
                                  onPressed: widget.onClose,
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: _toggleMute,
                                  icon: Icon(
                                    _isMuted
                                        ? Icons.volume_off
                                        : Icons.volume_up,
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
                                onPressed: _togglePlayPause,
                                iconSize: 56,
                                icon: Icon(
                                  widget.controller.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
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
                                    inactiveTrackColor: Colors.white
                                        .withOpacity(0.3),
                                    thumbColor: widget.primaryColor,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 8,
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
                                            (_duration.inMilliseconds * value)
                                                .round(),
                                      );
                                      _seek(newPosition);
                                    },
                                  ),
                                ),

                                // Time indicators
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(_position),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      _formatDuration(_duration),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
