module tools;

/**
    Tool for pretty output of variables and expressions.
   Compile time function. Converts a list of expressions into a block of code, wich outputs those exps.

   Using: mixin("&ltcomma separated list of expressions&gt".w);
   Parameters:
   expLst = list of expressions separated by commas
   Returns: string, that contains a block of code, which outputs the expression titles and values. It is and intended to be mixed
  into the source code.
*/
string w(string expLst) {
    import std.string: split, strip;
    import std.format: format;
    string[] asExp = expLst.split(",");
    string sRes = "import std.stdio: write, writeln;\n";
    foreach(s; asExp) {
        s = s.strip;
//        sRes ~= format(q{write("%s: "); write(typeid(typeof(%s))); write(" = "); writeln(%s);}, s, s, s) ~ "\n";
        sRes ~= format(q{write("%s: ", typeid(typeof(%s)), " = ", %s, "\n");}, s, s, s) ~ "\n";
    }

    return sRes;
}

unittest {
    int i = 1;
    int j = 2;
    int* p = &j;
    assert("i, *p".w == `import std.stdio: write, writeln;
write("i: ", typeid(typeof(i)), " = ", i, "\n");
write("*p: ", typeid(typeof(*p)), " = ", *p, "\n");
`
    );

    assert("i+(*p)".w, `import std.stdio: write, writeln;
write("i+(*p): ", typeid(typeof(i+(*p)), " = ", i+(*p), "\n");`
    );
}

///
unittest {
    import tools: w;
    string s = "Purpose of life";
    int k = 42;
    int* p = &k;

/*
    mixin("`w example`, s, k, *p, typeid(s)".w);

    Prints:
        `w example`: immutable(char)[] = w example
        s: immutable(char)[] = Purpose of life
        k: int = 42
        *p: int = 42
        typeid(s): TypeInfo_Array = immutable(char)[]
*/
}

    //---***---***---***---***---***--- public classes ---***---***---***---***---***---***

    //---***---***---***---***---***--- public data ---***---***---***---***---***--


    //^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v
    //
    //                            Public
    //
    //v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^

//    public Object public_func() {
//       throw new UnsupportedOperationException("Not supported yet.");
//    }


    //===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@
    //
    //                                  Package
    //
    //===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@===@@@

    //---@@@---@@@---@@@---@@@---@@@--- data ---@@@---@@@---@@@---@@@---@@@---@@@---

    //---@@@---@@@---@@@---@@@---@@@--- methods ---@@@---@@@---@@@---@@@---@@@---@@@---@@@-

//    Object Func() {
//       throw new UnsupportedOperationException("Not supported yet.");
//    }

    //---@@@---@@@---@@@---@@@---@@@--- class ---@@@---@@@---@@@---@@@---@@@---@@@---@@@-

    //~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$
    //
    //                                 Protected
    //
    //~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$~~~$$$

    //---$$$---$$$---$$$---$$$---$$$--- protected data ---$$$---$$$---$$$---$$$---$$$--

    //---$$$---$$$---$$$---$$$---$$$--- protected methods ---$$$---$$$---$$$---$$$---$$$---

//    protected Object ProtectedFunc() {
//       throw new UnsupportedOperationException("Not supported yet.");
//    }

    //---$$$---$$$---$$$---$$$---$$$--- protected classes ---$$$---$$$---$$$---$$$---$$$---

    //###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%
    //
    //                               Private
    //
    //###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%###%%%

    //---%%%---%%%---%%%---%%%---%%% private data ---%%%---%%%---%%%---%%%---%%%---%%%

    //---%%%---%%%---%%%---%%%---%%% private methods ---%%%---%%%---%%%---%%%---%%%---%%%--

//    private Object _privateFunc_() {
//       throw new UnsupportedOperationException("Not supported yet.");
//    }

    //---%%%---%%%---%%%---%%%---%%% private classes ---%%%---%%%---%%%---%%%---%%%---%%%--
