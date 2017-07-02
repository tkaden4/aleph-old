module util.meta;

import std.typecons;
import std.traits;
public import std.meta;

/* gets the return types of a set of functions */
template ReturnTypes(Args...){
    alias ReturnTypes = staticMap!(ReturnType, Args);
};

/* removes null */
template WithoutNull(Args...){
    alias WithoutNull = EraseAll!(typeof(null), Args);
};

/* geta all converstion targets of types */
template AllConversions(Args...){
    alias AllConversions = WithoutNull!(NoDuplicates!(staticMap!(ImplicitConversionTargets, Args)));
};

/* gets the highest converstion target */
template GreatestCommonType(Args...){
    static if(is(CommonType!Args == void)){
        private alias temp = DerivedToFront!(Reverse!(AllConversions!(Args)));
    }else{
        private alias temp = AliasSeq!(CommonType!(Args));
    }
    static if(temp.length){
        alias GreatestCommonType = temp[0];
    }else{
        alias GreatestCommonType = void;
    }
};

/* function that returns parameter passed to it */
template emptyFunc(T)
{
    alias emptyFunc = (T _) => _;
}
alias identity = emptyFunc;

/* get all fields of an aggregate type with names */
template FieldsWithNames(T)
    if(isAggregateType!T)
{
    private alias types = Fields!T;
    private alias names = FieldNameTuple!T;

    template makeTup(string Name){
        alias makeTup = AliasSeq!(types[staticIndexOf!(Name, names)], Name);
    }

    alias FieldsWithNames = Tuple!(staticMap!(makeTup, names));
};

/* create a lazy property */
mixin template Lazy(string vname,
                    alias getter,
                    string backingField="_" ~ vname,
                    string typeString=fullyQualifiedName!(ReturnType!getter)){
    mixin("private " ~ typeString ~ " " ~ backingField ~ ";");

    public @property {
        mixin("auto ref " ~ vname ~ "(){
            if(!this." ~ backingField ~ "){
                this." ~ backingField ~ " = getter();
            }
            return this." ~ backingField ~ ";
        }");
    };
};

/* partially apply a template */
template PartialApp(alias T, alias With) {
    alias PartialApp = PartialApp!(T, 0, With);
};

/* partially apply a template at a given index */
template PartialApp(alias T, size_t where, With...) {
    template PartialApp(Args...){
        alias PartialApp = T!(Insert!(With, where, Args));
    };
};

/* insert an alias into a set of aliases */
template Insert(alias T, size_t where, Args...){
    static if(__traits(compiles, T.length)){
        alias Insert = AliasSeq!(Args[0..where], T, Args[(where + T.length - 1)..$]);
    }else{
        alias Insert = AliasSeq!(Args[0..where], T, Args[where..$]);
    }
};
