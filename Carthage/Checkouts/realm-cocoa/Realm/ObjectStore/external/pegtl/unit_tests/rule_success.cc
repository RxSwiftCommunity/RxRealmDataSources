// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#include "test.hh"

namespace pegtl
{
   void unit_test()
   {
      verify_analyze< success >( __LINE__, __FILE__, false, false );

      verify_rule< success >( __LINE__, __FILE__,  "", result_type::SUCCESS, 0 );

      for ( char i = 1; i < 127; ++i ) {
         char t[] = { i, 0 };
         verify_rule< success >( __LINE__, __FILE__,  std::string( t ), result_type::SUCCESS, 1 );
      }
   }

} // pegtl

#include "main.hh"
