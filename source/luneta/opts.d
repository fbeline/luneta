module luneta.opts;

static int height = 22;  /// window height

/// initialize application options
void initialize(int _height) {
    if (_height > 0)
        height = _height;
}