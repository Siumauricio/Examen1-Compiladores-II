#include "ast.h"
#include <map>
#include <iostream>

class ContextStack{
    public:
        struct ContextStack* prev;
        map<string, Type> variables;
};

class FunctionInfo{
    public:
        Type returnType;
        list<Parameter *> parameters;
};

map<string, Type> globalVariables = {};
map<string, Type> variables;
map<string, FunctionInfo*> methods;



string getTypeName(Type type){
    switch(type){
        case FLOAT:
            return "FLOAT";
  
    }

    cout<<"Unknown type"<<endl;
    exit(0);
}

ContextStack * context = NULL;

void pushContext(){
    variables.clear();
    ContextStack * c = new ContextStack();
    c->variables = variables;
    c->prev = context;
    context = c;
}

void popContext(){
    if(context != NULL){
        ContextStack * previous = context->prev;
        free(context);
        context = previous;
    }
}

Type getLocalVariableType(string id){
    ContextStack * currContext = context;
    while(currContext != NULL){
        if(currContext->variables[id] != 0)
            return currContext->variables[id];
        currContext = currContext->prev;
    }
    if(!context->variables.empty())
        return context->variables[id];
    return INVALID;
}


Type getVariableType(string id){
    if(!globalVariables.empty())
        return globalVariables[id];
    return INVALID;
}


bool variableExists(string id){
  Type value;
  if(context != NULL){
    value = getLocalVariableType(id);
    //context->variables[id] != 0
    if(value != 0)
      return true;
  }
  return false;
}
void GlobalDeclaration::Ejecutar(){
    if(variables.size() == 0){
            variables.insert(pair<string, Type>(declaration->id, FLOAT));
                cout << "Variable [" << declaration->id<< "] Declarado" << endl;
    
    }else{
            cout<<"\n"<<variables.size()<<endl;

    if (variables.find(declaration->id) != variables.end()) {
        cout << "Variable " << declaration->id << " already declared" << endl;
    }
    }
    
    

    
}

int GlobalDeclaration::evaluateSemantic(){
    //TODO: evaluar semántica.
    return 0;
}


void addMethodDeclaration(string id, int line, Type type, ParameterList params){
    if(methods[id] != 0){
        cout<<"redefinition of function "<<id<<" in line: "<<line<<endl;
        exit(0);
    }
    methods[id] = new FunctionInfo();
    methods[id]->returnType = type;
    methods[id]->parameters = params;
}

int MethodDefinition::evaluateSemantic(){
    if(this->params.size() > 4){
        cout<< "Method: "<<this->id << " can't have more than 4 parameters, line: "<< this->line<<endl;
        exit(0);
    }

    addMethodDeclaration(this->id, this->line, this->type, this->params);
    pushContext();
   
    list<Parameter* >::iterator it = this->params.begin();
    while(it != this->params.end()){
        (*it)->evaluateSemantic();
        it++;
    }

    if(this->statement !=NULL ){
        this->statement->evaluateSemantic();
    }
    
    popContext();

    return 0;
}



Type FloatExpr::getType(){
    return FLOAT;
}

#define IMPLEMENT_BINARY_GET_TYPE(name)\
Type name##Expr::getType(){\
    string leftType = getTypeName(this->expr1->getType());\
    string rightType = getTypeName(this->expr2->getType());\
    Type resultType = resultTypes[leftType+","+rightType];\
    if(resultType == 0){\
        cerr<< "Error: type "<< leftType <<" can't be converted to type "<< rightType <<" line: "<<this->line<<endl;\
        exit(0);\
    }\
    return resultType; \
}\



int Parameter::evaluateSemantic(){
    if(!variableExists(this->declarator->id)){
        context->variables[declarator->id] = this->type;
    }else{
        cout<<"error: redefinition of variable: "<< declarator->id<< " line: "<<this->line <<endl;
        exit(0);
    }
    return 0;
}


Type ArrayExpr::getType(){
    return this->id->getType();
}

Type IdExpr::getType(){
    Type value;
    if(context != NULL){
        value = getLocalVariableType(this->id);
        if(value != 0)
            return value;
    }
    value = getVariableType(this->id);
    if(value == 0){
        cout<<"error: '"<<this->id<<"' was not declared in this scope line: "<<this->line<<endl;
        exit(0);
    }
    return value;
}

