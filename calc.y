%code requires{
    #include "ast.h"
}

%{
#include <string>
#include <list>
#include <map>
    #include <cstdio>
    using namespace std;
    int yylex();
    extern int yylineno;
    void yyerror(const char * s){
        fprintf(stderr, "Line: %d, error: %s\n", yylineno, s);
    }

  map<string, float> TP_Map;
  map<string, string> TP_Map2;
  map<float, float> statements;
    #define YYERROR_VERBOSE 1
        #define YYDEBUG 1


%}

%union{
  const char * string_t;
  float float_t;
  Expr * expr_t;
  bool bool_t;
    ArgumentList * argument_list_t;
    Statement * statement_t;
    StatementList * statement_list_t;

}

%token EOL
%token ADD SUB MUL DIV IF THEN ENDIF WHILE DO DONE ELSE LET
%token<float_t> TK_LIT_FLOAT
%token<string_t>  TK_ID

/* %type<expr_t> assignment_statement */
%type<statement_list_t> input 
%type<float_t> expression term factor
%type<statement_t> external_declaration method_definition block_statement 

%type<bool_t> relational_expression
/* %type<parameter_list_t> parameters_list */
/* %type <statement_t>  while_statement */
/* %type<expr_t>  term relational_expression factor expression  */


%%
start: input {  printf("\n");

}
    ;

input: input external_declaration {} 
    | external_declaration {}
    ;

external_declaration: method_definition EOL 
    | declaration EOL  {}
    | expression EOL  {  printf("\nResultado Operacion: %f\n", $1); }
    | method_invocation EOL
    ;

method_invocation: TK_ID '(' parameters_values ')'
    | TK_ID '(' parameters_values ')' ';'
    | TK_ID '(' ')' ';'
    | TK_ID '(' ')' 
    ;

parameters_values: parameters_values ',' expression 
    |  parameters_values ',' TK_ID
    | expression
    | TK_ID
    ;

method_definition: LET TK_ID '(' parameters_list ')' '=' DO block_statement DONE {         
    if(TP_Map2.count($2) > 0){  
        printf("\nError: Metodo Previamente Declarada [%s]  \n", $2); 
        exit(0);
        } else {
        TP_Map2.insert({$2,"METHOD"}); 
        printf("\nMETODO [%s] Declarada \n", $2);
        }
    }
    | LET TK_ID '(' ')' '=' DO block_statement DONE {  
        if(TP_Map2.count($2) > 0){  
        printf("\nError: Metodo Previamente Declarada [%s]  \n", $2); 
        exit(0);
        } else {
        TP_Map2.insert({$2,"METHOD"}); 
        printf("\nMETODO [%s] Declarada \n", $2);
        }
    }
    | LET TK_ID '(' parameters_list ')' '=' expression {
        if(TP_Map2.count($2) > 0){  
        printf("\nError: Metodo Previamente Declarada [%s]  \n", $2); 
        exit(0);
        } else {
        TP_Map2.insert({$2,"METHOD"}); 
        printf("\nMETODO [%s] Declarada \n", $2);
        }

    }
    ;

parameters_list: parameters_list ',' TK_ID  {
        if(TP_Map.count($3) > 0){  
        printf("\nError: Variable Previamente Declarada [%s]  \n", $3); 
        exit(0);
        } else {
        TP_Map.insert({$3,0});  
        }}
    | TK_ID { 
        if(TP_Map.count($1) > 0){  
        printf("\nError: Variable Previamente Declarada [%s]  \n", $1); 
        exit(0);
        } else {
        TP_Map.insert({$1,0});  
        }}
    ;

block_statement: block_statement while_statement 
    | block_statement assignment_statement
    | block_statement expression 
    |
    ;

while_statement: WHILE '(' relational_expression ')' DO block_statement DONE {    }
    ;

relational_expression: relational_expression '>' expression {  $$ = $1 > $3 ? 1 : 0;   } 
                    | relational_expression '<' expression  {  $$ = $1 < $3 ? 1 : 0;   } 
                    | expression {$$ = $1;}

                    ;

assignment_statement: TK_ID '=' expression  {
     if(TP_Map.count($1) == 0){  
        printf("\nError: Variable No Declarada [%s] en la Linea %d \n", $1, yylineno); 
        
        }else{
            TP_Map[$1] = $3;
        }
        }
    | TK_ID '=' expression ';'{
     if(TP_Map.count($1) == 0){  
        printf("\nError: Variable No Declarada [%s] en la Linea %d \n", $1, yylineno); 
       
        }else{
            TP_Map[$1] = $3;
        }}
    ;

declaration: LET TK_ID '=' expression ';'{    
        if(TP_Map.count($2) > 0){  
        printf("\nError: Variable Previamente Declarada [%s]  \n", $2); 
        exit(0);
        } else {
        TP_Map.insert({$2,$4});  
        printf("\nVariable [%s] Declarada \n", $2);
        }
        } 
    | LET TK_ID '=' expression  {    
        if(TP_Map.count($2) > 0){  
        printf("\nError: Variable Previamente Declarada [%s]  \n", $2); 
        exit(0);
        } else {
        TP_Map.insert({$2,$4});  
        printf("\nVariable [%s] Declarada \n", $2);
        }
        } 
    ;

expression: expression ADD term  {$$ = $1 + $3;  }
    | expression SUB term  {$$ = $1 - $3; }
    | term { $$ = $1; }
    ;

term: term MUL factor { $$ = $1 * $3; }
    | term DIV factor { $$ = $1 / $3; }
    | factor { $$ = $1; }
    ;

factor: TK_LIT_FLOAT {$$ = $1;}
    ;



%%
