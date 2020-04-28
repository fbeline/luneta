module luneta.opts;

static int height = 22;  /// window height
static bool colorSupport = true;

/// initialize application options
void initialize(int _height, bool _colorSupport) {
    if (_height > 0)
        height = _height;
    colorSupport = _colorSupport;
}

@("On application options initialization")
unittest {
    assert(height == 22);
    initialize(10, false);
    assert(height == 10);
    assert(!colorSupport);
}