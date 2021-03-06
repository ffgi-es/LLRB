#include "stdbool.h"
#include "ruby.h"
#include "extconf.h"

VALUE rb_mCLLRB;
VALUE rb_cTree;
VALUE rb_cLLRB;

struct node {
    VALUE key;
    VALUE value;
    bool red;
    struct node* lower;
    struct node* higher;
};

struct tree {
    struct node* root;
};

void mark_node(void* curr) {
    struct node* n = curr;
    if (!n) return;

    rb_gc_mark(n->key);
    rb_gc_mark(n->value);

    mark_node(n->lower);
    mark_node(n->higher);
}

void mark_tree(void* t) {
    mark_node(((struct tree*) t)->root);
}

void free_node(void* curr) {
    struct node* n = curr;

    if (!n) return;

    free_node(n->lower);
    free_node(n->higher);

    free(n);
}

void free_tree(void* t) {
    free_node(((struct tree*) t)->root);
}

static const rb_data_type_t tree_type = {
    "tree",
    {mark_tree, free_tree,},
    0, 0,
    RUBY_TYPED_FREE_IMMEDIATELY,
};

static VALUE tree_alloc(VALUE klass) {
    struct tree* t;
    return TypedData_Make_Struct(klass, struct tree, &tree_type, t);
}

static VALUE tree_initialize(VALUE obj) {
    struct tree* t;
    TypedData_Get_Struct(obj, struct tree, &tree_type, t);
    t->root = NULL;

    return obj;
}

static VALUE tree_new(VALUE klass) {
    VALUE obj = tree_alloc(klass);
    return tree_initialize(obj);
}

static struct node* new_node(VALUE key, VALUE value) {
    struct node* n = malloc(sizeof(struct node));
    n->key = key;
    n->value = value;
    n->red = true;
    n->lower = NULL;
    n->higher = NULL;
    return n;
}

static VALUE find_value(struct node* n, VALUE key) {
    int comp;
    if (!n) return Qnil;
    comp = FIX2INT(rb_funcall(key, rb_intern("<=>"), 1, n->key));
    switch (comp) {
        case 0:
            return n->value;
        case 1:
            return find_value(n->higher, key);
        case -1:
            return find_value(n->lower, key);
    }
    return Qnil;
}

static struct node* rotate_left(struct node* n) {
    struct node* tmp = n->higher;
    bool higher_red = tmp->red;
    n->higher = tmp->lower;
    tmp->lower = n;
    tmp->red = n->red;
    n->red = higher_red;
    return tmp;
}

static struct node* rotate_right(struct node* n) {
    struct node* tmp = n->lower;
    bool lower_red = tmp->red;
    n->lower = tmp->higher;
    tmp->higher = n;
    tmp->red = n->red;
    n->red = lower_red;
    return tmp;
}

static void colour_flip(struct node* n) {
    n->red = !n->red;
    n->lower->red = !n->lower->red;
    n->higher->red = !n->higher->red;
}

static bool higher_red(struct node* n) {
    if (n && n->higher) return n->higher->red;
    return false;
}

static bool higher_lower_red(struct node* n) {
    if (n && n->higher && n->higher->lower) return n->higher->lower->red;
    return false;
}

static bool lower_red(struct node* n) {
    if (n && n->lower) return n->lower->red;
    return false;
}

static bool lower_lower_red(struct node* n) {
    if (n && n->lower && n->lower->lower) return n->lower->lower->red;
    return false;
}

static struct node* move_red_right(struct node* n) {
    colour_flip(n);
    if (lower_lower_red(n)) {
        n = rotate_right(n);
        colour_flip(n);
    }
    return n;
}

static struct node* move_red_left(struct node* n) {
    colour_flip(n);
    if (higher_lower_red(n)) {
        n->higher = rotate_right(n->higher);
        n = rotate_left(n);
        colour_flip(n);
    }
    return n;
}

static struct node* fix_balance(struct node* n) {
    if (higher_red(n) && !lower_red(n))
        n = rotate_left(n);
    if (lower_red(n) && lower_lower_red(n))
        n = rotate_right(n);
    if (lower_red(n) && higher_red(n))
        colour_flip(n);
    return n;
}

static struct node* insert_node(struct node* n, VALUE key, VALUE value, int* size_ptr) {
    int comp;
    if (!n) {
        (*size_ptr)++;
        return new_node(key, value);
    }

    comp = FIX2INT(rb_funcall(key, rb_intern("<=>"), 1, n->key));
    switch (comp) {
    case 0:
        n->value = value;
        return n;
    case 1:
        n->higher = insert_node(n->higher, key, value, size_ptr);
        break;
    case -1:
        n->lower = insert_node(n->lower, key, value, size_ptr);
        break;
    }
    return fix_balance(n);
}

static VALUE llrb_initialize(VALUE obj) {
    rb_iv_set(obj, "@size", INT2FIX(0));
    rb_iv_set(obj, "@tree", tree_new(rb_cTree));

    return obj;
}

static VALUE squareBrackets(VALUE obj, VALUE key) {
    struct tree* t;
    TypedData_Get_Struct(rb_iv_get(obj, "@tree"), struct tree, &tree_type, t);

    return find_value(t->root, key);
}

static VALUE assignSquareBrackets(VALUE obj, VALUE index, VALUE value) {
    int size = NUM2INT(rb_iv_get(obj, "@size"));
    struct tree* t;
    TypedData_Get_Struct(rb_iv_get(obj, "@tree"), struct tree, &tree_type, t);
    t->root = insert_node(t->root, index, value, &size);
    t->root->red = false;

    rb_iv_set(obj, "@size", INT2NUM(size));
    return value;
}

static VALUE find_max(struct node* n) {
    if (!n->higher) return rb_ary_new_from_args(2, n->key, n->value);
    return find_max(n->higher);
}

static VALUE max(VALUE obj) {
    struct tree* t;
    TypedData_Get_Struct(rb_iv_get(obj, "@tree"), struct tree, &tree_type, t);
    if (!t->root) return Qnil;
    return find_max(t->root);
}

static VALUE find_min(struct node* n) {
    if (!n->lower) return rb_ary_new_from_args(2, n->key, n->value);
    return find_min(n->lower);
}

static VALUE min(VALUE obj) {
    struct tree* t;
    TypedData_Get_Struct(rb_iv_get(obj, "@tree"), struct tree, &tree_type, t);
    if (!t->root) return Qnil;
    return find_min(t->root);
}

static void each_node(struct node* n) {
    if (n->lower) each_node(n->lower);
    rb_yield_values(2, n->key, n->value);
    if (n->higher) each_node(n->higher);
}

static VALUE each(VALUE obj) {
    struct tree* t;
    if (!rb_block_given_p())
        rb_raise(rb_eArgError, "Expected block");
    TypedData_Get_Struct(rb_iv_get(obj, "@tree"), struct tree, &tree_type, t);
    if (t->root) each_node(t->root);
    return Qnil;
}

static struct node* deleteMax(struct node* n, struct node **result) {
    if (lower_red(n)) n = rotate_right(n);

    if (!n->higher) {
        *result = n;
        return NULL;
    }

    if (!higher_red(n) && !higher_lower_red(n)) n = move_red_right(n);

    n->higher = deleteMax(n->higher, result);

    return fix_balance(n);
}

static struct node* deleteMin(struct node* n, struct node **result) {
    if (!n->lower) {
        *result = n;
        return NULL;
    }

    if (!lower_red(n) && !lower_lower_red(n)) n = move_red_left(n);

    n->lower = deleteMin(n->lower, result);

    return fix_balance(n);
}

static struct node* delete_node(struct node* n, VALUE key, VALUE* result) {
    int comp;

    comp = FIX2INT(rb_funcall(key, rb_intern("<=>"), 1, n->key));
    if (comp < 0) {
        if (!lower_red(n) && !lower_lower_red(n)) n = move_red_left(n);
        n->lower = delete_node(n->lower, key, result);
    } else {
        if (lower_red(n)) n = rotate_right(n);

        comp = FIX2INT(rb_funcall(key, rb_intern("<=>"), 1, n->key));
        if (comp == 0 && !n->higher) {
            *result = n->value;
            free(n);
            return NULL;
        }
        if (!higher_red(n) && !higher_lower_red(n)) n = move_red_right(n);

        comp = FIX2INT(rb_funcall(key, rb_intern("<=>"), 1, n->key));
        if (comp == 0) {
            struct node* min;
            *result = n->value;
            n->higher = deleteMin(n->higher, &min);
            n->key = min->key;
            n->value = min->value;
            free(min);
        }
        else n->higher = delete_node(n->higher, key, result);
    }
    return fix_balance(n);
}

static VALUE pop(VALUE obj) {
    struct tree* t;
    struct node* result_node;
    VALUE result;

    TypedData_Get_Struct(rb_iv_get(obj, "@tree"), struct tree, &tree_type, t);
    if (!t->root) return Qnil;

    t->root = deleteMax(t->root, &result_node);
    if (t->root) t->root->red = false;

    result = rb_ary_new_from_args(2, result_node->key, result_node->value);
    free(result_node);

    rb_iv_set(obj, "@size", INT2NUM(NUM2INT(rb_iv_get(obj, "@size")) - 1));
    return result;
}

static VALUE shift(VALUE obj) {
    struct tree* t;
    struct node* result_node;
    VALUE result;

    TypedData_Get_Struct(rb_iv_get(obj, "@tree"), struct tree, &tree_type, t);
    if (!t->root) return Qnil;

    t->root = deleteMin(t->root, &result_node);
    if (t->root) t->root->red = false;

    result = rb_ary_new_from_args(2, result_node->key, result_node->value);
    free(result_node);

    rb_iv_set(obj, "@size", INT2NUM(NUM2INT(rb_iv_get(obj, "@size")) - 1));
    return result;
}

static VALUE delete(VALUE obj, VALUE key) {
    struct tree* t;
    VALUE result;

    TypedData_Get_Struct(rb_iv_get(obj, "@tree"), struct tree, &tree_type, t);
    if (!t->root) return Qnil;

    if(find_value(t->root, key) == Qnil) return Qnil;

    t->root = delete_node(t->root, key, &result);
    if (t->root) t->root->red = false;

    rb_iv_set(obj, "@size", INT2NUM(NUM2INT(rb_iv_get(obj, "@size")) - 1));
    return result;
}

void Init_cllrb() {
    rb_mCLLRB = rb_define_module("CLLRB");
    rb_cTree = rb_define_class_under(rb_mCLLRB, "Tree", rb_cData);
    rb_cLLRB = rb_define_class_under(rb_mCLLRB, "LLRB", rb_cObject);

    rb_define_alloc_func(rb_cTree, tree_alloc);
    rb_define_singleton_method(rb_cTree, "new", tree_new, 0);

    rb_define_method(rb_cLLRB, "initialize", llrb_initialize, 0);
    rb_define_attr(rb_cLLRB, "size", 1, 0);
    rb_define_method(rb_cLLRB, "[]", &squareBrackets, 1);
    rb_define_method(rb_cLLRB, "[]=", &assignSquareBrackets, 2);
    rb_define_method(rb_cLLRB, "max", max, 0);
    rb_define_method(rb_cLLRB, "min", min, 0);
    rb_define_method(rb_cLLRB, "each", each, 0);
    rb_define_method(rb_cLLRB, "pop", pop, 0);
    rb_define_method(rb_cLLRB, "shift", shift, 0);
    rb_define_method(rb_cLLRB, "delete", delete, 1);
}
