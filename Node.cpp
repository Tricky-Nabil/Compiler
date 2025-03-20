#ifndef __NODE_CPP__
#define __NODE_CPP__

#include "Scoptable.cpp"



class Node{
    vector<Node *> children;
    SymbolInfo* symbol;
    int first_line , last_line;
    public:
    Node(SymbolInfo* s , int line){
        symbol = s;
        first_line = last_line = line;
    }
    void addchildren(Node * n){
        if(children.size() == 0)
            first_line = n->get_firstLine();
        children.push_back(n);
        last_line = n->get_lastline();
        
    }

    void remove_all_children(){

    }

    SymbolInfo* getSymbolInfo(){
        return symbol;
    }

    int get_firstLine(){
        return first_line;
    }

    int get_lastline(){
        return last_line;
    }

    vector<Node *> getChildren(){
        return children;
    }
    void print(int space){
        symbol->show();
        if(children.size() != 0)
            cout<<" \t"<<"<Line: "<<first_line<<"-"<<last_line<<">"<<endl;
        else
            cout<<"\t"<<"<Line: "<<first_line<<">"<<endl;
        for(int i = 0 ; i < children.size() ; i++){
            for(int j = 1 ; j <= space ; j++){
                cout<<" ";
            }
            children[i]->print(space + 1);
        }


    }
    ~Node(){
        delete symbol;
    }
    

};

#endif