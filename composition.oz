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

%% ========================================
%% TASK 2: EXPLICIT COMPOSITION
%% ========================================

%% Task 2: ExplicitComposition - Builds a brand new object incorporating all attributes and methods
fun {ExplicitComposition Objects}
   case Objects of nil then
      {CreateObject empty()}
   [] [Object] then
      Object
   [] Object|Rest then
      {FoldL Rest ComposeObjects Object}
   end
end

%% ========================================
%% TASK 3: IMPLICIT COMPOSITION
%% ========================================

%% Task 3: ImplicitComposition - Manages objects as part of a new object
fun {ImplicitComposition Objects}
   local
      %% Store all objects in a list for management
      ManagedObjects = {NewCell Objects}
      
      %% Create a dispatcher that finds and calls methods from managed objects
      fun {CreateDispatcher MethodName}
         fun {$}
            {FindAndCallMethod Objects MethodName nil}
         end
      end
      
      %% Helper function to find and call a method from managed objects
      fun {FindAndCallMethod Objects MethodName Args}
         case Objects of nil then
            error(noMethod:MethodName)
         [] Object|Rest then
            if {HasMethod Object MethodName} then
               %% Call the method directly without arguments
               {Object.MethodName}
            else
               {FindAndCallMethod Rest MethodName Args}
            end
         end
      end
      
      %% Get all unique method names from all objects
      fun {GetAllMethodNames Objects}
         {RemoveDuplicates {Flatten {Map Objects GetMethodNames}}}
      end
      
      %% Remove duplicates from a list
      fun {RemoveDuplicates List}
         case List of nil then nil
         [] H|T then
            if {Member H T} then {RemoveDuplicates T}
            else H|{RemoveDuplicates T}
            end
         end
      end
      
      %% Create the composite object with dispatchers for each method
      fun {CreateCompositeObject MethodNames}
         case MethodNames of nil then
            {CreateObject empty()}
         [] MethodName|Rest then
            {AdjoinAt {CreateCompositeObject Rest} MethodName {CreateDispatcher MethodName}}
         end
      end
   in
      {CreateCompositeObject {GetAllMethodNames Objects}}
   end
end

%% ========================================
%% TASK 4: EXPLICIT COMPOSITION WITH METHOD CLASHES
%% ========================================

%% Task 4: ExplicitCompositionPoly - Handles method clashes by keeping all methods as ordered lists
fun {ExplicitCompositionPoly Objects}
   local
      {System.showInfo "DEBUG: ExplicitCompositionPoly called with objects"}
      {Show {Length Objects}}
      
      %% Collect all methods from all objects, handling clashes
      fun {CollectMethods Objects}
         case Objects of nil then
            {System.showInfo "DEBUG: No more objects to process"}
            {CreateObject empty()}
         [] Object|Rest then
            {System.showInfo "DEBUG: Processing object, merging with rest"}
            {MergeMethods Object {CollectMethods Rest}}
         end
      end
      
      %% Merge methods from two objects, handling clashes
      fun {MergeMethods Object1 Object2}
         local
            {System.showInfo "DEBUG: MergeMethods called"}
            %% Get all method names from both objects
            Methods1 = {GetMethodNames Object1}
            Methods2 = {GetMethodNames Object2}
            AllMethods = {Append Methods1 Methods2}
            UniqueMethods = {RemoveDuplicates AllMethods}
            
            {System.showInfo "DEBUG: Methods1: "}
            {Show Methods1}
            {System.showInfo "DEBUG: Methods2: "}
            {Show Methods2}
            {System.showInfo "DEBUG: UniqueMethods: "}
            {Show UniqueMethods}
            
            %% Create merged methods record
            fun {CreateMergedMethods MethodNames}
               case MethodNames of nil then
                  {System.showInfo "DEBUG: No more methods to process"}
                  {CreateObject empty()}
               [] MethodName|Rest then
                  local
                     {System.showInfo "DEBUG: Processing method: " # MethodName}
                     %% Check if method exists in both objects (clash)
                     HasIn1 = {HasMethod Object1 MethodName}
                     HasIn2 = {HasMethod Object2 MethodName}
                  in
                     {System.showInfo "DEBUG: HasIn1: "}
                     {Show HasIn1}
                     {System.showInfo "DEBUG: HasIn2: "}
                     {Show HasIn2}
                     if HasIn1 andthen HasIn2 then
                        {System.showInfo "DEBUG: Method clash detected for: " # MethodName}
                        %% Method clash - store all methods as an ordered list
                        {AdjoinAt {CreateMergedMethods Rest} MethodName 
                         [Object1.MethodName Object2.MethodName]}
                     elseif HasIn1 then
                        {System.showInfo "DEBUG: Method only in Object1: " # MethodName}
                        %% Method only in Object1
                        {AdjoinAt {CreateMergedMethods Rest} MethodName Object1.MethodName}
                     elseif HasIn2 then
                        {System.showInfo "DEBUG: Method only in Object2: " # MethodName}
                        %% Method only in Object2
                        {AdjoinAt {CreateMergedMethods Rest} MethodName Object2.MethodName}
                     else
                        {System.showInfo "DEBUG: Method not found in either object: " # MethodName}
                        %% Should not happen
                        {CreateMergedMethods Rest}
                     end
                  end
               end
            end
         in
            {CreateMergedMethods UniqueMethods}
         end
      end
      
      %% Remove duplicates from a list
      fun {RemoveDuplicates List}
         case List of nil then nil
         [] H|T then
            if {Member H T} then {RemoveDuplicates T}
            else H|{RemoveDuplicates T}
            end
         end
      end
   in
      {System.showInfo "DEBUG: Starting CollectMethods"}
      {CollectMethods Objects}
   end
end

%% ========================================
%% TASK 5: DISPATCHING FUNCTION
%% ========================================

%% Task 5: Dispatch function to handle method calls for objects with methods as lists
fun {Dispatch Object MethodName Args}
   {System.showInfo "DEBUG: Dispatch called with method: " # MethodName}
   if {HasMethod Object MethodName} then
      local Method in
         Method = Object.MethodName
         {System.showInfo "DEBUG: Method found, checking if it's a list"}
         case Method of nil then
            {System.showInfo "DEBUG: Method is nil"}
            error(noMethod:MethodName)
         [] H|T then
            {System.showInfo "DEBUG: Method is a list, calling first method"}
            case Args of nil then
               {H}
            [] [Arg] then
               {H Arg}
            [] [Arg1 Arg2] then
               {H Arg1 Arg2}
            else
               {H Args}
            end
         else
            {System.showInfo "DEBUG: Method is not a list, calling directly"}
            case Args of nil then
               {Method}
            [] [Arg] then
               {Method Arg}
            [] [Arg1 Arg2] then
               {Method Arg1 Arg2}
            else
               {Method Args}
            end
         end
      end
   else
      {System.showInfo "DEBUG: Method not found: " # MethodName}
      error(noMethod:MethodName)
   end
end

%% ========================================
%% TASK 6: DISPATCH WITH NEXTFUNCTION
%% ========================================

%% Task 6: Enhanced Dispatch with NextFunction for method chaining
fun {DispatchWithIndex Object MethodName Args Index}
   {System.showInfo "DEBUG: DispatchWithIndex called with method: " # MethodName # " index: "}
   {Show Index}
   if {HasMethod Object MethodName} then
      local Method in
         Method = Object.MethodName
         {System.showInfo "DEBUG: Method found, checking if it's a list"}
         case Method of nil then
            {System.showInfo "DEBUG: Method is nil"}
            error(noMethod:MethodName)
         [] H|T then
            {System.showInfo "DEBUG: Method is a list, getting method at index"}
            if Index =< {Length Method} then
               local SelectedMethod in
                  SelectedMethod = {Nth Method Index}
                  {System.showInfo "DEBUG: Calling method at index "}
                  {Show Index}
                  case Args of nil then
                     {SelectedMethod}
                  [] [Arg] then
                     {SelectedMethod Arg}
                  [] [Arg1 Arg2] then
                     {SelectedMethod Arg1 Arg2}
                  else
                     {SelectedMethod Args}
                  end
               end
            else
               {System.showInfo "DEBUG: Index out of bounds"}
               unit
            end
         else
            {System.showInfo "DEBUG: Method is not a list, calling directly"}
            case Args of nil then
               {Method}
            [] [Arg] then
               {Method Arg}
            [] [Arg1 Arg2] then
               {Method Arg1 Arg2}
            else
               {Method Args}
            end
         end
      end
   else
      {System.showInfo "DEBUG: Method not found: " # MethodName}
      error(noMethod:MethodName)
   end
end

%% Helper function to get the nth element of a list
fun {Nth List N}
   case List of nil then
      error(indexOutOfBounds)
   [] H|T then
      if N == 1 then H
      else {Nth T N-1}
      end
   end
end

%% Helper function to get the length of a list
fun {Length List}
   case List of nil then 0
   [] H|T then 1 + {Length T}
   end
end

%% NextFunction implementation for method chaining
fun {NextFunction Object MethodName Args CurrentIndex}
   {System.showInfo "DEBUG: NextFunction called with method: " # MethodName # " current index: "}
   {Show CurrentIndex}
   {DispatchWithIndex Object MethodName Args CurrentIndex + 1}
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
   {System.showInfo {Value.toVirtualString {GetAttributes Counter1} 1000 1}}
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
   {System.showInfo {Value.toVirtualString {GetAttributes Account1} 1000 1} }
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
   {System.showInfo {Value.toVirtualString {GetAttributes Account1} 1000 1}}
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
   {System.showInfo {Value.toVirtualString {GetAttributes Person1} 1000 1}}
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
   {System.showInfo {Value.toVirtualString {GetAttributes Person1} 1000 1}}
   {System.showInfo "DEBUG: Person1 attributes after birthday obtained successfully"}
   {System.showInfo "DEBUG: Person test completed"}
   
   {System.showInfo "=== Testing Required Objects ==="}
   
   %% Test Employer
   {System.showInfo "Employer methods: "}
   {Show {GetMethodNames Employer1}}
   {System.showInfo "Employer attributes: "}
   {System.showInfo {Value.toVirtualString {GetAttributes Employer1} 1000 1}}
   {Employer1.'Display'}
   
   %% Test Person with Employer
   {System.showInfo "PersonWithEmployer methods: "}
   {Show {GetMethodNames PersonWithEmployer}}
   {System.showInfo "PersonWithEmployer attributes: "}
   {System.showInfo {Value.toVirtualString {GetAttributes PersonWithEmployer} 1000 1}}
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
   
   {System.showInfo "=== Testing Task 2: ExplicitComposition ==="}
   local O1 O2 ExplicitComp in
      O1 = {NewObject1 500}
      O2 = {NewObject2 600 700}
      
      ExplicitComp = {ExplicitComposition [O1 O2]}
      
      {System.showInfo "ExplicitComposition methods: "}
      {Show {GetMethodNames ExplicitComp}}
      {System.showInfo "ExplicitComposition - getAttribute1: " # {ExplicitComp.getAttribute1}}
      {System.showInfo "ExplicitComposition - getAttribute2: " # {ExplicitComp.getAttribute2}}
   end
   
   {System.showInfo "=== Testing Task 3: ImplicitComposition ==="}
   local O1 O2 ImplicitComp in
      O1 = {NewObject1 800}
      O2 = {NewObject2 900 1000}
      
      ImplicitComp = {ImplicitComposition [O1 O2]}
      
      {System.showInfo "ImplicitComposition methods: "}
      {Show {GetMethodNames ImplicitComp}}
      {System.showInfo "ImplicitComposition - getAttribute1: " # {ImplicitComp.getAttribute1}}
      {System.showInfo "ImplicitComposition - getAttribute2: " # {ImplicitComp.getAttribute2}}
   end
   
   {System.showInfo "=== Testing Task 4: ExplicitCompositionPoly ==="}
   local O1 O2 PolyComp in
      O1 = {NewObject1 1100}
      O2 = {NewObject2 1200 1300}
      
      PolyComp = {ExplicitCompositionPoly [O1 O2]}
      
      {System.showInfo "ExplicitCompositionPoly methods: "}
      {Show {GetMethodNames PolyComp}}
      {System.showInfo "ExplicitCompositionPoly - getAttribute1 using Dispatch: "}
      {Show {Dispatch PolyComp getAttribute1 nil}}
      {System.showInfo "ExplicitCompositionPoly - getAttribute2 using Dispatch: "}
      {Show {Dispatch PolyComp getAttribute2 nil}}
   end
   
   {System.showInfo "=== Testing Task 5: Dispatch Function ==="}
   local O1 O2 PolyComp in
      O1 = {NewObject1 1400}
      O2 = {NewObject2 1500 1600}
      
      PolyComp = {ExplicitCompositionPoly [O1 O2]}
      
      {System.showInfo "Testing Dispatch function with PolyComp"}
      {System.showInfo "Dispatch getAttribute1: "}
      {Show {Dispatch PolyComp getAttribute1 nil}}
      {System.showInfo "Dispatch getAttribute2: "}
      {Show {Dispatch PolyComp getAttribute2 nil}}
   end
   
   {System.showInfo "=== Testing Task 6: DispatchWithIndex and NextFunction ==="}
   local O1 O2 PolyComp in
      O1 = {NewObject1 1700}
      O2 = {NewObject2 1800 1900}
      
      PolyComp = {ExplicitCompositionPoly [O1 O2]}
      
      {System.showInfo "Testing DispatchWithIndex function"}
      {System.showInfo "DispatchWithIndex getAttribute1 index 1: "}
      {Show {DispatchWithIndex PolyComp getAttribute1 nil 1}}
      {System.showInfo "DispatchWithIndex getAttribute1 index 2: "}
      {Show {DispatchWithIndex PolyComp getAttribute1 nil 2}}
      
      {System.showInfo "Testing NextFunction"}
      {System.showInfo "NextFunction getAttribute1 from index 1: "}
      {Show {NextFunction PolyComp getAttribute1 nil 1}}
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
