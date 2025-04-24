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
    public:
    SymbolInfo(){
        next = nullptr;
    }
    SymbolInfo(string n , string t){
        name = n;
        type = t;
        SymbolInfo();
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
        cout<<"<"<<name<<","<<type<<"> ";
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
            //hashTable[i] = new SymbolInfo();
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

    bool insert(string name , string type , int &pos1 , int &pos2){
        auto index = getHash(name) ;
        pos1 = index + 1;
        int cnt = 2;
        auto head = hashTable[index];
        int dummy1 , dummy2;
        if(lookup(name , dummy1 , dummy2) != nullptr){
           //delete head;
            return false;
        }
            //return false;
        if(hashTable[index] == nullptr){
            hashTable[index] = new SymbolInfo(name , type);
            pos2 = 1;
            return true;
            
            //SymbolInfo temp(name , type);
        }
            //hashTable[index] = new SymbolInfo(name , type);
        else{
            
            while(head->getNext() != nullptr){
                head = head->getNext();
                cnt++;
            }
            pos2 = cnt;

            head->setNext(new SymbolInfo(name , type));
        }
       // delete head;
        return true;

        
        

    }

    bool Delete(string name , int &pos1 , int &pos2){
        auto index = getHash(name);
        pos1 = index + 1;
        auto head = hashTable[index];
        if(head == nullptr){
            //delete head;
            return false;
        }
            //return false;
        
        if(head->getName() == name){
            hashTable[index] = head->getNext();
            pos2 = 1;
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
                    pos2 = cnt;
                    delete head;
                    return true;
                }
                cnt++;
                prev = head;
                head = head->getNext();
            }

        }
        //delete head;
        return false;
        
        
        
        /*else{
            auto prev = head;
            //head = head->getNext();
            while(head != nullptr){
                if(head->getName() == name){
                    prev->setNext(head->getNext());
                    if(head == prev){
                        
                        hashTable[index] = head->getNext();
                        //delete head;
                        return true;
                    }
                    //cout<<"Before Delete";
                    delete head;
                    //cout<<"After Delete"; 
                    if(prev == head){
                        delete prev;
                        delete head;
                    }

                    return true;
                }
                    
                prev = head;
                head = head->getNext();

            }
        }*/
        
        
    }

    void print(){
        for(int i = 0 ; i < bucket ; i++){
            cout<<"\t"<<i + 1<<"--> ";
            auto head = hashTable[i];
            while(head != nullptr){
                head->show();
                
                head = head->getNext();
            }
            cout<<endl;
        }

    }

    SymbolInfo* lookup(string name , int &pos1 , int &pos2){
        //SymbolInfo* p = nullptr;
        auto index  = getHash(name);
        pos1 = index + 1;
        auto head = hashTable[index];
        int cnt = 1;
        while(head != nullptr){
            if(head->getName() == name){
                pos2 = cnt;
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
    SymbolTable(){
        curr = nullptr;
        Scoptable_Num = 0;

    }
    /*SymbolTable(int n){
        bucket = n;
        curr = nullptr;
        enterScope();

    }*/
    void setBucketSize(int n){
        bucket = n;
    }

    void enterScope(){
        Scoptable_Num++;
        cout<<"\tScopeTable# "<<Scoptable_Num<<" created\n";
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
            cout<<"\tScopeTable# 1 cannot be removed\n";
            return;
        }
        
            //return;
        cout<<"\tScopeTable# "<<curr->getScpNumber()<<" removed\n";
        auto temp = curr;
        curr = curr->getParent();
        //delete temp;
        //Scoptable_Num--;
    }

    bool insert(string name , string type , int &pos1 , int &pos2 , int &scptable){
        scptable = curr->getScpNumber();
        bool flag = curr->insert(name , type , pos1 , pos2);
        return flag;
    }

    bool remove(string name , int &pos1 , int &pos2 , int &scptable){
        scptable = curr->getScpNumber();
        bool flag = curr->Delete(name , pos1 , pos2);
        return flag;
    }

    SymbolInfo* lookUp(string name , int &scptable , int &pos1 , int &pos2){
        //bool flag = false;
        SymbolInfo* flag = nullptr;
        auto temp  = curr;
        //int temp_scp = Scoptable_Num;
        while(temp != nullptr){
            flag = temp->lookup(name , pos1 , pos2);
            if(flag != nullptr){
                scptable = temp->getScpNumber();
                return flag;
                //return temp;
            }
            //temp_scp--;    
            temp = temp->getParent();

        }
        return flag;
    }

    void prntCurScp(){
        cout<<"\tScopeTable# "<<curr->getScpNumber()<<endl;
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




int main(){
    int bucket;
    int pos1 , pos2 , scptable;
    int cmd = 1;
    //SymbolTable s = new SymbolTable()
    //freopen("input.txt", "r", stdin);
    SymbolTable s;
    //s.setBucketSize(1);
    //s.enterScope();
    //s.insert("I" , "var" , pos1 , pos2 , scptable);
    //cout<<pos1<<" "<<pos2<<endl;
    //s.insert("J" , "var" , pos1 , pos2 , scptable);
    //cout<<pos1<<" "<<pos2<<endl;
    //s.insert("K" , "var" , pos1 , pos2 , scptable);
    //cout<<pos1<<" "<<pos2<<endl;
    //s.remove("i" , pos1 , pos2 , scptable);
    //cout<<s.lookUp("I" , pos1 , pos2 , scptable)<<endl;
   // s.remove("J" , pos1 , pos2 , scptable);
    //s.prntCurScp();
    //cout<<s.lookUp("i");
    //s.remove("i");
    fstream file;
    file.open("input.txt" , ios::in);
    freopen("output.txt", "w", stdout);
    string str , param1  , param2  , param3 ;
    bool flag = 0;
    while(getline(file , str)){

        if(!flag){
            bucket = stoi(str);
            
            s.setBucketSize(bucket);
            s.enterScope();
            flag = 1;
            continue;
        }
        cout<<"Cmd "<<cmd++<<": "<<str<<endl;
        istringstream iss(str);
        string word;
        int cnt = 0;
        while(iss>>word){
            cnt++;
            if(cnt == 1)
                param1 = word;
            else if(cnt == 2)
                param2 = word;
            else if(cnt == 3)
                param3 = word;
        }

        if(param1 == "I" && cnt == 3){
            bool temp = s.insert(param2 , param3 , pos1 , pos2 , scptable);
            if(temp){
                cout<<"\tInserted in ScopeTable# "<<scptable<<" at position " <<pos1<<", " <<pos2<<endl;
            }
            else{
                cout<<"\t"<<"\'"<<param2<<"\'"<<" already exists in the current ScopeTable\n";
            }
        }
        else if(param1 == "I" && cnt != 3){
            cout<<"\tNumber of parameters mismatch for the command I\n";
        }
        if(param1 == "L" && cnt == 2){
            auto temp = s.lookUp(param2 , scptable ,  pos1 , pos2);
            char c1 = '\'' , c2 = '\'';
            if(temp != nullptr){
                 
                 cout<<"\t"<<c1<<param2<<c2<<" found in ScopeTable# "<<scptable<<" at position " <<pos1<<", " <<pos2<<endl;
            }
            else{
                cout<<"\t"<<c1<<param2<<c2<<" not found in any of the ScopeTables\n";
            }

        }
        else if(param1 == "L" && cnt !=2){
            cout<<"\tNumber of parameters mismatch for the command L\n";
        }
        if(param1 == "D" && cnt == 2){
            //s.remove(param2);
            bool flag = s.remove(param2 , pos1 , pos2 , scptable); //s.remove(param2);
            if(flag){
                cout<<"\tDeleted \'"<<param2<<"\' from ScopeTable# "<<scptable<<" at position "<<pos1<<", "<<pos2<<endl;
            }
            else{
                cout<<"\tNot found in the current ScopeTable\n";
            }
        }
        else if(param1 == "D" && cnt != 2){
            cout<<"\tNumber of parameters mismatch for the  command D\n";
        }
        if(param1 == "P" && cnt == 2){
            if(param2 == "A"){
                s.printAllScp();
            }
            else if(param2 == "C"){
                s.prntCurScp();
            }
        }
        else if(param1 == "P" && cnt != 2){
            cout<<"\tNumber of parameters mismatch for the command P\n";
        }
        if(param1 == "S" && cnt == 1){
            s.enterScope();
        }
        else if(param1 == "S" && cnt != 1){
            cout<<"\tNumber of parameters mismatch for the command S\n";
        }
        if(param1 == "E" && cnt == 1){
            s.exitScope(false);
        }
        else if(param1 == "E" && cnt != 1){
            cout<<"\tNumber of parameters mismatch for the command E\n";
        }
        if(param1 == "Q" && cnt == 1){
            s.exitScope(true);
            break;
        }
        else if(param1 == "Q" && cnt != 1){
            cout<<"\tNumber of parameters mismatch for the command Q\n";
        }
        


    }
        


    //freopen("output.txt", "w", stdout);

    //work of file
}