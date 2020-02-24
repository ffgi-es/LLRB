#include "ruby.h"
#include "extconf.h"

VALUE squareBrackets(VALUE obj, VALUE index) {
    return rb_iv_get(obj, "@value");
}

VALUE assignSquareBrackets(VALUE obj, VALUE index, VALUE value) {
    return rb_iv_set(obj, "@value", value);
}

VALUE size(VALUE obj) {
    return INT2NUM(0);
}

void Init_cllrb() {
    VALUE rb_mCLLRB = rb_define_module("CLLRB");
    VALUE rb_cLLRB = rb_define_class_under(rb_mCLLRB, "LLRB", rb_cObject);
    rb_define_method(rb_cLLRB, "[]", &squareBrackets, 1);
    rb_define_method(rb_cLLRB, "[]=", &assignSquareBrackets, 2);
    rb_define_method(rb_cLLRB, "size", &size, 0);
}
