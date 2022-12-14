// PR 99294, ICE with -fno-module-lazy on class completeness
// { dg-additional-options -fmodules-ts }

// The instantiation of the *definition* of basic_string is used in
// importers, *after* they have instantiated a declaration of it *and*
// created type variants.

module;

#include "pr99294.h"

export module foo;
// { dg-module-cmi foo }

export inline int greeter (string const &bob)
{
  return sizeof (bob); // instantiates string
}
