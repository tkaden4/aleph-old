module AlephException;

import std.exception;

public class AlephException : Exception {
    mixin basicExceptionCtors;
};
