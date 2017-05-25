module syntax.visitors.traits;

/* get the return type of a provider */
template ProviderReturn(alias Provider, T) {
    alias ProviderReturn = ReturnType!(Provider!(Provider, T).visit);
};
