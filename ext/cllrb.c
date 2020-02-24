#include "ruby.h"
#include "extconf.h"

void Init_cllrb() {
    VALUE rb_mCLLRB = rb_define_module("CLLRB");
    rb_define_class_under(rb_mCLLRB, "LLRB", rb_cObject);
}
