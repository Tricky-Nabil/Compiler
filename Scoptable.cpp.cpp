#ifndef __SCOPETABLE_CPP__
#define __SCOPETABLE_CPP__

#include<bits/stdc++.h>
using namespace std;

static unsigned long long SDBMHash(string str) {
	unsigned long long hash = 0;
	unsigned int i = 0;
	unsigned int len = str.length();

	for (i = 0; i < len; i++)
	{
		hash = (str[i]) + (hash << 6) + (hash << 16) - hash;
	}

	return hash;
}

class SymbolInfo{
    
    string name;
    string type;
    SymbolInfo* next;
    string extra_info;
    public:
    SymbolInfo(){
        next = nullptr;
    }
    SymbolInfo(string n , string t){
        name = n;
        type = t;
        next = nullptr;
        extra_info = "";
    }
    SymbolInfo(string n , string t , string info){
        name = n;
        type = t;
        next = nullptr;
        extra_info = info;
    }

    void setExtra_info(string s){
        extra_info = s;
    }

    string getExtra_info(){
        return extra_info;
    }

    void setName(string n){
        name = n;
    }
    void setType(string t){
        type = t;
    }
    string getName(){
        return name;
    }
    string getType(){
        return type;
    }
    void setNext(SymbolInfo* s){
        next = s;
    }
    SymbolInfo* getNext(){
        return next;
    }
     
    void show(){
        cout<<type<<" : "<<name;
    }
    ~SymbolInfo(){
        delete next;
    }
};

class ScopeTable{
    int bucket;
    SymbolInfo** hashTable;
    ScopeTable* parent;
    int Scp_num;

    public:
    ScopeTable(int n , int scp , ScopeTable* p = nullptr){
        bucket = n;
        Scp_num = scp;
        parent = p;
        hashTable = new SymbolInfo*[bucket];
        for(int i = 0 ; i < bucket ; i++){
            
            hashTable[i] = nullptr;
        }
    }

    int getScpNumber(){
        return Scp_num;
    }

    int getHash(string str){
        return SDBMHash(str) % bucket;
    }

    void setParent(ScopeTable* s){
        parent = s;
    }

    ScopeTable* getParent(){
        return parent;
    }

    bool insert(string name , string type , string info){
        auto index = getHash(name) ;
        //cout<<"Hash Value: "<<index + 1<<endl;
       // pos1 = index + 1;
        int cnt = 2;
        auto head = hashTable[index];
       // int dummy1 , dummy2;
        if(lookup(name) != nullptr){
           //delete head;
            return false;
        }
            //return false;
        if(hashTable[index] == nullptr){
            hashTable[index] = new SymbolInfo(name , type , info);
            //pos2 = 1;
            return true;
            
            //SymbolInfo temp(name , type);
        }
            //hashTable[index] = new SymbolInfo(name , type);
        else{
            
            while(head->getNext() != nullptr){
                head = head->getNext();
                cnt++;
            }
            //pos2 = cnt;

            head->setNext(new SymbolInfo(name , type , info));
        }
       // delete head;
        return true;

        
        

    }

    bool Delete(string name){
        auto index = getHash(name);
        //pos1 = index + 1;
        auto head = hashTable[index];
        if(head == nullptr){
            //delete head;
            return false;
        }
            //return false;
        
        if(head->getName() == name){
            hashTable[index] = head->getNext();
           // pos2 = 1;
            delete head;
            return true;
        }
        else{
            int cnt = 2;
            auto prev = head;
            head = head->getNext();
            while(head != nullptr){
                if(head->getName() == name){
                    prev->setNext(head->getNext());
                    //pos2 = cnt;
                    delete head;
                    return true;
                }
                cnt++;
                prev = head;
                head = head->getNext();
            }

        }
        
        return false;
 
    }

    void print(){
        for(int i = 0 ; i < bucket ; i++){

            auto head = hashTable[i];
            if(head == nullptr){
                //cout<<"Null Position Detected\n";
                continue;
            }
                
            cout<<"\t"<<i + 1<<"--> ";
            while(head != nullptr){
                //cout<<head<<" " << head->getNext() << endl;
                head->show();   
                head = head->getNext();
                
            }
            cout<<endl;
        }

    }

    SymbolInfo* lookup(string name){
        //SymbolInfo* p = nullptr;
        auto index  = getHash(name);
        //pos1 = index + 1;
        auto head = hashTable[index];
        int cnt = 1;
        while(head != nullptr){
            if(head->getName() == name){
                //pos2 = cnt;
                //delete head;
                return head;
            }
            cnt++;
            head = head->getNext();
        }
       // delete head;
        
        return nullptr;

    }

    ~ScopeTable(){
        for(int i = 0 ; i < bucket ; i++){
            delete hashTable[i];
        }
        delete[] hashTable;
    }
};

class SymbolTable{
    int bucket;
    ScopeTable* curr;
    int Scoptable_Num;

    public:
    SymbolTable(int n){
        bucket = n;
        curr = nullptr;
        Scoptable_Num = 0;
        enterScope();

    }
    void setBucketSize(int n){
        bucket = n;
    }

    void enterScope(){
        Scoptable_Num++;
        auto temp = curr;
        curr = new ScopeTable(bucket , Scoptable_Num);
        curr->setParent(temp);
    }

    
    void exitScope(bool flag){
        if(flag){
            exitScope_Extend();
            return ;
        }
        else if(curr->getParent() == nullptr){
            return;
        }
        auto temp = curr;
        curr = curr->getParent();
        delete temp;
        
    }

    bool insert(string name , string type , string info){
        bool flag = curr->insert(name , type , info);
        return flag;
    }

    bool remove(string name){
        bool flag = curr->Delete(name);
        return flag;
    }

    SymbolInfo* lookUp(string name){
        
        SymbolInfo* flag = nullptr;
        auto temp  = curr;
        
        while(temp != nullptr){
            flag = temp->lookup(name);
            if(flag != nullptr){
                return flag;
                
            }   
            temp = temp->getParent();

        }
        return flag;
    }

    void prntCurScp(){
        
        curr->print();
    }

    void printAllScp(){
        auto temp = curr;
        
        while(temp != nullptr){
            cout<<"\tScopeTable# "<<temp->getScpNumber()<<endl;
            temp->print();
            temp = temp->getParent();
        }
    }

    ~SymbolTable(){
        delete curr;
    }

    private : void exitScope_Extend(){
        
        while(curr != nullptr){
            cout<<"\tScopeTable# "<<curr->getScpNumber()<<" removed\n";
            auto temp = curr;
            curr = curr->getParent();
            delete temp;
        }
    }
    
};

#endif