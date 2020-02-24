#include "ruby.h"
#include "extconf.h"

VALUE squareBrackets(int argc, VALUE* argv, VALUE obj) {
    return rb_iv_get(obj, "@value");
}

VALUE assignSquareBrackets(int argc, VALUE* argv, VALUE obj) {
    return rb_iv_set(obj, "@value", argv[1]);
}

void Init_cllrb() {
    VALUE rb_mCLLRB = rb_define_module("CLLRB");
    VALUE rb_cLLRB = rb_define_class_under(rb_mCLLRB, "LLRB", rb_cObject);
    rb_define_method(rb_cLLRB, "[]", &squareBrackets, -1);
    rb_define_method(rb_cLLRB, "[]=", &assignSquareBrackets, -1);
}
