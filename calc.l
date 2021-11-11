%option noyywrap
%option yylineno
%option caseless


%{
    #include <stdio.h>
    #include "tokens.h"
%}
DIGIT [0-9]

%%

"+" { return ADD; }
"=" { return '='; }
"-" { return SUB; }
"*" { return MUL; }
"/" { return DIV; }
"(" { return '('; }
")" { return ')'; }
"," { return ','; }
";" { return ';'; }
">" { return '>'; }
"<" { return '<'; }
"let" { return LET; }
"while" { return WHILE; }
"do" { return DO; }
"done" { return DONE; }
{DIGIT}+ { yylval.float_t = atof(yytext); return TK_LIT_FLOAT; }
{DIGIT}+"."{DIGIT}+ { yylval.float_t = atof(yytext); return TK_LIT_FLOAT; }
[a-zA-Z]({DIGIT}|[a-zA-Z_0-9]|_)* { yylval.string_t = strdup(yytext); return TK_ID; }
[\n] { return EOL; }
[ \t] { /* ignorar */ }
. { printf("invalido %c\n", yytext[0]); }
%%