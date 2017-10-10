// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#include "test.hh"

namespace pegtl
{
   void unit_test()
   {
      verify_analyze< eof >( __LINE__, __FILE__, false, false );

      verify_rule< eof >( __LINE__, __FILE__,  "", result_type::SUCCESS, 0 );

      for ( char i = 1; i < 127; ++i ) {
         verify_char< eof >( __LINE__, __FILE__, i, result_type::LOCAL_FAILURE );
      }
      verify_rule< eof >( __LINE__, __FILE__,  "abcdefghijklmn", result_type::LOCAL_FAILURE, 14 );
   }

} // pegtl

#include "main.hh"
