module util.meta.map;

public import util.meta;

template AliasMap(K, alias V) {
    alias AliasMap = AliasSeq!(K, V);
};

template Set(K, alias V, Map...)
{
    enum keyIndex = staticIndexOf!(K, Map);
    static if(keyIndex == -1){
        alias Set = AliasSeq!(K, V, Map);
    }else{
        alias newMap = AliasSeq!(Map[0..keyIndex], Map[(keyIndex+2)..$]);
        alias Set = AliasSeq!(K, V, newMap);
    }
}

template Get(K, Map...)
{
    enum keyIndex = staticIndexOf!(K, Map);
    static assert(keyIndex > -1, "Key not found in map");
    alias Get = Map[keyIndex+1];
}
