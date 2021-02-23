import 'package:flutter/material.dart';

class MyFadeInAndSlideAnimation extends StatefulWidget {
  final Widget child;

  const MyFadeInAndSlideAnimation({Key key, this.child}) : super(key: key);

  @override
  _MyFadeInAndSlideAnimationState createState() =>
      _MyFadeInAndSlideAnimationState();
}

class _MyFadeInAndSlideAnimationState extends State<MyFadeInAndSlideAnimation>
    with TickerProviderStateMixin {
  AnimationController _controller, controllerSlider;
  Animation _animation, animationSlider;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);


    controllerSlider = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    animationSlider = Tween(
        begin: Offset(0, 0),
        end: Offset(0, 1)
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    controllerSlider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward();
    controllerSlider.forward();
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(position: animationSlider, child: widget.child,),
    );
  }
}
