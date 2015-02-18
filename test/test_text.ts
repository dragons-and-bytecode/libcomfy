#suite text

#include <stdio.h>
#include "comfy.h"

#test test_foo
    Text* txt = text_new("Foo?", 4);
    ck_assert(txt);
    text_destroy(txt);
