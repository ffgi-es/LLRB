#include "ruby.h"
#include "extconf.h"

VALUE squareBrackets(int argc, VALUE* argv, VALUE obj) {
    return Qnil;
}

void Init_cllrb() {
    VALUE rb_mCLLRB = rb_define_module("CLLRB");
    VALUE rb_cLLRB = rb_define_class_under(rb_mCLLRB, "LLRB", rb_cObject);
    rb_define_method(rb_cLLRB, "[]", &squareBrackets, -1);
}
