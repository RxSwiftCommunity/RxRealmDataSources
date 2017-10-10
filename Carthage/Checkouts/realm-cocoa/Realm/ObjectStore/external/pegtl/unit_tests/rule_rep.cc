// Copyright (c) 2014-2015 Dr. Colin Hirsch and Daniel Frey
// Please see LICENSE for license or visit https://github.com/ColinH/PEGTL/

#include "test.hh"

namespace pegtl
{
   void unit_test()
   {
      verify_analyze< rep< 0, eof > >( __LINE__, __FILE__, false, false );
      verify_analyze< rep< 0, any > >( __LINE__, __FILE__, false, false );
      verify_analyze< rep< 1, eof > >( __LINE__, __FILE__, false, false );
      verify_analyze< rep< 1, any > >( __LINE__, __FILE__, true, false );
      verify_analyze< rep< 7, eof > >( __LINE__, __FILE__, false, false );
      verify_analyze< rep< 9, any > >( __LINE__, __FILE__, true, false );

      verify_analyze< rep< 0, eof, eof > >( __LINE__, __FILE__, false, false );
      verify_analyze< rep< 0, any, eof > >( __LINE__, __FILE__, false, false );
      verify_analyze< rep< 0, any, any > >( __LINE__, __FILE__, false, false );
      verify_analyze< rep< 0, eof, any > >( __LINE__, __FILE__, false, false );
      verify_analyze< rep< 1, eof, eof > >( __LINE__, __FILE__, false, false );
      verify_analyze< rep< 1, any, eof > >( __LINE__, __FILE__, true, false );
      verify_analyze< rep< 1, any, any > >( __LINE__, __FILE__, true, false );
      verify_analyze< rep< 1, eof, any > >( __LINE__, __FILE__, true, false );

      verify_rule< rep< 3, one< 'a' > > >( __LINE__, __FILE__,  "", result_type::LOCAL_FAILURE, 0 );
      verify_rule< rep< 3, one< 'a' > > >( __LINE__, __FILE__,  "a", result_type::LOCAL_FAILURE, 1 );
      verify_rule< rep< 3, one< 'a' > > >( __LINE__, __FILE__,  "aa", result_type::LOCAL_FAILURE, 2 );
      verify_rule< rep< 3, one< 'a' > > >( __LINE__, __FILE__,  "b", result_type::LOCAL_FAILURE, 1 );
      verify_rule< rep< 3, one< 'a' > > >( __LINE__, __FILE__,  "bb", result_type::LOCAL_FAILURE, 2 );
      verify_rule< rep< 3, one< 'a' > > >( __LINE__, __FILE__,  "bbb", result_type::LOCAL_FAILURE, 3 );
      verify_rule< rep< 3, one< 'a' > > >( __LINE__, __FILE__,  "aaa", result_type::SUCCESS, 0 );
      verify_rule< rep< 3, one< 'a' > > >( __LINE__, __FILE__,  "aaaa", result_type::SUCCESS, 1 );
      verify_rule< rep< 3, one< 'a' > > >( __LINE__, __FILE__,  "aaab", result_type::SUCCESS, 1 );
      verify_rule< rep< 3, one< 'a' > > >( __LINE__, __FILE__,  "baaab", result_type::LOCAL_FAILURE, 5 );

      verify_rule< rep< 2, two< 'a' > > >( __LINE__, __FILE__,  "a", result_type::LOCAL_FAILURE, 1 );
      verify_rule< rep< 2, two< 'a' > > >( __LINE__, __FILE__,  "aa", result_type::LOCAL_FAILURE, 2 );
      verify_rule< rep< 2, two< 'a' > > >( __LINE__, __FILE__,  "aaa", result_type::LOCAL_FAILURE, 3 );
      verify_rule< rep< 2, two< 'a' > > >( __LINE__, __FILE__,  "aaaa", result_type::SUCCESS, 0 );
      verify_rule< rep< 2, two< 'a' > > >( __LINE__, __FILE__,  "aaaaa", result_type::SUCCESS, 1 );
      verify_rule< rep< 2, two< 'a' > > >( __LINE__, __FILE__,  "aaaaaa", result_type::SUCCESS, 2 );
      verify_rule< rep< 2, two< 'a' > > >( __LINE__, __FILE__,  "aaaaaaa", result_type::SUCCESS, 3 );
   }

} // pegtl

#include "main.hh"
