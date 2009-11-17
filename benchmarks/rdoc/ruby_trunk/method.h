/**********************************************************************

  method.h -

  $Author: matz $
  created at: Wed Jul 15 20:02:33 2009

  Copyright (C) 2009 Koichi Sasada

**********************************************************************/
#ifndef METHOD_H
#define METHOD_H

typedef enum {
    NOEX_PUBLIC    = 0x00,
    NOEX_NOSUPER   = 0x01,
    NOEX_PRIVATE   = 0x02,
    NOEX_PROTECTED = 0x04,
    NOEX_MASK      = 0x06,
    NOEX_BASIC     = 0x08,
    NOEX_UNDEF     = NOEX_NOSUPER,
    NOEX_MODFUNC   = 0x12,
    NOEX_SUPER     = 0x20,
    NOEX_VCALL     = 0x40,
    NOEX_RESPONDS  = 0x80
} rb_method_flag_t;

#define NOEX_SAFE(n) ((int)((n) >> 8) & 0x0F)
#define NOEX_WITH(n, s) ((s << 8) | (n) | (ruby_running ? 0 : NOEX_BASIC))
#define NOEX_WITH_SAFE(n) NOEX_WITH(n, rb_safe_level())

/* method data type */

typedef enum {
    VM_METHOD_TYPE_ISEQ,
    VM_METHOD_TYPE_CFUNC,
    VM_METHOD_TYPE_ATTRSET,
    VM_METHOD_TYPE_IVAR,
    VM_METHOD_TYPE_BMETHOD,
    VM_METHOD_TYPE_ZSUPER,
    VM_METHOD_TYPE_UNDEF,
    VM_METHOD_TYPE_NOTIMPLEMENTED,
    VM_METHOD_TYPE_OPTIMIZED, /* Kernel#send, Proc#call, etc */
    VM_METHOD_TYPE_MISSING   /* wrapper for method_missing(id) */
} rb_method_type_t;

typedef struct rb_method_cfunc_struct {
    VALUE (*func)(ANYARGS);
    int argc;
} rb_method_cfunc_t;

typedef struct rb_iseq_struct rb_iseq_t;

typedef struct rb_method_definition_struct {
    rb_method_type_t type; /* method type */
    ID original_id;
    union {
	rb_iseq_t *iseq;            /* should be mark */
	rb_method_cfunc_t cfunc;
	ID attr_id;
	VALUE proc;                 /* should be mark */
	enum method_optimized_type {
	    OPTIMIZED_METHOD_TYPE_SEND,
	    OPTIMIZED_METHOD_TYPE_CALL
	} optimize_type;
    } body;
    int alias_count;
} rb_method_definition_t;

typedef struct rb_method_entry_struct {
    rb_method_flag_t flag;
    rb_method_definition_t *def;
    ID called_id;
    VALUE klass;                    /* should be mark */
} rb_method_entry_t;

#define UNDEFINED_METHOD_ENTRY_P(me) (!(me) || !(me)->def || (me)->def->type == VM_METHOD_TYPE_UNDEF)

void rb_add_method_cfunc(VALUE klass, ID mid, VALUE (*func)(ANYARGS), int argc, rb_method_flag_t noex);
rb_method_entry_t *rb_add_method(VALUE klass, ID mid, rb_method_type_t type, void *option, rb_method_flag_t noex);
rb_method_entry_t *rb_add_method_me(VALUE klass, ID mid, const rb_method_entry_t *, rb_method_flag_t noex);
rb_method_entry_t *rb_method_entry(VALUE klass, ID id);
rb_method_entry_t *rb_get_method_entry(VALUE klass, ID id);
#define rb_method_entry_without_cache(klass, id) rb_get_method_entry((klass), (id))
int rb_method_entry_arity(const rb_method_entry_t *me);
void rb_gc_mark_method_entry(const rb_method_entry_t *me);
void rb_free_method_entry(rb_method_entry_t *me);

#endif /* METHOD_H */
