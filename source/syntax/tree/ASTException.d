module syntax.tree.ASTException;

import std.exception;

class ASTException : Exception { mixin basicExceptionCtors; }
