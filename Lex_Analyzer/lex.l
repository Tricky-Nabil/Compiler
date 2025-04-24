%option noyywrap yylineno

%x SINGLE_LINE_COMMENT
%x MULTI_LINE_COMMENT
%x STRING
%{
#include<bits/stdc++.h>
#include"Node.cpp"
#include "syntax_semantic.tab.h"

extern ofstream logout;
extern ofstream tokenout;
int error_count = 0;

string str_for_comment;
int line_count_comment;

string str_for_string;
int line_count_string;

map<char, string> Special_Char = {
        {'n', "\n"},
        {'t', "\t"},
        {'\\', "\\"},
        {'\'', "\'"},
        {'a', "\a"},
        {'f', "\f"},
        {'r', "\r"},
        {'b', "\b"},
        {'v', "\v"},
        {'0', "\0"},
        {'\"', "\""},
    };



string log_str;
string token_str;



int bucket_size = 10;
SymbolTable st(bucket_size);

void printString(string Up , string normal){
    
    
    tokenout<<"<"<<Up<<", "<<normal<<">\n";
	logout<<"Line# "<<yylineno<<": Token <"<<Up<<"> Lexeme "<<normal<<" found\n";
    
}

void UpperString(string s){
    string temp = "";
    for(auto i: s){
			if(i >= 'a' && i <= 'z')
				temp+= i - 'a' + 'A';
			else temp += i;
	}

    printString(temp , s);
}

void Special_char_handle(string tkn , string text){
    
    
    string val = "";
    val+=Special_Char[text[2]];
    logout<<"Line# "<<yylineno<<": Token <"<<tkn<<"> Lexeme "<<val<<" found\n";
    tokenout<<"<"<<tkn<<", "<<val<<">\n";
    
}
void char_handle(string tkn , string text){
    
    string val = "";
    val+=text[1];
    logout<<"Line# "<<yylineno<<": Token <"<<tkn<<"> Lexeme "<<val<<" found\n";
    tokenout<<"<"<<tkn<<", "<<val<<">\n";
    
}

void logPrint(string tkn , string text){
    logout<<"Line# "<<yylineno<<": Token <"<<tkn<<"> Lexeme "<<text<<" found\n";
}

void tokenPrint(string tkn , string text){
    tokenout<<"<"<<tkn<<", "<<text<<">\n";
}
void string_handle(string tkn1 , string text,int line_no){
    string tkn;
    if(yylineno > line_count_string)
        tkn = "MULTI LINE STRING";
    else
        tkn = "SINGLE LINE STRING";
    string temp = "";
    int line_of_string = 0;
    for(int i = 1 ; i < text.length() - 1 ; i++){
        
        if(text[i]!='\\'){
            temp+=text[i];
        }
        else{
            temp+= Special_Char[text[++i]];
            
        }
    }
    
    logout<<"Line# "<<line_no<<": Token <"<<tkn<<"> Lexeme "<<text<<" found\n";
    tokenPrint(tkn , temp);
    
}
void handle_comment(string tkn , string text , int line_no){
    int line_temp = 0;
    for(int i = 0 ; i < text.length() ; i++){
        if(text[i] == '\n')
            line_temp++;
        
    } 
    logout<<"Line# "<<line_no<<": Token <"<<tkn<<"> Lexeme "<<text<<" found\n";
    
}
void ErrorMsg(string str , string text){
    cout<<"Error at line# "<<yylineno<<": "<<str<<" "<<text<<endl;
}

void ErrorMsg_Str(string str , string text , int line_no){
    cout<<"Error at line# "<<line_no<<": "<<str<<" "<<text<<endl;
}
void ErrorMsgCom(string str , string text){
    cout<<"Error at line# "<<yylineno<<": "<<str<<" "<<text<<endl;
}

%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
DIGITS {DIGIT}+
EXP (E[+-]?{DIGITS})
NEWLINE \n
NEWLINE1 (\r)?\n
FLOAT {DIGITS}{EXP}|{DIGITS}?\.{DIGITS}{EXP}
CONST_CHAR \'[^\\\n\r]\'
SPECIAL_CHAR \'\\[nt\\'afrbv0\"]\'
MULTICHAR_CONST_CHAR \'.[^\'\r\n]+\' 
UNFINISHED_CONST_CHAR \'(\\\')?[^\'\r\n]?
EMPTY_CONST_CHAR \'\'

%%

\n  {}
{WHITESPACE} {}
"if" {
     UpperString(yytext); 
     yylval = new Node(new SymbolInfo(yytext , "IF") , yylineno);
     return IF;
     }
"else" {
    UpperString(yytext);
     yylval = new Node(new SymbolInfo(yytext , "ELSE") , yylineno);
     return ELSE;
    }
"for" {
    UpperString(yytext);
     yylval = new Node(new SymbolInfo(yytext , "FOR") , yylineno);
     return FOR;
    }
"while" {
    UpperString(yytext);
    yylval = new Node(new SymbolInfo(yytext , "WHILE") , yylineno);
    return WHILE;
    }
"do" {
    UpperString(yytext);
    yylval = new Node(new SymbolInfo(yytext , "DO") , yylineno);
    return DO;
    }
"break" {
    UpperString(yytext);
    yylval = new Node(new SymbolInfo(yytext , "BREAK") , yylineno);
    return BREAK;
    }
"int" {
    UpperString(yytext);
    yylval = new Node(new SymbolInfo(yytext , "INT") , yylineno);
    return INT;
}
"char" {
    UpperString(yytext);
    yylval = new Node(new SymbolInfo(yytext , "CHAR") , yylineno);
    return CHAR;
    }
"float" {
    UpperString(yytext);
    yylval = new Node(new SymbolInfo(yytext , "FLOAT") , yylineno);
    return FLOAT;
    }
"double" {
    UpperString(yytext);
    yylval = new Node(new SymbolInfo(yytext , "DOUBLE") , yylineno);
    return DOUBLE;
    }   
"void" {
    UpperString(yytext);
    yylval = new Node(new SymbolInfo(yytext , "VOID") , yylineno);
    return VOID;
    }
"return" {
    UpperString(yytext);
    yylval = new Node(new SymbolInfo(yytext , "RETURN") , yylineno);
    return RETURN;
    }
"switch" {
    UpperString(yytext);
    yylval = new Node(new SymbolInfo(yytext , "SWITCH") , yylineno);
    return SWITCH;
    }
"default" {
    UpperString(yytext);
    yylval = new Node(new SymbolInfo(yytext , "SWITCH") , yylineno);
    return SWITCH;
    }
"continue" {
    UpperString(yytext);
    yylval = new Node(new SymbolInfo(yytext , "CONTINUE") , yylineno);
    return CONTINUE;
    }
"case" {
    UpperString(yytext);
    yylval = new Node(new SymbolInfo(yytext , "CASE") , yylineno);
    return CASE;
    }
"++"|"--" {
    printString("INCOP" , yytext);
    yylval = new Node(new SymbolInfo(yytext , "INCOP") , yylineno);
    return INCOP;
    }
"+"|"-" {
    printString("ADDOP" , yytext);
    yylval = new Node(new SymbolInfo(yytext , "ADDOP") , yylineno);
    return ADDOP;
    }
"*"|"/"|"%" {
    printString("MULOP" , yytext);
    yylval = new Node(new SymbolInfo(yytext , "MULOP") , yylineno);
    return MULOP;
    }
"<="|"<"|"=="|">="|">"|"!=" {
    printString("RELOP" , yytext);
    yylval = new Node(new SymbolInfo(yytext , "RELOP") , yylineno);
    return RELOP;
    }
"=" {
    printString("ASSIGNOP" , yytext);
    yylval = new Node(new SymbolInfo(yytext , "ASSIGNOP") , yylineno);
    return ASSIGNOP;
    }
"&&"|"||" {
    printString("LOGICOP" , yytext);
    yylval = new Node(new SymbolInfo(yytext , "LOGICOP") , yylineno);
    return LOGICOP;
    }
"&"|"|"|"^"|"<<"|">>" {
    printString("BITOP" , yytext);
    yylval = new Node(new SymbolInfo(yytext , "BITOP") , yylineno);
    return BITOP;
    }
"!" {
    printString("NOT" , yytext);
    yylval = new Node(new SymbolInfo(yytext , "NOT") , yylineno);
    return NOT;
    }
"(" {
    printString("LPAREN" , yytext);
    yylval = new Node(new SymbolInfo(yytext , "LPAREN") , yylineno);
    return LPAREN;
    }
")" {
    printString("RPAREN" , yytext);
    yylval = new Node(new SymbolInfo(yytext , "RPAREN") , yylineno);
    return RPAREN;
    }
"{" {
    printString("LCURL" , yytext); st.enterScope();
    yylval = new Node(new SymbolInfo(yytext , "LCURL") , yylineno);
    return LCURL;
    }
"}" {
    printString("RCURL" , yytext);
    st.exitScope(false);
    yylval = new Node(new SymbolInfo(yytext , "RCURL") , yylineno);
    return RCURL;
    }
"[" {
    printString("LSQUARE" , yytext);
    yylval = new Node(new SymbolInfo(yytext , "LSQUARE") , yylineno);
    return LTHIRD;
    }
"]" {
    printString("RSQUARE" , yytext);
    yylval = new Node(new SymbolInfo(yytext , "RSQUARE") , yylineno);
    return RTHIRD;
    }
"," {
    printString("COMMA" , yytext);
    yylval = new Node(new SymbolInfo(yytext , "COMMA") , yylineno);
    return COMMA;
    }
";" {
    printString("SEMICOLON" , yytext);
    yylval = new Node(new SymbolInfo(yytext , "SEMICOLON") , yylineno);
    return SEMICOLON;
    }



{DIGIT}+ {
    printString("CONST_INT" , yytext);
    yylval = new Node(new SymbolInfo(yytext , "CONST_INT") , yylineno);
    return CONST_INT;
    }
{DIGITS}{EXP}|{DIGITS}?\.{DIGITS}{EXP}? {
    printString("CONST_FLOAT" , yytext);
    yylval = new Node(new SymbolInfo(yytext , "CONST_FLOAT") , yylineno);
    return CONST_FLOAT;
    }

{DIGITS}{EXP}(\.{DIGITS}{EXP}?)+|{DIGITS}?\.{DIGITS}{EXP}(\.{DIGITS}{EXP}?)+ {
error_count++;
ErrorMsg("ILLFORMED_NUMBER",yytext);
}

[+-]?{DIGITS}?\.{DIGITS}(\.{DIGITS}{EXP}?)+ {
error_count++;
ErrorMsg("TOO_MANY_DECIMAL_POINTS",yytext);
}
{CONST_CHAR}   {
    char_handle("CONST_CHAR",yytext);
    
}
{SPECIAL_CHAR}   {
    Special_char_handle("CONST_CHAR",yytext);
}
{EMPTY_CONST_CHAR} {
    error_count++;
    ErrorMsg("EMPTY_CONST_CHAR",yytext);
}
{MULTICHAR_CONST_CHAR}   {
    error_count++;
    ErrorMsg("MULTICHAR_CONST_CHAR",yytext);
}
{UNFINISHED_CONST_CHAR}   {
    error_count++;
    ErrorMsg("UNFINISHED_CONST_CHAR",yytext);
}

\"  {
    str_for_string = yytext;
    line_count_string = yylineno;
    BEGIN STRING;
}
<STRING>\\{NEWLINE} {
    str_for_string+=yytext;
    //line_count_string++;
}

<STRING>\\\"    {
    str_for_string+=yytext;
} 
<STRING>[^\"\n\r]   {
    str_for_string+=yytext;
}
<STRING>\"  {
    str_for_string+=yytext;
    string_handle("",str_for_string,line_count_string);
    BEGIN INITIAL;
}
<STRING>{NEWLINE}   {
    error_count++;
    ErrorMsg_Str("UNFINISHED_STRING",str_for_string,line_count_string);
    BEGIN INITIAL;
}
<STRING><<EOF>> {
    error_count++;
    ErrorMsg_Str("UNFINISHED_STRING",str_for_string,line_count_string);
    st.printAllScp();
    st.exitScope(false);
    cout<<"Total lines: "<<yylineno<<endl;
    cout<<"Total errors: "<<error_count<<endl;
    return 0;
}

"//" {
    str_for_comment = yytext;     
    BEGIN SINGLE_LINE_COMMENT;
    line_count_comment = yylineno;
}

<SINGLE_LINE_COMMENT>. {
    str_for_comment+=yytext;
}

<SINGLE_LINE_COMMENT>\\{NEWLINE1} {
    str_for_comment+=yytext;
    
    
}

<SINGLE_LINE_COMMENT>{NEWLINE1} {
    handle_comment("SINGLE LINE COMMENT",str_for_comment,line_count_comment);
    BEGIN INITIAL;
}

<SINGLE_LINE_COMMENT><<EOF>>  {
    handle_comment( "SINGLE LINE COMMENT",str_for_comment,line_count_comment);
    st.printAllScp();
    st.exitScope(false);
    cout<<"Total lines: "<<yylineno<<endl;
    cout<<"Total errors: "<<error_count<<endl;
    return 0;
}

"/*" {
    str_for_comment = yytext;
    BEGIN MULTI_LINE_COMMENT;
    line_count_comment = yylineno;
}

<MULTI_LINE_COMMENT>. {
    str_for_comment+=yytext;
}


<MULTI_LINE_COMMENT>{NEWLINE1} {
    str_for_comment+=yytext;
}


<MULTI_LINE_COMMENT>"*/" {
    str_for_comment+=yytext;
    handle_comment("MULTI LINE COMMENT",str_for_comment,line_count_comment);
    BEGIN INITIAL;
} 

    /* error-8: multiline comment error */
<MULTI_LINE_COMMENT><<EOF>> {
    error_count++;
    ErrorMsgCom("UNFINISHED_COMMENT",str_for_comment);
    //symboltable.printAllScopeTables();
    st.printAllScp();
    st.exitScope(false);
    cout<<"Total lines: "<<yylineno<<endl;
    cout<<"Total errors: "<<error_count<<endl;
    return 0;
} 


[_a-zA-Z][_a-zA-Z0-9]* {
    printString("ID" , yytext);
    yylval = new Node(new SymbolInfo(yytext , "ID") , yylineno);
    return ID;
    
}
[0-9][a-zA-Z0-9]+ {error_count++;
ErrorMsg("INVALID_ID_SUFFIX_NUM_PREFIX",yytext);}

.   {
    error_count++;
    ErrorMsg("UNRECOGNIZED_CHAR",yytext);
}/*
<<EOF>> {
    st.printAllScp();
    st.exitScope(false);
    cout<<"Total lines: "<<yylineno<<endl;
    cout<<"Total errors: "<<error_count<<endl;
    return 0;

}*/

%%
/*
int main(int argc, char** argv) {
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	freopen("log.txt","w" , stdout);
	tokenout.open("token.txt");

	yyin= fin;
	yylex();
	
	fclose(yyin);
	
	
	return 0;
}
*/