%%%
%%% Composable Objects Implementation
%%% 
%%% This implementation creates composable objects using meta functions
%%% following the bundled modularity pattern with some variations.
%%% Objects are represented as records of named functions.
%%%

declare

%% ========================================
%% META FUNCTIONS FOR COMPOSABLE OBJECTS
%% ========================================

%% Meta function to create a new composable object
fun {CreateObject Methods}
    Methods     % devuelve exactamente el record de métodos
 end 

%% Meta function to add a method to an existing object
fun {AddMethod Object MethodName Method}
   %% Add a new method to the object's method record
   {AdjoinAt Object MethodName Method}
end

%% Meta function to remove a method from an object
fun {RemoveMethod Object MethodName}
   %% Remove a method from the object
   {Record.subtract Object MethodName}
end

%% Meta function to compose two objects (merge their methods)
fun {ComposeObjects Object1 Object2}
   %% Merge methods from both objects, Object1 methods override Object2
   %% This ensures the first object in composition has precedence
   {Adjoin Object2 Object1}
end

%% Meta function to compose any number of objects (Implementation 1)
fun {ComposeList Objects}
    case Objects of nil then {CreateObject empty()}
    [] [Object] then Object
    [] [Object1 Object2] then {ComposeObjects Object1 Object2}
    [] Object|Rest then {ComposeObjects Object {ComposeList Rest}}
    end
end 

%% Meta function to compose any number of objects (Implementation 2)
%% Alternative implementation using fold pattern
fun {Compose2 Objects}
   case Objects of nil then
      {CreateObject empty()}
   [] [Object] then
      Object
   [] Object|Rest then
      {FoldL Rest ComposeObjects Object}
   end
end

%% Meta function to get all method names from an object
fun {GetMethodNames Object}
   {System.showInfo "DEBUG: GetMethodNames function called"}
   local Result in
      {System.showInfo "DEBUG: About to call Arity on object"}
      Result = {Arity Object}
      {System.showInfo "DEBUG: Arity call completed"}
      Result
   end
end

%% Meta function to get all attributes from an object
fun {GetAttributes O}
    if {HasFeature O attributes} then
       {O.attributes}   % <— invocar la función
    else
       attributes()
    end
 end 

%% Meta function to check if an object has a specific method
fun {HasMethod Object MethodName}
   {HasFeature Object MethodName}
end

%% Meta function to invoke a method on an object
proc {InvokeMethod Object MethodName Args}
   if {HasMethod Object MethodName} then
      case Args of nil then
         {Object.MethodName}
      [] [Arg] then
         {Object.MethodName Arg}
      [] [Arg1 Arg2] then
         {Object.MethodName Arg1 Arg2}
      else
         {Object.MethodName Args}
      end
   else
      {System.showInfo "Error: Method " # MethodName # " not found"}
   end
end

%% Meta function to create a proxy object that delegates to another object
fun {CreateProxy TargetObject}
   proc {Proxy MethodName Args}
      {InvokeMethod TargetObject MethodName Args}
   end
in
   proxy(invoke:Proxy target:TargetObject)
end

%% ========================================
%% EXAMPLE COMPOSABLE OBJECTS
%% ========================================

%% Example 1: Counter Object
fun {CreateCounter InitialValue}
   local
      %% Attribute defined as a cell for modification
      Value = {NewCell InitialValue}
      
      %% Attributes function that returns a record with cell values
      fun {Attributes}
         attributes(value:@Value)
      end
      
      %% Methods that operate on the cell attribute
      fun {GetValue} @Value end
      proc {SetValue NewValue} Value := NewValue end
      proc {Increment Amount} 
         {System.showInfo "DEBUG: Increment function called with amount: "}
         {Show Amount}
         {System.showInfo "DEBUG: About to get current Value"}
         local CurrentVal in
            CurrentVal = @Value
            {System.showInfo "DEBUG: Current value: "}
            {Show CurrentVal}
            {System.showInfo "DEBUG: About to set new value"}
            Value := CurrentVal + Amount
            {System.showInfo "DEBUG: New value set successfully"}
         end
         {System.showInfo "DEBUG: Increment function completed"}
      end
      proc {Decrement Amount} Value := @Value - Amount end
      proc {Reset} Value := InitialValue end
      proc {Display} 
         {System.showInfo "DEBUG: Display function called"}
         {System.showInfo "DEBUG: About to get Value from cell"}
         {System.showInfo "DEBUG: Accessing @Value now..."}
         {System.showInfo "DEBUG: Before @Value assignment"}
         {System.showInfo "DEBUG: About to assign @Value to Val"}
         local Val in
            Val = @Value
            {System.showInfo "DEBUG: After @Value assignment"}
            {System.showInfo "DEBUG: Value obtained: "}
            {Show Val}
            {System.showInfo "DEBUG: About to show counter value"}
            {System.showInfo "DEBUG: Before string concatenation"}
            {System.showInfo "Counter value: "}
            {Show Val}
            {System.showInfo "DEBUG: After showing counter value"}
         end
         {System.showInfo "DEBUG: Display function completed"}
      end
   in
      {CreateObject counter(
         attributes:Attributes
         getValue:GetValue
         setValue:SetValue
         increment:Increment
         decrement:Decrement
         reset:Reset
         display:Display
      )}
   end
end

%% Example 2: Bank Account Object
fun {CreateBankAccount InitialBalance}
   local
      %% Attribute defined as a cell for modification
      Balance = {NewCell InitialBalance}
      
      %% Attributes function that returns a record with cell values
      fun {Attributes}
         attributes(balance:@Balance)
      end
      
      %% Methods that operate on the cell attribute
      fun {GetBalance} @Balance end
      proc {Deposit Amount} 
         Balance := @Balance + Amount
      end
      proc {Withdraw Amount}
         if @Balance >= Amount then
            Balance := @Balance - Amount
         else
            {System.showInfo "Error: Insufficient funds. Balance: " # @Balance # ", Requested: " # Amount}
         end
      end
      proc {Display} {System.showInfo "Account balance: " # @Balance} end
   in
      {CreateObject account(
         attributes:Attributes
         getBalance:GetBalance
         deposit:Deposit
         withdraw:Withdraw
         display:Display
      )}
   end
end

%% Example 3: Person Object
fun {CreatePerson Name Age}
   local
      %% Attributes defined as cells for modification
      InnerName = {NewCell Name}
      InnerAge = {NewCell Age}
      
      %% Attributes function that returns a record with cell values
      fun {Attributes}
         attributes(name:@InnerName age:@InnerAge)
      end
      
      %% Methods that operate on the cell attributes
      fun {GetName} @InnerName end
      fun {GetAge} @InnerAge end
      proc {SetName NewName} InnerName := NewName end
      proc {SetAge NewAge} InnerAge := NewAge end
      proc {HaveBirthday} InnerAge := @InnerAge + 1 end
      proc {Display} 
         {System.showInfo "Person: " # @InnerName # ", Age: " # @InnerAge}
      end
   in
      {CreateObject person(
         attributes:Attributes
         getName:GetName
         getAge:GetAge
         setName:SetName
         setAge:SetAge
         haveBirthday:HaveBirthday
         display:Display
      )}
   end
end

%% ========================================
%% EXAMPLE OBJECTS FOR COMPOSITION TESTING
%% ========================================

%% Example Object 1 for composition testing
fun {NewObject1 Val}
   local
      %% Attribute defined as a cell for modification
      Attribute1 = {NewCell Val}
      
      %% Attributes function that returns a record with cell values
      fun {Attributes}
         attributes(attribute1:@Attribute1)
      end
      
      %% Methods that operate on the cell attribute
      fun {GetAttribute1} @Attribute1 end
      proc {SetAttribute1 NewVal} Attribute1 := NewVal end
      proc {Display} {System.showInfo "Object1 - Attribute1: " # @Attribute1} end
   in
      {CreateObject object1(
         attributes:Attributes
         getAttribute1:GetAttribute1
         setAttribute1:SetAttribute1
         display:Display
      )}
   end
end

%% Example Object 2 for composition testing
fun {NewObject2 Val1 Val2}
   local
      %% Attributes defined as cells for modification
      Attribute1 = {NewCell Val1}
      Attribute2 = {NewCell Val2}
      
      %% Attributes function that returns a record with cell values
      fun {Attributes}
         attributes(attribute1:@Attribute1 attribute2:@Attribute2)
      end
      
      %% Methods that operate on the cell attributes
      fun {GetAttribute1} @Attribute1 end
      fun {GetAttribute2} @Attribute2 end
      proc {SetAttribute1 NewVal} Attribute1 := NewVal end
      proc {SetAttribute2 NewVal} Attribute2 := NewVal end
      proc {Display} 
         {System.showInfo "Object2 - Attribute1: " # @Attribute1 # ", Attribute2: " # @Attribute2}
      end
   in
      {CreateObject object2(
         attributes:Attributes
         getAttribute1:GetAttribute1
         getAttribute2:GetAttribute2
         setAttribute1:SetAttribute1
         setAttribute2:SetAttribute2
         display:Display
      )}
   end
end

%% ========================================
%% REQUIRED OBJECTS: EMPLOYER AND PERSON
%% ========================================

%% Employer Object
fun {CreateEmployer InitialName InitialAddress}
    local
       N = {NewCell InitialName}
       A = {NewCell InitialAddress}
       fun {Attributes} attributes(name:@N address:@A) end
       fun {Name} @N end
       fun {Address} @A end
       proc {Display}
          {System.showInfo "Employer"}
          {System.showInfo "Name: " # @N}
          {System.showInfo "Address: " # @A}
       end
    in
        {CreateObject employer(
            attributes:Attributes
            'Name':Name
            'Address':Address
            'Display':Display
        )}         
    end
 end 

%% Person Object
fun {CreatePersonWithEmployer PName Emp}
    local
       N = {NewCell PName}
       E = {NewCell Emp}
       fun {Attributes} attributes(name:@N employer:@E) end
       fun {PersonName} @N end
       fun {PersonEmployer} {(@E).'Name'} end   % invoca el método del employer (mayúscula)
       proc {Display}
          {System.showInfo "Person"}
          {System.showInfo "Name: " # @N}
       end
    in
        {CreateObject person(
            attributes:Attributes
            'PersonName':PersonName
            'PersonEmployer':PersonEmployer
            'Display':Display
        )}         
    end
 end 

%% ========================================
%% COMPOSITION EXAMPLES
%% ========================================

%% Example: Create a Person with Counter capabilities
fun {CreatePersonWithCounter Name Age}
   local
      Person = {CreatePerson Name Age}
      Counter = {CreateCounter 0}
      
      %% Compose the objects, adding counter methods to person
      Composed = {ComposeObjects Person Counter}
   in
      Composed
   end
end

%% Example: Create a Bank Account with Person capabilities
fun {CreateAccountHolder Name Age InitialBalance}
   local
      Person = {CreatePerson Name Age}
      Account = {CreateBankAccount InitialBalance}
      
      %% Compose the objects
      Composed = {ComposeObjects Person Account}
   in
      Composed
   end
end




%% ========================================
%% TESTING AND DEMONSTRATION
%% ========================================

%% Test the composable objects system
local
   %% Create individual objects
   Counter1 = {CreateCounter 5}
   Account1 = {CreateBankAccount 1000}
   Person1 = {CreatePerson "Alice" 25}
   
   %% Create composed objects
   PersonWithCounter = {CreatePersonWithCounter "Bob" 30}
   AccountHolder = {CreateAccountHolder "Charlie" 35 500}
   
   %% Create required objects
   Employer1 = {CreateEmployer "TechCorp" "123 Main St"}
   PersonWithEmployer = {CreatePersonWithEmployer "Alice" Employer1}
in
   {System.showInfo "DEBUG: Starting tests"}
   {System.showInfo "=== Testing Individual Objects ==="}
   {System.showInfo "DEBUG: About to test Counter"}
   
   %% Test Counter
   {System.showInfo "Counter methods: "}
   {Show {GetMethodNames Counter1}}
   {System.showInfo "DEBUG: About to get Counter attributes"}
   {System.showInfo "Counter attributes: "}
   {System.showInfo "DEBUG: Calling GetAttributes now..."}
   {System.showInfo "DEBUG: About to call {Counter1.attributes} directly..."}
   local Attrs in
      Attrs = {Counter1.attributes}
      {System.showInfo "Person's employer name: " # {PersonWithEmployer.'PersonEmployer'}}
      {Show Attrs}
   end
   {System.showInfo "DEBUG: About to call Counter display"}
   {System.showInfo "DEBUG: Calling Counter1.display now..."}
   {Counter1.display}
   {System.showInfo "DEBUG: Counter1.display completed successfully"}
   {System.showInfo "DEBUG: About to increment Counter"}
   {System.showInfo "DEBUG: Calling Counter1.increment(3) now..."}
   {Counter1.increment 3}
   {System.showInfo "DEBUG: Counter1.increment(3) completed successfully"}
   {System.showInfo "DEBUG: About to call Counter display again"}
   {System.showInfo "DEBUG: Calling Counter1.display again now..."}
   {Counter1.display}
   {System.showInfo "DEBUG: Counter1.display (second time) completed successfully"}
   {System.showInfo "Counter attributes after increment: "}
   {System.showInfo "DEBUG: About to get Counter attributes after increment"}
   {Show {GetAttributes Counter1}}
   {System.showInfo "DEBUG: Counter attributes after increment obtained successfully"}
   {System.showInfo "DEBUG: Counter test completed"}
   
   %% Test Bank Account
   {System.showInfo "DEBUG: Starting Bank Account test"}
   {System.showInfo "Account methods: "}
   {System.showInfo "DEBUG: Getting Account1 method names"}
   {Show {GetMethodNames Account1}}
   {System.showInfo "DEBUG: Account1 method names obtained successfully"}
   {System.showInfo "Account attributes: "}
   {System.showInfo "DEBUG: Getting Account1 attributes"}
   {Show {GetAttributes Account1}}
   {System.showInfo "DEBUG: Account1 attributes obtained successfully"}
   {System.showInfo "DEBUG: About to call Account1.display"}
   {Account1.display}
   {System.showInfo "DEBUG: Account1.display completed successfully"}
   {System.showInfo "DEBUG: About to call Account1.deposit(200)"}
   {Account1.deposit 200}
   {System.showInfo "DEBUG: Account1.deposit(200) completed successfully"}
   {System.showInfo "DEBUG: About to call Account1.display again"}
   {Account1.display}
   {System.showInfo "DEBUG: Account1.display (second time) completed successfully"}
   {System.showInfo "Account attributes after deposit: "}
   {System.showInfo "DEBUG: Getting Account1 attributes after deposit"}
   {Show {GetAttributes Account1}}
   {System.showInfo "DEBUG: Account1 attributes after deposit obtained successfully"}
   {System.showInfo "DEBUG: Bank Account test completed"}
   
   %% Test Person
   {System.showInfo "DEBUG: Starting Person test"}
   {System.showInfo "Person methods: "}
   {System.showInfo "DEBUG: Getting Person1 method names"}
   {Show {GetMethodNames Person1}}
   {System.showInfo "DEBUG: Person1 method names obtained successfully"}
   {System.showInfo "Person attributes: "}
   {System.showInfo "DEBUG: Getting Person1 attributes"}
   {Show {GetAttributes Person1}}
   {System.showInfo "DEBUG: Person1 attributes obtained successfully"}
   {System.showInfo "DEBUG: About to call Person1.display"}
   {Person1.display}
   {System.showInfo "DEBUG: Person1.display completed successfully"}
   {System.showInfo "DEBUG: About to call Person1.haveBirthday"}
   {Person1.haveBirthday}
   {System.showInfo "DEBUG: Person1.haveBirthday completed successfully"}
   {System.showInfo "DEBUG: About to call Person1.display again"}
   {Person1.display}
   {System.showInfo "DEBUG: Person1.display (second time) completed successfully"}
   {System.showInfo "Person attributes after birthday: "}
   {System.showInfo "DEBUG: Getting Person1 attributes after birthday"}
   {Show {GetAttributes Person1}}
   {System.showInfo "DEBUG: Person1 attributes after birthday obtained successfully"}
   {System.showInfo "DEBUG: Person test completed"}
   
   {System.showInfo "=== Testing Required Objects ==="}
   
   %% Test Employer
   {System.showInfo "Employer methods: "}
   {Show {GetMethodNames Employer1}}
   {System.showInfo "Employer attributes: "}
   {Show {GetAttributes Employer1}}
   {Employer1.'Display'}
   
   %% Test Person with Employer
   {System.showInfo "PersonWithEmployer methods: "}
   {Show {GetMethodNames PersonWithEmployer}}
   {System.showInfo "PersonWithEmployer attributes: "}
   {Show {GetAttributes PersonWithEmployer}}
   {PersonWithEmployer.'Display'}
   {System.showInfo "Person's employer name: " # {PersonWithEmployer.'PersonEmployer'}}
   
   {System.showInfo "=== Testing Composed Objects ==="}
   
   %% Test Person with Counter
   {System.showInfo "PersonWithCounter methods: "}
   {Show {GetMethodNames PersonWithCounter}}
   {PersonWithCounter.display}  %% Person display
   {PersonWithCounter.increment 10}  %% Counter method
   {PersonWithCounter.display}  %% Counter display
   
   %% Test Account Holder
   {System.showInfo "AccountHolder methods: "}
   {Show {GetMethodNames AccountHolder}}
   {AccountHolder.display}  %% Person display
   {AccountHolder.deposit 100}  %% Account method
   {AccountHolder.display}  %% Account display
   
   {System.showInfo "=== Testing Meta Functions ==="}
   
   %% Test adding a method dynamically
   EnhancedCounter = {AddMethod Counter1 greet
        proc {$} {System.showInfo "Hello from counter!"} end
    }
   {System.showInfo "Enhanced counter methods: "}
   {Show {GetMethodNames EnhancedCounter}}
   {EnhancedCounter.greet}     % ahora OK (proc de aridad 0)
   
   %% Test method invocation through meta function
   {System.showInfo "Invoking method through meta function: "}
   {InvokeMethod Counter1 display nil}
   
   %% Test proxy creation
   Proxy = {CreateProxy Counter1}
   {System.showInfo "Proxy created for counter"}
   {Proxy.invoke display nil}
   
   {System.showInfo "=== Testing Compose Meta Function ==="}
   
   %% Test the exact example from the image Snippet 1
   local O1 O2 Comp in
      O1 = {NewObject1 42}
      O2 = {NewObject2 10 20}
      Comp  = {ComposeList [O1 O2]}
      
      {System.showInfo "Testing composition equality: "}
      {Show {O1.getAttribute1} == {Comp.getAttribute1}}
      
      {System.showInfo "O1 methods: "}
      {Show {GetMethodNames O1}}
      {System.showInfo "O2 methods: "}
      {Show {GetMethodNames O2}}
      {System.showInfo "Composed object methods: "}
      {Show {GetMethodNames Comp}}
      
      {System.showInfo "Testing composed object methods: "}
      {System.showInfo "Comp.getAttribute1: " # {Comp.getAttribute1}}
      {System.showInfo "Comp.getAttribute2: " # {Comp.getAttribute2}}
   end
   
   %% Test both implementations of Compose
   {System.showInfo "=== Testing Both Compose Implementations ==="}
   local O1 O2 Comp1 Comp2 in
      O1 = {NewObject1 100}
      O2 = {NewObject2 200 300}
      
      Comp1 = {ComposeList [O1 O2]}
      Comp2 = {Compose2 [O1 O2]}
      
      {System.showInfo "Implementation 1 (Compose) methods: "}
      {Show {GetMethodNames Comp1}}
      {System.showInfo "Implementation 2 (Compose2) methods: "}
      {Show {GetMethodNames Comp2}}
      
      {System.showInfo "Both implementations should have same methods: "}
      {Show {GetMethodNames Comp1} == {GetMethodNames Comp2}}
      
      {System.showInfo "Implementation 1 - getAttribute1: " # {Comp1.getAttribute1}}
      {System.showInfo "Implementation 2 - getAttribute1: " # {Comp2.getAttribute1}}
      {System.showInfo "Both should return same value (first object precedence): "}
      {Show {Comp1.getAttribute1} == {Comp2.getAttribute1}}
   end
   
   %% Test idempotency - composing the same object twice
   {System.showInfo "=== Testing Idempotency ==="}
   local O1 Comp1 Comp2 in
      O1 = {NewObject1 100}
      Comp1 = {ComposeList [O1]}
      Comp2 = {ComposeList [O1 O1]}
      
      {System.showInfo "Original object methods: "}
      {Show {GetMethodNames O1}}
      {System.showInfo "Composed once methods: "}
      {Show {GetMethodNames Comp1}}
      {System.showInfo "Composed twice methods: "}
      {Show {GetMethodNames Comp2}}
      
      {System.showInfo "Idempotency test - same attribute values: "}
      {Show {O1.getAttribute1} == {Comp1.getAttribute1}}
      {Show {O1.getAttribute1} == {Comp2.getAttribute1}}
   end
end
