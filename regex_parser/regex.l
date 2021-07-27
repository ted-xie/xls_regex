%{
  #include <iostream>
  #include "regex.tab.h"
  using namespace std;
  extern int yylex();
%}
%option noyywrap
%%
\[                { yylval = strdup(yytext); return SQR_BRACK_OPEN; free(yytext); }
\]                { yylval = strdup(yytext); return SQR_BRACK_CLOS; free(yytext); }
\\\(              { yylval = strdup(yytext); return ESC_PAREN_OPEN; free(yytext); }
\\\)              { yylval = strdup(yytext); return ESC_PAREN_CLOS; free(yytext); }
\\\?              { yylval = strdup(yytext); return ESC_QUESTION_MARK; free(yytext); } 
[ a-zA-Z0-9]      { yylval = strdup(yytext); return LITERAL; free(yytext); }
%%

/*
int main(int, char**) {
  // lex through the input:
  while (yylex());
}
*/
