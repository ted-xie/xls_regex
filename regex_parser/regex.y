%{
  #include <math.h>
  #include <iostream>
  int yylex (void);
  void yyerror (char const *);
%}


/* Bison declarations. */
%define api.value.type {char*}
%token LITERAL
%token SQR_BRACK_OPEN
%token SQR_BRACK_CLOS
%token ESC_PAREN_OPEN
%token ESC_PAREN_CLOS
%token ESC_QUESTION_MARK
%left '-' '+'
%left '*' '/'
%precedence NEG   /* negation--unary minus */
%right '^'        /* exponentiation */


%% /* The grammar follows. */

input:
       %empty
| input line
;


line:
      '\n'
| exp '\n'  { printf ("%s\n", $1); }
;


exp:
     LITERAL 
| exp '-' exp        { ; }
;

%%

int main(int, char**) {
  // Parse through the input:
  yyparse();
}

void yyerror(const char *s) {
  std::cout << "parse error: " << s << std::endl;
  exit(-1);
}
