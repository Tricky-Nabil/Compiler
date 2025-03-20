%{
#include<bits/stdc++.h>
#include"Node.cpp"
#include<fstream>
using namespace std;

ofstream logout("log.txt"), tokenout("token.txt"), error("error.txt") , debug("debug.txt");
SymbolTable symboltable(11);
int yyparse(void);
int yylex(void);

extern FILE *yyin;
extern int yylineno;
extern int error_count;

bool isInFunction = false;


void yyerror(char *s){
	printf("%s\n",s);
}

int yylex(void);

vector<SymbolInfo *> getVar_from_decl_list(Node * node , string type){
    vector<SymbolInfo *> ans;
    if(node->getChildren().size() == 1){
        //ans.push_back();
        SymbolInfo *symbol = new SymbolInfo(node->getChildren()[0]->getSymbolInfo()->getName() , type , "normal");
        ans.push_back(symbol);

    }
    else if(node->getChildren().size() == 4){
        SymbolInfo *symbol = new SymbolInfo(node->getChildren()[0]->getSymbolInfo()->getName() , type , "array");
        ans.push_back(symbol);
    }
    else if(node->getChildren().size() == 3){
        ans = getVar_from_decl_list(node->getChildren()[0] , type);
        ans.push_back(new SymbolInfo(node->getChildren()[2]->getSymbolInfo()->getName() , type , "normal"));
        
    }
    else if(node->getChildren().size() == 6){
        ans = getVar_from_decl_list(node->getChildren()[0] , type);
        ans.push_back(new SymbolInfo(node->getChildren()[2]->getSymbolInfo()->getName() , type , "array"));
        
    }
    
    return ans;


}

vector<string> getParametreList(Node* node){
    vector<string> ans;
    if(node->getChildren().size() == 4){
        ans =  getParametreList(node->getChildren()[0]);
        ans.push_back(node->getChildren()[2]->getSymbolInfo()->getName());
    }
    else if(node->getChildren().size() == 3){
        ans = getParametreList(node->getChildren()[0]);
        ans.push_back(node->getChildren()[2]->getSymbolInfo()->getName());
    }
    else if(node->getChildren().size() == 2){
        ans.push_back(node->getChildren()[0]->getSymbolInfo()->getName());
    }
    else if(node->getChildren().size() == 1){
        ans.push_back(node->getChildren()[0]->getSymbolInfo()->getName());
    }
    
    return ans;
}

vector<string> getArgumentList_2(Node* node){
     vector<string> ans;
     if(node->getChildren().size() == 3){
        //recursive
        ans = getArgumentList_2(node->getChildren()[0]);
        if(node->getChildren()[2]->getSymbolInfo()->getExtra_info() == "exp int"){
            ans.push_back("int");
        }
        else if(node->getChildren()[2]->getSymbolInfo()->getExtra_info() == "exp float"){
            ans.push_back("float");
        }
     }
     else if(node->getChildren().size() == 1){
        if(node->getChildren()[0]->getSymbolInfo()->getExtra_info() == "exp int"){
            ans.push_back("int");
        }
        else if(node->getChildren()[0]->getSymbolInfo()->getExtra_info() == "exp float"){
            ans.push_back("float");
        }
     }
     
     return ans;
}

vector<string> getArgumentList(Node* node){
     vector<string> ans;
     if(node->getChildren().size() == 1){
        ans = getArgumentList_2(node->getChildren()[0]);
     }
     
     return ans;
}


void check(string str , SymbolInfo* symbol){
    auto symbol_str = symbol->getExtra_info();
    vector<string> v1 , v2;
    string s;
    stringstream ss(str);
 
    while (getline(ss, s, ' ')) {
        v1.push_back(s);
    }

    stringstream ss2(symbol_str);
    while (getline(ss2, s, ' ')) {
        v2.push_back(s);
    }

    if(v1.size() > v2.size()){
        error<<"Too few arguments - "<<yylineno<<endl;
        error_count++;
    }
    else if(v1.size() < v2.size()){
        error<<"Too many arguments - "<<yylineno<<endl;
        error_count++;
    }
    else{
        if(v1[0] != v2[0]){
            error<<"Return type doesnot match - "<<yylineno<<endl;
            error_count++;
        }
        for(int i = 1 ; i < v1.size() ; i++){
            if(v1[i] != v2[i]){
                error<<"Type mismatch for argument - "<<yylineno<<endl;
                error_count++;
            }
        }
    }
}
void check2(vector<string> arg , vector<string> func , string func_name){
    if(arg.size() > func.size()){
        error<<"Line# "<<yylineno<<" : "<<"Too many arguments to function \'"<<func_name<<"\'"<<endl;
        error_count++;
    }
    else if(arg.size() < func.size()){
        error<<"Line# "<<yylineno<<" : "<<"Too few arguments to function \'"<<func_name<<"\'"<<endl;
        error_count++;
    }
    else{
        for(int i = 0 ; i < arg.size() ; i++){
            if(arg[i] != func[i]){
                error<<"Line# "<<yylineno<<" : "<<"Type mismatch for argument  "<<i+1<<" of \'"<<func_name<<"\'"<<endl;
                error_count++;
            }
        }
    }
}

string func_type(string str){
    vector<string> v;
    string s;
    stringstream ss(str);

    while (getline(ss, s, ' ')) {
        v.push_back(s);
    }
    return v[0];
}

vector<string> arg_list_type(string str){
    vector<string> v1 , v2;
    string s;
    stringstream ss(str);

    while (getline(ss, s, ' ')) {
        v1.push_back(s);
    }
    for(int i = 1 ; i < v1.size() ; i++){
        v2.push_back(v1[i]);
    }

    return v2;
}

vector<SymbolInfo* > new_Scope_for_func(Node* node){
    vector<SymbolInfo* > ans;
    if(node->getChildren().size() == 4){
        ans = new_Scope_for_func(node->getChildren()[0]);
        ans.push_back(new SymbolInfo(node->getChildren()[3]->getSymbolInfo()->getName() , node->getChildren()[2]->getSymbolInfo()->getName()));
    }
    
    else if(node->getChildren().size() == 2){
        ans.push_back(new SymbolInfo(node->getChildren()[1]->getSymbolInfo()->getName() , node->getChildren()[0]->getSymbolInfo()->getName()));
    }
    
    return ans;
}



%}

%token ADDOP MULOP BITOP INCOP DECOP RELOP LOGICOP ASSIGNOP NOT
%token IF ELSE FOR DO VOID SWITCH CASE DEFAULT WHILE BREAK CONTINUE RETURN MAIN
%token ID INT FLOAT CHAR DOUBLE CONST_INT CONST_FLOAT CONST_CHAR
%token LCURL RCURL LTHIRD RTHIRD LPAREN RPAREN COMMA SEMICOLON PRINTLN

%code requires{
    #include"Node.cpp"
}
%define api.value.type {Node *}


%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%start start
%%
start : program{
    $$ = new Node(new SymbolInfo("program" , "start") , yylineno);
    $$->addchildren($1);
    logout<<"start : program"<<endl;
    $$->print(1);

    logout << "Total Lines: " << yylineno << endl;
	logout << "Total Errors: " << error_count << endl;

};
program : program unit{
    $$ = new Node(new SymbolInfo("program unit" , "program") , yylineno);
    $$->addchildren($1);$$->addchildren($2);
    logout<<"program : program unit"<<endl;
    
}
| unit{
    $$ = new Node(new SymbolInfo("unit" , "program") , yylineno);
    $$->addchildren($1);
    logout<<"program : unit"<<endl;
}
;
unit : var_declaration{
    $$ = new Node(new SymbolInfo("var_declaration" , "unit") , yylineno);
    $$->addchildren($1);
    logout<<"unit : var_declaration"<<endl;
}
| func_declaration{
    $$ = new Node(new SymbolInfo("func_declaration" , "unit") , yylineno);
    $$->addchildren($1);
    logout<<"unit : func_declaration"<<endl;
}
| func_definition{
    $$ = new Node(new SymbolInfo("func_definition" , "unit") , yylineno);
    $$->addchildren($1);
    logout<<"unit : func_definition"<<endl;
}
;
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON{
    auto parameterList = getParametreList($4);
    string info = ($1)->getSymbolInfo()->getName();
    for(auto i : parameterList){
        info += " " + i;
    }
    transform(info.begin(), info.end(), info.begin(), ::tolower);
    $$ = new Node(new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN SEMICOLON" , "func_declaration") , yylineno);
    $$->addchildren($1);$$->addchildren($2);$$->addchildren($3);
    $$->addchildren($4);$$->addchildren($5);$$->addchildren($6);
    logout<<"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON"<<endl;
    //SymbolInfo symbol(($2)->getSymbolInfo()-> , "func"  , info);
    auto temp = symboltable.lookUp(($2)->getSymbolInfo()->getName());
    if(temp == nullptr){
        symboltable.insert(($2)->getSymbolInfo()->getName() , "func"  , info);
    }
    else{
        if(temp->getType() != "func"){
            error<<"Line# "<<yylineno<<" : "<<"\'"<<($2)->getSymbolInfo()->getName()<<"\' redeclared as different kind of symbol"<<endl;
            error_count++;
        }
        else{
            error<<"Line# "<<yylineno<<" : "<<"\'"<<($2)->getSymbolInfo()->getName()<<"\' same function name"<<endl;
            error_count++;
        }
    }
    /*for(auto i : parameterList){
        debug<<i<<endl;
    }*/
    //symboltable.printAllScp();


}
| type_specifier ID LPAREN RPAREN SEMICOLON{
    string info = ($1)->getSymbolInfo()->getName();
    $$ = new Node(new SymbolInfo("type_specifier ID LPAREN RPAREN SEMICOLON" , "func_declaration") , yylineno);
    $$->addchildren($1);$$->addchildren($2);$$->addchildren($3);
    $$->addchildren($4);$$->addchildren($5);
    logout<<"func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON"<<endl;
    auto temp = symboltable.lookUp(($2)->getSymbolInfo()->getName());
    if(temp == nullptr){
        symboltable.insert(($2)->getSymbolInfo()->getName() , "func" , info);
    }
    else{
        if(temp->getType() != "func"){
            error<<"Line# "<<yylineno<<" : "<<"\'"<<($2)->getSymbolInfo()->getName()<<"\' redeclared as different kind of symbol"<<endl;
            error_count++;
        }
        else{
            error<<"Line# "<<yylineno<<" : "<<"\'"<<($2)->getSymbolInfo()->getName()<<"\' same function name"<<endl;
            error_count++;
        }
    }
}
;
func_definition : type_specifier ID LPAREN parameter_list RPAREN {
    auto parameterList = getParametreList($4);
    string info = ($1)->getSymbolInfo()->getName();
    for(auto i : parameterList){
        info += " " + i;
    }
    transform(info.begin(), info.end(), info.begin(), ::tolower);
    auto temp = symboltable.lookUp(($2)->getSymbolInfo()->getName());
    if(temp == nullptr){
        symboltable.insert(($2)->getSymbolInfo()->getName() , "func"  , info);
    }
    else{
        if(temp->getType() != "func"){
            error<<"Line# "<<yylineno<<" : "<<"\'"<<($2)->getSymbolInfo()->getName()<<"\' redeclared as different kind of symbol"<<endl;
            error_count++;
        }
        else{
            if(temp->getExtra_info() != info){
                error<<"Line# "<<yylineno<<" : "<<"Conflicting types for \'"<<temp->getName()<<"\'"<<endl;
                error_count++;
            }
        }
    }
    symboltable.enterScope();
    isInFunction = true;
    auto temp1 = new_Scope_for_func($4);
    for(auto i : temp1){
        //i->show();
        //cout<<endl<<endl;
        if(!symboltable.insert(i->getName() , i->getType() , "")){
            error<<"Line# "<<yylineno<<" : "<<"Redefinition of parameter \'"<<i->getName()<<"\'"<<endl;
        }
    }
    //symboltable.printAllScp();



} compound_statement{
    
    $$ = new Node(new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN compound_statement" , "func_definition") , yylineno);
    $$->addchildren($1);$$->addchildren($2);$$->addchildren($3);
    $$->addchildren($4);$$->addchildren($5);$$->addchildren($7);
    logout<<"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement"<<endl;
    

    

}
| type_specifier ID LPAREN RPAREN {
    
    string info = ($1)->getSymbolInfo()->getName();
    transform(info.begin(), info.end(), info.begin(), ::tolower);
    auto temp = symboltable.lookUp(($2)->getSymbolInfo()->getName());
    if(temp == nullptr){
        symboltable.insert(($2)->getSymbolInfo()->getName() , "func"  , info);
    }
    else{
        if(temp->getType() != "func"){
            error<<"Line# "<<yylineno<<" : "<<"\'"<<($2)->getSymbolInfo()->getName()<<"\' redeclared as different kind of symbol"<<endl;
            error_count++;
        }
        else{
            if(temp->getExtra_info() != info){
                error<<"Line# "<<yylineno<<" : "<<"Conflicting types for \'"<<temp->getName()<<"\'"<<endl;
                error_count++;
            }
        }
    }
    symboltable.enterScope();
    isInFunction = true;
    

} compound_statement{
    $$ = new Node(new SymbolInfo("type_specifier ID LPAREN RPAREN compound_statement" , "func_definition") , yylineno);
    $$->addchildren($1);$$->addchildren($2);$$->addchildren($3);
    $$->addchildren($4);$$->addchildren($6);
    logout<<"func_definition : type_specifier ID LPAREN RPAREN compound_statement"<<endl;
}

;
parameter_list : parameter_list COMMA type_specifier ID{
    $$ = new Node(new SymbolInfo("parameter_list COMMA type_specifier ID" , "parameter_list") , yylineno);
    $$->addchildren($1);$$->addchildren($2);$$->addchildren($3);$$->addchildren($4);
    logout<<"parameter_list : parameter_list COMMA type_specifier ID"<<endl;
}
| parameter_list COMMA type_specifier{
    $$ = new Node(new SymbolInfo("parameter_list COMMA type_specifier" , "parameter_list") , yylineno);
    $$->addchildren($1);$$->addchildren($2);$$->addchildren($3);
    logout<<"parameter_list : parameter_list COMMA type_specifier"<<endl;
}
| type_specifier ID{
    $$ = new Node(new SymbolInfo("type_specifier ID" , "parameter_list") , yylineno);
    $$->addchildren($1);$$->addchildren($2);
    logout<<"parameter_list : type_specifier ID"<<endl;
}
| type_specifier{
    $$ = new Node(new SymbolInfo("type_specifier" , "parameter_list") , yylineno);
    $$->addchildren($1);
    logout<<"parameter_list : type_specifier"<<endl;
}
;
compound_statement : LCURL 
{
    if(!isInFunction) symboltable.enterScope(); 
    isInFunction = false;
} statements RCURL{
    $$ = new Node(new SymbolInfo("LCURL statements RCURL" , "compound_statement") , yylineno);
    $$->addchildren($1);$$->addchildren($3);$$->addchildren($4);
    logout<<"compound_statement : LCURL statements RCURL"<<endl;
    //symboltable.printAllScp();
    symboltable.exitScope(false);

}
| LCURL RCURL{
    $$ = new Node(new SymbolInfo("LCURL RCURL" , "compound_statement") , yylineno);
    $$->addchildren($1);$$->addchildren($2);
    logout<<"compound_statement : LCURL RCURL"<<endl;
}
;
var_declaration : type_specifier declaration_list SEMICOLON{
    $$ = new Node(new SymbolInfo("type_specifier declaration_list SEMICOLON" , "var_declaration") , yylineno);
    $$->addchildren($1);$$->addchildren($2);$$->addchildren($3);
    logout<<"var_declaration : type_specifier declaration_list SEMICOLON"<<endl;

    auto type_spec = ($1)->getChildren();
    auto name = type_spec[0]->getSymbolInfo()->getName();

    /*if(name == "VOID"){
        error<<"Variable or field \'"<< <<"\' declared void"<<endl;
        error_count++;
    }*/

    auto variables = getVar_from_decl_list($2 , name);
    for(auto i : variables){
        debug << name << endl;
        if(name == "void"){
            error<<"Line# "<<yylineno<<" : "<<"Variable or field \'"<<i->getName()<<"\' declared void"<<endl;
            error_count++;
            delete i;
            continue;
        }
        auto flag = symboltable.insert(i->getName() , i->getType() , i->getExtra_info());
        if(!flag){
            //symboltable.insert(i->getName() , i->getType() , i->getExtra_info());
            // if(i->getType() )
            // error<<"Redefinition of parameter "<<i->getName()<<endl;
            // error_count++;
            error<<"Line# "<<yylineno<<" : "<<"Conflicting types for \'"<<i->getName()<<"\'"<<endl;
            error_count++;
        }
        // else{
        //     if(flag->getType() != i->getType()){
        //         error<<"Line# "<<yylineno<<" : "<<"Conflicting types for \'"<<i->getName()<<"\'"<<endl;
        //         error_count++;
        //     }
        //     else if(flag->getType() == i->getType()){
        //         //error<<"Line# "<<yylineno<<" : "<<"Redefinition of parameter "<<i->getName()<<endl;
        //         //error_count++;
        //     }
        // }
        delete i;
    }
   // symboltable.printAllScp();


}
;
type_specifier : INT{
    $$ = new Node(new SymbolInfo("INT" , "type_specifier") , yylineno);
    $$->addchildren($1);
    logout<<"type_specifier : INT"<<endl;
}
| FLOAT{
    $$ = new Node(new SymbolInfo("FLOAT" , "type_specifier") , yylineno);
    $$->addchildren($1);
    logout<<"type_specifier : FLOAT"<<endl;
}
| VOID{
    $$ = new Node(new SymbolInfo("VOID" , "type_specifier") , yylineno);
    $$->addchildren($1);
    logout<<"type_specifier : VOID"<<endl;
}
;
declaration_list : declaration_list COMMA ID{
    $$ = new Node(new SymbolInfo("declaration_list COMMA ID" , "declaration_list") , yylineno);
    $$->addchildren($1);$$->addchildren($2);$$->addchildren($3);
    logout<<"declaration_list : declaration_list COMMA ID"<<endl;
}
| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD{
    $$ = new Node(new SymbolInfo("declaration_list COMMA ID LTHIRD CONST_INT RTHIRD" , "declaration_list") , yylineno);
    $$->addchildren($1);$$->addchildren($2);$$->addchildren($3);
    $$->addchildren($4);$$->addchildren($5);$$->addchildren($6);
    logout<<"declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD"<<endl;
}
| ID{
    $$ = new Node(new SymbolInfo("ID" , "declaration_list") , yylineno);
    $$->addchildren($1);
    logout<<"declaration_list : ID"<<endl;
}
| ID LTHIRD CONST_INT RTHIRD{
    $$ = new Node(new SymbolInfo("ID LTHIRD CONST_INT RTHIRD" , "declaration_list") , yylineno);
    $$->addchildren($1);$$->addchildren($2);$$->addchildren($3);
    $$->addchildren($4);
    logout<<"declaration_list : ID LTHIRD CONST_INT RTHIRD"<<endl;
}
;
statements : statement{
    $$ = new Node(new SymbolInfo("statement" , "statements") , yylineno);
    $$->addchildren($1);
    logout<<"statements : statement"<<endl;
}
| statements statement{
    $$ = new Node(new SymbolInfo("statements statement" , "statements") , yylineno);
    $$->addchildren($1);$$->addchildren($2);
    logout<<"statements : statements statement"<<endl;
}
;
statement : var_declaration{
    $$ = new Node(new SymbolInfo("var_declaration" , "statement") , yylineno);
    $$->addchildren($1);
    logout<<"statement : var_declaration"<<endl;
}
| expression_statement{
     $$ = new Node(new SymbolInfo("expression_statement" , "statement") , yylineno);
    $$->addchildren($1);
    logout<<"statement : expression_statement"<<endl;
}
| compound_statement{
     $$ = new Node(new SymbolInfo("compound_statement" , "statement") , yylineno);
    $$->addchildren($1);
    logout<<"statement : compound_statement"<<endl;
}
| FOR LPAREN expression_statement expression_statement expression RPAREN statement{
    $$ = new Node(new SymbolInfo("FOR LPAREN expression_statement expression_statement expression RPAREN statement" , "statement") , yylineno);
    $$->addchildren($1);$$->addchildren($2);$$->addchildren($3);$$->addchildren($4);
    $$->addchildren($5);$$->addchildren($6);$$->addchildren($7);
    logout<<"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement"<<endl;
}
| IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE{
    $$ = new Node(new SymbolInfo("IF LPAREN expression RPAREN statement" , "statement") , yylineno);
    $$->addchildren($1);$$->addchildren($2);$$->addchildren($3);$$->addchildren($4);
    $$->addchildren($5);
    logout<<"statement : IF LPAREN expression RPAREN statement"<<endl;
}

| IF LPAREN expression RPAREN statement ELSE statement{
    $$ = new Node(new SymbolInfo("IF LPAREN expression RPAREN statement ELSE statement" , "statement") , yylineno);
    $$->addchildren($1);$$->addchildren($2);$$->addchildren($3);$$->addchildren($4);
    $$->addchildren($5);$$->addchildren($6);$$->addchildren($7);
    logout<<"statement : IF LPAREN expression RPAREN statement ELSE statement"<<endl;
}
| WHILE LPAREN expression RPAREN statement{
    $$ = new Node(new SymbolInfo("WHILE LPAREN expression RPAREN statement" , "statement") , yylineno);
    $$->addchildren($1);$$->addchildren($2);$$->addchildren($3);$$->addchildren($4);
    $$->addchildren($5);
    logout<<"statement : WHILE LPAREN expression RPAREN statement"<<endl;
}
| PRINTLN LPAREN ID RPAREN SEMICOLON{
    $$ = new Node(new SymbolInfo("PRINTLN LPAREN ID RPAREN SEMICOLON" , "statement") , yylineno);
    $$->addchildren($1);$$->addchildren($2);$$->addchildren($3);$$->addchildren($4);
    $$->addchildren($5);
    logout<<"statement : PRINTLN LPAREN ID RPAREN SEMICOLON"<<endl;
}
| RETURN expression SEMICOLON{
    $$ = new Node(new SymbolInfo("RETURN expression SEMICOLON" , "statement") , yylineno);
    $$->addchildren($1);$$->addchildren($2);$$->addchildren($3);
    logout<<"statement : RETURN expression SEMICOLON"<<endl;
}
;
expression_statement : SEMICOLON{
    $$ = new Node(new SymbolInfo("SEMICOLON" , "expression_statement") , yylineno);
    $$->addchildren($1);
    logout<<"expression_statement : SEMICOLON"<<endl;
}
| expression SEMICOLON{
    $$ = new Node(new SymbolInfo("expression SEMICOLON" , "expression_statement") , yylineno);
    $$->addchildren($1);$$->addchildren($2);
    logout<<"expression_statement : expression SEMICOLON"<<endl;
}
;
variable : ID{
    string type;
    logout<<"variable : ID"<<endl;
    if(symboltable.lookUp(($1)->getSymbolInfo()->getName()) == nullptr){
        error<<"Line# "<<yylineno<<" : "<<"Undeclared variable \'"<<($1)->getSymbolInfo()->getName()<<"\'"<<endl;
        error_count++;
        type = "exp int";
    }
    else{
        auto temp = symboltable.lookUp(($1)->getSymbolInfo()->getName());
        //type = "exp " + temp->getType();
        //debug<<endl<<type<<endl;
        transform(type.begin(), type.end(), type.begin(), ::tolower);
        if(temp->getExtra_info() == "array"){
            error<<"Line# "<<yylineno<<" : "<<temp->getName()<<" is not an array"<<endl;
            error_count++;
        }
        
    }
    $$ = new Node(new SymbolInfo("ID" , "variable" , type) , yylineno);
    $$->addchildren($1);

}
| ID LTHIRD expression RTHIRD{
    string type;
    logout<<"variable : ID LTHIRD expression RTHIRD"<<endl;
    if(symboltable.lookUp(($1)->getSymbolInfo()->getName()) == nullptr){
        error<<"Line# "<<yylineno<<" : "<<"Undeclared variable \'"<<($1)->getSymbolInfo()->getName()<<"\'"<<endl;
        error_count++;
        type = "exp int";
        //debug<<"in the look up"<<endl;
    }
    else{
        auto temp = symboltable.lookUp(($1)->getSymbolInfo()->getName());
        type = "exp " + temp->getType();
        transform(type.begin(), type.end(), type.begin(), ::tolower);
        //auto temp = symboltable.lookUp(($1)->getSymbolInfo()->getName());
        //debug<<"variable found look up"<<($3)->getSymbolInfo()->getExtra_info()<<endl;
        if(temp->getExtra_info() != "array"){
            //error<<"Fucntion / normal variable used as array variable - "<<yylineno<<endl;
            //error_count++;
            error<<"Line# "<<yylineno<<" : \'"<<($1)->getSymbolInfo()->getName()<<"\' is not an array"<<endl;
        }
        else{
           // debug << "here" << endl;
            if(($3)->getSymbolInfo()->getExtra_info() != "exp int"){
                //debug<<($2)->getSymbolInfo()->getExtra_info() << "abc" <<endl<<endl;
                error<<"Line# "<<yylineno<<" : "<<"Array subscript is not an integer"<<endl;
                error_count++;
            }

        }
    }

    $$ = new Node(new SymbolInfo("ID LTHIRD expression RTHIRD" , "variable" , type) , yylineno);
    $$->addchildren($1);$$->addchildren($2);$$->addchildren($3);$$->addchildren($4);
}
;
expression : logic_expression{
    $$ = new Node(new SymbolInfo("logic_expression" , "expression" , ($1)->getSymbolInfo()->getExtra_info()) , yylineno);
    //debug<<"expression - "<<($1)->getSymbolInfo()->getExtra_info()<<endl;
    $$->addchildren($1);
    logout<<"expression : logic_expression"<<endl;
}

| variable ASSIGNOP logic_expression{
    string type = ($1)->getSymbolInfo()->getExtra_info();
    if(($3)->getSymbolInfo()->getExtra_info() == "exp void"){
        error<<"Line# "<<yylineno<<" : "<<"Void cannot be used in expression"<<endl;
        type = "exp int";
        error_count++;
    }
    $$ = new Node(new SymbolInfo("variable ASSIGNOP logic_expression" , "expression" , type) , yylineno);
    $$->addchildren($1);$$->addchildren($2);$$->addchildren($3);
    logout<<"expression : variable ASSIGNOP logic_expression"<<endl;
    if(($1)->getSymbolInfo()->getExtra_info() == "exp int" && ($3)->getSymbolInfo()->getExtra_info() == "exp float"){
        error<<"Line# "<<yylineno<<" : "<<"Warning: possible loss of data in assignment of FLOAT to INT"<<endl;
        error_count++;
    }
    
    
}

;
logic_expression : rel_expression{
    string type = ($1)->getSymbolInfo()->getExtra_info();
    if(($1)->getSymbolInfo()->getExtra_info() == "exp void"){
        error<<"Line# "<<yylineno<<" : "<<"Void cannot be used in expression"<<endl;
        type = "exp int";
        error_count++;
    }
    $$ = new Node(new SymbolInfo("rel_expression" , "logic_expression" , type) , yylineno);
    $$->addchildren($1);
    logout<<"logic_expression : rel_expression"<<endl;
    
}
| rel_expression LOGICOP rel_expression{
    $$ = new Node(new SymbolInfo("rel_expression LOGICOP rel_expression" , "expression" , "exp int") , yylineno);
    $$->addchildren($1);$$->addchildren($2);$$->addchildren($3);
    logout<<"logic_expression : rel_expression LOGICOP rel_expression"<<endl;
    if(($1)->getSymbolInfo()->getExtra_info() == "exp void" || ($3)->getSymbolInfo()->getExtra_info() == "exp void"){
        error<<"Line# "<<yylineno<<" : "<<"Void cannot be used in expression"<<endl;
        error_count++;
    }
}
;
rel_expression : simple_expression{
    string type = ($1)->getSymbolInfo()->getExtra_info();
    if(($1)->getSymbolInfo()->getExtra_info() == "exp void"){
        error<<"Line# "<<yylineno<<" : "<<"Void cannot be used in expression"<<endl;
        type = "exp int";
        error_count++;
    }
    $$ = new Node(new SymbolInfo("simple_expression" , "rel_expression" , type) , yylineno);
    $$->addchildren($1);
    logout<<"rel_expression : simple_expression"<<endl;
    
}
| simple_expression RELOP simple_expression{
    $$ = new Node(new SymbolInfo("simple_expression RELOP simple_expression" , "rel_expression" , "exp int") , yylineno);
    $$->addchildren($1);$$->addchildren($2);$$->addchildren($3);
    logout<<"rel_expression : simple_expression RELOP simple_expression"<<endl;
    if(($1)->getSymbolInfo()->getExtra_info() == "exp void" || ($3)->getSymbolInfo()->getExtra_info() == "exp void"){
        error<<"Line# "<<yylineno<<" : "<<"Void cannot be used in expression"<<endl;
        error_count++;
    }
}
;
simple_expression : term{
    $$ = new Node(new SymbolInfo("term" , "simple_expression" , ($1)->getSymbolInfo()->getExtra_info()) , yylineno);
    $$->addchildren($1);
    logout<<"simple_expression : term"<<endl;
}
| simple_expression ADDOP term{
    if(($1)->getSymbolInfo()->getExtra_info() == "exp void" || ($3)->getSymbolInfo()->getExtra_info() == "exp void"){
        error<<"Line# "<<yylineno<<" : "<<"Void cannot be used in expression"<<endl;
        error_count++;
    }
    string type = "exp int";
    if(($1)->getSymbolInfo()->getExtra_info() == "exp float" || ($3)->getSymbolInfo()->getExtra_info() == "exp float"){
        type = "exp float";     
    }
    $$ = new Node(new SymbolInfo("simple_expression ADDOP term" , "simple_expression" , type) , yylineno);
    $$->addchildren($1);$$->addchildren($2);$$->addchildren($3);
    logout<<"simple_expression : simple_expression ADDOP term"<<endl;

}
;
term : unary_expression{
    
    $$ = new Node(new SymbolInfo("unary_expression" , "term" , ($1)->getSymbolInfo()->getExtra_info()) , yylineno);
    $$->addchildren($1);
    logout<<"term : unary_expression"<<endl;
}
| term MULOP unary_expression{
   // debug<<"%% error - "<<($1)->getSymbolInfo()->getExtra_info()<< "  "<<($3)->getSymbolInfo()->getExtra_info()<<endl; 
    if(($2)->getSymbolInfo()->getName() == "%"){
        if(($1)->getSymbolInfo()->getExtra_info() == "exp int" && ($3)->getSymbolInfo()->getExtra_info() == "exp int"){
        //error<<"expression cannot be void - "<<yylineno<<endl;
        }
        else{
            error<<"Line# "<<yylineno<<" : "<<"Operands of modulus must be integers"<<endl;
            error_count++;
        }
    }
    if(($1)->getSymbolInfo()->getExtra_info() == "exp void" || ($3)->getSymbolInfo()->getExtra_info() == "exp void"){
        error<<"Line# "<<yylineno<<" : "<<"Void cannot be used in expression"<<endl;
        error_count++;
    }

    string type = "exp int";
    if(($1)->getSymbolInfo()->getExtra_info() == "exp float" || ($3)->getSymbolInfo()->getExtra_info() == "exp float"){
        type = "exp float";     
    }
    $$ = new Node(new SymbolInfo("term MULOP unary_expression" , "term" , type) , yylineno);
    $$->addchildren($1);$$->addchildren($2);$$->addchildren($3);
    logout<<"term : term MULOP unary_expression"<<endl;
}
;
unary_expression : ADDOP unary_expression{
    if(($2)->getSymbolInfo()->getExtra_info() == "exp void"){
        error<<"Line# "<<yylineno<<" : "<<"Void cannot be used in expression"<<endl;
        error_count++;
        ($2)->getSymbolInfo()->setExtra_info("exp int");
    }
    
    $$ = new Node(new SymbolInfo("ADDOP unary_expression" , "unary_expression" , ($2)->getSymbolInfo()->getExtra_info()) , yylineno);
    $$->addchildren($1);$$->addchildren($2);
    logout<<"unary_expression : ADDOP unary_expression"<<endl;
}
| NOT unary_expression{
    if(($2)->getSymbolInfo()->getExtra_info() == "exp void"){
        error<<"Line# "<<yylineno<<" : "<<"Void cannot be used in expression"<<endl;
        error_count++;
        //($2)->getSymbolInfo->setExtra_info("exp int");
    }
    $$ = new Node(new SymbolInfo("NOT unary_expression" , "unary_expression" , "exp int") , yylineno);
    $$->addchildren($1);$$->addchildren($2);
    logout<<"unary_expression : NOT unary_expression"<<endl;
}
| factor{
    $$ = new Node(new SymbolInfo("factor" , "unary_expression" , ($1)->getSymbolInfo()->getExtra_info()) , yylineno);
   //debug<<"factor - "<<($1)->getSymbolInfo()->getExtra_info()<<endl;
    $$->addchildren($1);
    logout<<"unary_expression : factor"<<endl;
}
;
factor : variable{
    $$ = new Node(new SymbolInfo("variable" , "factor" , ($1)->getSymbolInfo()->getExtra_info()) , yylineno);
    $$->addchildren($1);
    logout<<"factor : variable"<<endl;
}
| ID LPAREN argument_list RPAREN{
    auto arg_list = getArgumentList($3);
    /*for(auto i : arg_list){
        debug<<i<<" ";
    }*/
    string type = "INT";
    auto temp = symboltable.lookUp(($1)->getSymbolInfo()->getName());
    if(temp == nullptr){
        error<<"Line# "<<yylineno<<" : "<<"Undeclared function \'"<<($1)->getSymbolInfo()->getName()<<"\'"<<endl;
        error_count++;
    }
    else{
        type = func_type(temp->getExtra_info());
        vector<string> s = arg_list_type(temp->getExtra_info());
        // //debug<<"From SymbolInfo - "<<temp->getExtra_info()<<endl;
        // //debug<<"Type - "<<type<<endl;
        // for(int i = 0 ; i < s.size() ; i++){
        //     debug<<s[i]<<" ";
        // }
        check2(arg_list , s , temp->getName());
    }
    transform(type.begin(), type.end(), type.begin(), ::tolower);
   
    $$ = new Node(new SymbolInfo("ID LPAREN argument_list RPAREN" , "factor" , "exp " + type) , yylineno);
    $$->addchildren($1);$$->addchildren($2);$$->addchildren($3);$$->addchildren($4);
    logout<<"factor : ID LPAREN argument_list RPAREN"<<endl;

}
| LPAREN expression RPAREN{
    $$ = new Node(new SymbolInfo("LPAREN expression RPAREN" , "factor" , ($2)->getSymbolInfo()->getExtra_info()) , yylineno);
    $$->addchildren($1);$$->addchildren($2);$$->addchildren($3);
    logout<<"factor : LPAREN expression RPAREN"<<endl;
}
| CONST_INT{
    $$ = new Node(new SymbolInfo("CONST_INT" , "factor", "exp int") , yylineno);
    $$->addchildren($1);
    logout<<"factor : CONST_INT"<<endl;
}
| CONST_FLOAT{
    $$ = new Node(new SymbolInfo("CONST_FLOAT" , "factor" , "exp float") , yylineno);
    $$->addchildren($1);
    logout<<"factor : CONST_FLOAT"<<endl;
}
| variable INCOP{
    $$ = new Node(new SymbolInfo("variable INCOP" , "factor" , ($1)->getSymbolInfo()->getExtra_info()) , yylineno);
    $$->addchildren($1);$$->addchildren($2);
    logout<<"factor : variable INCOP"<<endl;
}
| variable DECOP{
    $$ = new Node(new SymbolInfo("variable DECOP" , "factor" , ($1)->getSymbolInfo()->getExtra_info()) , yylineno);
    $$->addchildren($1);$$->addchildren($2);
    logout<<"factor : variable DECOP"<<endl;
}
;
argument_list : arguments{
    $$ = new Node(new SymbolInfo("arguments" , "argument_list") , yylineno);
    $$->addchildren($1);
    logout<<"argument_list : arguments"<<endl;
}
|   {
    $$ = new Node(new SymbolInfo("" , "argument_list") , yylineno);
    logout<<"argument_list : "<<endl;
    
}
;
arguments : arguments COMMA logic_expression{
    $$ = new Node(new SymbolInfo("arguments COMMA logic_expression" , "arguments") , yylineno);
    $$->addchildren($1);$$->addchildren($2);$$->addchildren($3);
    logout<<"arguments : arguments COMMA logic_expression"<<endl;
}
| logic_expression{
    $$ = new Node(new SymbolInfo("logic_expression" , "arguments") , yylineno);
    $$->addchildren($1);
    logout<<"arguments : logic_expression"<<endl;
}
;
%%

int main(int argc, char *argv[])
{
    freopen ("parsetree.txt", "w", stdout);
    FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	

	yyin= fin;
    yyparse();
    exit(0);
}
