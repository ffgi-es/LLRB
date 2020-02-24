#include "ruby.h"
#include "extconf.h"

VALUE rb_mCLLRB;
VALUE rb_cNode;
VALUE rb_cLLRB;

struct node {
    VALUE key;
    VALUE value;
    struct node* next;
};

void mark_node(void* curr) {
    struct node* n = curr;
    if (!n) return;

    rb_gc_mark(n->key);
    rb_gc_mark(n->value);

    mark_node(n->next);
}

void free_node(void* curr) {
    struct node* n = curr;

    if (!n) return;

    free_node(n->next);

    free(n);
}

static const rb_data_type_t node_type = {
    "node",
    {mark_node, free_node,},
    0, 0,
    RUBY_TYPED_FREE_IMMEDIATELY,
};

static VALUE node_alloc(VALUE klass) {
    struct node* n;
    return TypedData_Make_Struct(klass, struct node, &node_type, n);
}

static VALUE node_initialize(VALUE obj, VALUE key, VALUE value) {
    struct node* n;
    TypedData_Get_Struct(obj, struct node, &node_type, n);

    n->key = key;
    n->value = value;
    n->next = NULL;

    return obj;
}

static VALUE node_new(VALUE klass, VALUE key, VALUE value) {
    VALUE obj = node_alloc(klass);
    return node_initialize(obj, key, value);
}

static VALUE find_value(struct node* n, VALUE key) {
    int comp;
    if (!n) return Qnil;
    comp = FIX2INT(rb_funcall(key, rb_intern("<=>"), 1, n->key));
    if (comp == 0) return n->value;
    return find_value(n->next, key);
}

static void insert_node(struct node* n, VALUE key, VALUE value) {
    int comp = FIX2INT(rb_funcall(key, rb_intern("<=>"), 1, n->key));
    if (comp == 0) {
        n->value = value;
        return;
    }
    if (!n->next) {
        n->next = malloc(sizeof(struct node));
        n->next->key = key;
        n->next->value = value;
        n->next->next = NULL;
    } else {
        insert_node(n->next, key, value);
    }
}

VALUE llrb_initialize(VALUE obj) {
    rb_iv_set(obj, "@size", INT2FIX(0));

    return obj;
}

VALUE squareBrackets(VALUE obj, VALUE index) {
    if (!NIL_P(rb_iv_get(obj, "@root"))) { 
        struct node* n;
        TypedData_Get_Struct(rb_iv_get(obj, "@root"), struct node, &node_type, n);
        
        return find_value(n, index);
    }
    return Qnil;
}

VALUE assignSquareBrackets(VALUE obj, VALUE index, VALUE value) {
    if (NIL_P(rb_iv_get(obj, "@root"))) {
        rb_iv_set(obj, "@root", node_new(rb_cNode, index, value));
    } else {
        struct node* n;
        TypedData_Get_Struct(rb_iv_get(obj, "@root"), struct node, &node_type, n);
        insert_node(n, index, value);
    }
    rb_iv_set(obj, "@size", INT2NUM(NUM2INT(rb_iv_get(obj, "@size")) + 1));
    return value;
}

VALUE size(VALUE obj) {
    return rb_iv_get(obj, "@size");
}

void Init_cllrb() {
    rb_mCLLRB = rb_define_module("CLLRB");
    rb_cNode = rb_define_class_under(rb_mCLLRB, "Node", rb_cData);
    rb_cLLRB = rb_define_class_under(rb_mCLLRB, "LLRB", rb_cObject);

    rb_define_alloc_func(rb_cNode, node_alloc);
    rb_define_singleton_method(rb_cNode, "new", node_new, 2);

    rb_define_method(rb_cLLRB, "initialize", llrb_initialize, 0);
    rb_define_method(rb_cLLRB, "[]", &squareBrackets, 1);
    rb_define_method(rb_cLLRB, "[]=", &assignSquareBrackets, 2);
    rb_define_method(rb_cLLRB, "size", &size, 0);
}
