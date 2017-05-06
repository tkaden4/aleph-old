module syntax.tree.ImportNode;

import syntax.tree.StatementNode;

import core.stdc.string;

import std.array;
import std.string;
import std.conv;

public class ImportNode : StatementNode {
public:
    this(in string _path)
    {
        this.path = _path.replace(".", "/") ~ ".al";
    }
    const(string) path; 
};
