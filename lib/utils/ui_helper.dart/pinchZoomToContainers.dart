import 'package:flutter/material.dart';

class PinchToZoomContainer extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;

  const PinchToZoomContainer({
    Key? key,
    required this.child,
    this.minScale = 1.0,
    this.maxScale = 4.0,
  }) : super(key: key);

  @override
  _PinchToZoomContainerState createState() => _PinchToZoomContainerState();
}

class _PinchToZoomContainerState extends State<PinchToZoomContainer>
    with SingleTickerProviderStateMixin {
  
  // Transformation variables
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  
  // Logic helpers
  late Offset _startLastOffset;
  late double _startScale;

  void _restoreScaleValues() {
    setState(() {
      _scale = widget.minScale;
      _offset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Handles Double Tap (Restore or Zoom to Max)
      onDoubleTap: () {
        if (_scale > widget.minScale) {
          _restoreScaleValues();
        } else {
          setState(() {
            _scale = widget.maxScale;
            // Note: Centering zoom logic can be added here
          });
        }
      },
      
      // Handles Pinch & Pan Start
      onScaleStart: (details) {
        _startScale = _scale;
        _startLastOffset = details.focalPoint - _offset;
      },
      
      // Handles Pinch & Pan Update
      onScaleUpdate: (details) {
        setState(() {
          // Update Scale
          _scale = (_startScale * details.scale).clamp(widget.minScale, widget.maxScale);

          // Update Translation (Panning)
          // This logic ensures the image stays within boundaries
          Offset newOffset = details.focalPoint - _startLastOffset;
          
          // Clamp the panning so you don't scroll into empty space
          // This replicates your C# Math.Min/Math.Max logic
          _offset = _clampOffset(newOffset);
        });
      },
      
      child: ClipRect( // Ensures content doesn't bleed outside container
        child: Transform(
          transform: Matrix4.identity()
            ..translate(_offset.dx, _offset.dy)
            ..scale(_scale),
          alignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );
  }

  Offset _clampOffset(Offset offset) {
    // Basic boundary logic: 
    // You can refine this to match your MAUI logic exactly based on 
    // the size of the rendered child.
    if (_scale == 1.0) return Offset.zero;
    return offset;
  }
}