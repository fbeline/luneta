module luneta.opts;

static int height;  /// window height
static bool colorSupport = true; /// colorized result

/// initialize application options
void initialize(int _height, bool _colorSupport) {
    height = _height;
    colorSupport = _colorSupport;
}

@("On application options initialization")
unittest {
    assert(height == 0);
    initialize(10, false);
    assert(height == 10);
    assert(!colorSupport);
}