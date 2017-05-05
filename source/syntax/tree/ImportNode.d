module syntax.tree.ImportNode;

import syntax.tree.ASTNode;

import core.stdc.string;

import std.array;
import std.string;
import std.conv;

public class ImportNode : ASTNode {
public:
    this(string _path)
    {
        this.path = _path.replace(".", "/");
    }
private:
    string path; 
};
