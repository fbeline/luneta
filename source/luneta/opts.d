module luneta.opts;

static int height;  /// window height
static bool colorSupport = true; /// colorized result
static string query; ///default query to be used upon startup

/// initialize application options
void initialize(int _height, bool _colorSupport, string _query) {
    height = _height;
    colorSupport = _colorSupport;
    query = _query;
}

@("On application options initialization")
unittest {
    assert(height == 0);
    initialize(10, false, "");
    assert(height == 10);
    assert(!colorSupport);
}