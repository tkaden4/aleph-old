module util.meta;

import std.typecons;
import std.traits;
import std.meta;

template ReturnTypes(Args...){
    alias ReturnTypes = staticMap!(ReturnType, Args);
};

template WithoutNull(Args...){
    alias WithoutNull = EraseAll!(typeof(null), Args);
};

template AllConversions(Args...){
    alias AllConversions = WithoutNull!(NoDuplicates!(staticMap!(ImplicitConversionTargets, Args)));
};

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

template emptyFunc(T)
{
    alias emptyFunc = (T _) => _;
}

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
