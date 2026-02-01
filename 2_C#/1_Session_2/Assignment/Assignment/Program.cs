using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Security.Cryptography.X509Certificates;

namespace CSharpAssignment
{
    class Program
    {
        // Class-level field for scope demonstrations
        static int classField = 100;

        static void Main(string[] args)
        {
            Console.WriteLine("╔════════════════════════════════════════════════════════════════════╗");
            Console.WriteLine("║           C# FUNDAMENTALS - ASSIGNMENT WITH ANSWERS                ║");
            Console.WriteLine("║                      20 Questions                                  ║");
            Console.WriteLine("╚════════════════════════════════════════════════════════════════════╝\n");



            #region Question 1: Regions _ done
            // ══════════════════════════════════════════════════════════════════════
            // QUESTION 2: REGIONS
            // ══════════════════════════════════════════════════════════════════════
            //
            // Q: What is the purpose of #region and #endregion directives in C#? 
            //    How do they help in code organization?
            //
            // ══════════════════════════════════════════════════════════════════════


            //Nested Region Example
            #region Question 1: Answer
            /* #region and #endregion directives r used to organize code by 'collapse' * 
             * and 'expand' large blocks of code, so you can divide the large block    *
             * of code into smaller blocks to be organized, readable and can be        *
             * maintained easily.                                                      */
            #endregion

            Console.WriteLine("\n" + new string('-', 70) + "\n");
            #endregion

            #region Question 2: Variable Declaration - Explicit vs Implicit _ done
            // ══════════════════════════════════════════════════════════════════════
            // QUESTION 3: VARIABLE DECLARATION - EXPLICIT VS IMPLICIT
            // ══════════════════════════════════════════════════════════════════════
            //
            // Q: What is the difference between explicit and implicit variable 
            //    declaration in C#? Provide examples of both.
            //
            // ══════════════════════════════════════════════════════════════════════



            // EXPLICIT DECLARATION 
            // is decalring the type of the variable like int, char, float and so on
            // can be uninitialized and in this case it'll be called declaration as no 
            // value is assigned to this variable
            int Question1Var1;

            // this is definition where value is assigned to this variable
            char Question1Var2 = 'a';

            // IMPLICIT DECLARATION 
            // using var keyword and let the compiler decide the type of the variable 
            // based on the value in it and it MUST be initialized
            var Question1Var3 = 3;

            #endregion

            #region Question 3: Constants _ done
            // ══════════════════════════════════════════════════════════════════════
            // QUESTION 4: CONSTANTS
            // ══════════════════════════════════════════════════════════════════════
            //
            // Q: Write the syntax for declaring a constant in C#. Why would you use 
            //    a constant instead of a regular variable?
            //
            // ══════════════════════════════════════════════════════════════════════



            // Constant examples
            /*******************************************************************
             * const variable is used as a label for example                   *
             * you've a value 10 which represents for example max array length *
             * so, instead of typing 10 which isn't readable you can use       *
             * const char maxArrayLength = 10;                                 *
             * where this won't take space in the memory (no memory allocated) *
             * as it's treaded in the following way:                           *
             * --> compile-time substitution (inlining) <-- or in other words  *
             * text replacement as follows:                                    *
             * const char maxArrayLength = 10;                                 *
             * int[] arr = new int[maxArrayLength]                             *
             * what will happen that in the compile time the compiler will     *
             * replace the text by the value as follows                        *
             * any maxArrayLength will be 10                                   *
             * int[] arr = new int[5]                                          *
             *******************************************************************/
            const int Question4Var1 = 1;

            #endregion

            #region Question 4: Class-level vs Method-level Scope _ done
            // ══════════════════════════════════════════════════════════════════════
            // QUESTION 4: CLASS-LEVEL VS METHOD-LEVEL SCOPE
            // ══════════════════════════════════════════════════════════════════════
            //
            // Q: Explain the difference between class-level scope and method-level 
            //    scope with examples.
            //
            // ══════════════════════════════════════════════════════════════════════

            // there is a variable in the definition of this method that can't be
            // used outside it and this is Method-level scope, while the class-level
            // variable can be used anywhere in the class which is
            // also printed in the following method
            Question4Method();

            #endregion

            #region Question 5: Block-level Scope _ done
            // ══════════════════════════════════════════════════════════════════════
            // QUESTION 5: BLOCK-LEVEL SCOPE
            // ══════════════════════════════════════════════════════════════════════
            //
            // Q: What is block-level scope? Give an example showing a variable that 
            //    is only accessible within a specific block.
            //
            // ══════════════════════════════════════════════════════════════════════

            // block level scope means that the variables declared withing this scope
            // can't be used outside it 
            if (true)
            {
                char Question5Var1 = (char)1;

                // can be accessed inside this if scope only
                Console.WriteLine("\nQuestion 5: "+Question5Var1);

            }

            // if u uncomment the following line it will generate compile-time error
            // Console.WriteLine("\nQuestion 5: " + Question5Var1);
            #endregion

            #region Question 6: Variable Lifetime - Local vs Static _ done
            // ══════════════════════════════════════════════════════════════════════
            // QUESTION 6: VARIABLE LIFETIME - LOCAL VS STATIC
            // ══════════════════════════════════════════════════════════════════════
            //
            // Q: What is variable lifetime? Explain the lifetime of local variables 
            //    vs static variables.
            //
            // ══════════════════════════════════════════════════════════════════════


            // Variable lifetime is the time which the variable exists in memory and
            // can be accesses.
            // local variable exists from the moment its scope is entered
            // (for example, when a method is called) until that scope is exited.
            // It is typically allocated on the stack and destroyed when the method returns.
            // static variable lifetime: is the time from it's initialization till the 
            // whole program is teminated

            #endregion

            #region Question 7: Garbage Collector _ done
            // ══════════════════════════════════════════════════════════════════════
            // QUESTION 7: GARBAGE COLLECTOR
            // ══════════════════════════════════════════════════════════════════════
            //
            // Q: What is the Garbage Collector in C#? How does it affect the 
            //    lifetime of objects?
            //
            // ══════════════════════════════════════════════════════════════════════

            // garbage collector is the tool that is responsible for freeing the heap
            // from unused (unreachable) memory
            // in older languages like C and C++, memory had to be freed manually
            // using functions such as free(pointer)
            //
            // for example: class named student
            // creating 2 instances of this class
            // student student1 = new student();
            // student student2 = new student();
            //
            // here student1 is not the object itself, it's a reference to its location
            // in the memory (i.e., pointer-like reference), so if we do the following
            // student1 = student2; here the reference that was in student1 changes
            // so, student1 now contains reference to student2 object
            //
            // what will happen to the first student object that is in the heap?
            // the object becomes unreachable and eligible for garbage collection
            // unlike older languages where we had to manually call free(pointer),
            // in C# the garbage collector automatically and non-deterministically
            // frees this part of the memory later
            //
            // this allows this part of the memory to be reused and helps reduce
            // problems like memory fragmentation

            #endregion

            #region Question 8: Variable Shadowing _ done
            // ══════════════════════════════════════════════════════════════════════
            // QUESTION 8: VARIABLE SHADOWING
            // ══════════════════════════════════════════════════════════════════════
            //
            // Q: What is variable shadowing in C#? Does C# allow shadowing in 
            //    nested blocks within the same method?
            //
            // ══════════════════════════════════════════════════════════════════════

            // Shadowing is to use the same name for different variables one in outer
            // scope and the other in an inner scopr
            // and NO C# doesn't allow shadowing in nested blocks within the same 
            // method

            // inner scope 1: if
            if (true)
            {
                int Question8VarInner1 = 1;

                // inner scopr 2: if
                if (true)
                {
                    // here if u uncomment the following line this will cause compile-time error
                    //int Question8VarInner1 = 1;
                }
            }


            #endregion

            #region Question 9: C# Naming Rules _ done
            // ══════════════════════════════════════════════════════════════════════
            // QUESTION 9: C# NAMING RULES
            // ══════════════════════════════════════════════════════════════════════
            //
            // Q: List five rules that must be followed when naming variables in C#.
            //
            // ══════════════════════════════════════════════════════════════════════

            /*
             1. Must start with a letter or underscore
             2. Can contain letters, digits, and underscore
             3. can't be C# keyword
             4. Case sensitive
             5. use PascalCase with Methods, Classes, cpnstants
             6. use camelCase with localVariables, parameters
             */

            #endregion

            #region Question 10: Naming Conventions _ done
            // ══════════════════════════════════════════════════════════════════════
            // QUESTION 10: NAMING CONVENTIONS
            // ══════════════════════════════════════════════════════════════════════
            //
            // Q: What naming conventions are recommended for: (a) local variables, 
            //    (b) class names, (c) constants?
            //
            // ══════════════════════════════════════════════════════════════════════

            /*
             a -> camelCase
             b -> PascalCase
             c -> PascalCase
             */

            #endregion

            #region Question 11: Error Types _ done
            // ══════════════════════════════════════════════════════════════════════
            // QUESTION 11: ERROR TYPES
            // ══════════════════════════════════════════════════════════════════════
            //
            // Q: Compare and contrast syntax errors, runtime errors, and logical 
            //    errors. Provide an example of each.
            //
            // ══════════════════════════════════════════════════════════════════════

            /***************************************************************************
             1. Syntax error is a compile-time error, it happenes during compiling the *
                program, like missing ';' or typing strin instead of string            *
             ***************************************************************************/
            // int Question11Var =  2 // missing ';'

            /***************************************************************************
             2. runtime errors: it happens while the program is running, like dividing *
                by Zero, index out of range when accessing arrays                      *
             ***************************************************************************/
            // dividing by zero
            int Question11Var2 = 2;
            int Question11Dividor = 0;

            // if u uncomment the following line it will cause run-time error
            // Question11Var2 /= Question11Dividor;

            /***************************************************************************
             3. logical error: it happens when the code is compiled successfully and   *
                runs with no runtime error but the intended behavior didn't happed     *
                correct, like calculatin the average incorrectly                       *
             ***************************************************************************/
            int Question11ElementsSum = 30;
            int Question11ElementsCount = 6;

            // here is logical error
            // as Question11Avg = Question11ElementsSum / Question11ElementsCount; is right
            float Question11Avg = Question11ElementsCount / Question11ElementsSum;
            #endregion

            #region Question 12: Exception Handling Importance _ done
            // ══════════════════════════════════════════════════════════════════════
            // QUESTION 12: EXCEPTION HANDLING IMPORTANCE
            // ══════════════════════════════════════════════════════════════════════
            //
            // Q: Why is exception handling important in C#? What would happen if 
            //    you don't handle exceptions?
            //
            // ══════════════════════════════════════════════════════════════════════

            // Exception handling is important to catch the runtime errors that may 
            // occur during the program execution.
            // if exceptions aren't handeled the system may 'CRASH' 

            #endregion

            #region Question 13: try-catch-finally _ done
            // ══════════════════════════════════════════════════════════════════════
            // QUESTION 13: TRY-CATCH-FINALLY
            // ══════════════════════════════════════════════════════════════════════
            //
            // Q: Write a code example demonstrating try-catch-finally. Explain when 
            //    the finally block executes.
            //
            // ══════════════════════════════════════════════════════════════════════

            // typing that an error happened
            Console.WriteLine("\ntry...catch block example:");

            try
            {
                throw new Exception("\nSomething went wrong\n");
            }
            catch (Exception ex)
            {
                Console.WriteLine( "\nException happens here --> " + ex.ToString());
            }
            finally
            {
                Console.WriteLine("\nFinally block alawys run\n");
            }

            // Finally block alawys run whether there is exception of not

            #endregion

            #region Question 14: Common Built-in Exceptions _ done
            // ══════════════════════════════════════════════════════════════════════
            // QUESTION 14: COMMON BUILT-IN EXCEPTIONS
            // ══════════════════════════════════════════════════════════════════════
            //
            // Q: List and explain five common built-in exceptions in C# with 
            //    scenarios when each would occur.
            //
            // ══════════════════════════════════════════════════════════════════════

            /*
             1. NullReferenceException --> if u tried to use a NULL reference
                                           student student1 = null
                                           student1.GPA; Exception
             2. DivideByZeroException --> if u tried to divide by zero
                                          int x = 3/0; Exception
             3. IndexOutOfRangeException --> if u tried to access element outside
                                             an array
                                             int[] arr = int[5]
                                             arr[5]; Exception should be from 0 - 4
             4. FileNotFoundException --> if u tried to read a file that doesn't exist
                                          in the path that u entered
             5. ArgumentNullException --> if null pased as an argument to a method
                                          MethodName(null , arg1 , arg2); Exception
             */

            #endregion

            #region Question 15: Multiple catch Blocks _ done
            // ══════════════════════════════════════════════════════════════════════
            // QUESTION 15: MULTIPLE CATCH BLOCKS
            // ══════════════════════════════════════════════════════════════════════
            //
            // Q: Why is the order of catch blocks important when handling multiple 
            //    exceptions? Write code showing correct ordering.
            //
            // ══════════════════════════════════════════════════════════════════════

            // Order of catch blocks is important as when Exception happens the 
            // catch blocks will be checked from top to bottom so, the more specific
            // ones should be mentioned first then the more general ones

            Console.WriteLine("\ncatch order question:\n");

            try
            {
                int[] arr = new int[5];
                arr[5] = 0; 
            }
            catch (IndexOutOfRangeException ex)
            {
                Console.WriteLine("exception message: " + ex.Message);
            }
            catch(Exception ex)
            {
                Console.WriteLine("general exception message: " + ex.Message);
            }

            // if the order if catch here differes and the Exception part comes first
            // this will be general and if u needed to do something specific if 
            // IndexOutOfRangeException u won't be able to do it

            #endregion

            #region Question 16: throw Keyword _ done
            // ══════════════════════════════════════════════════════════════════════
            // QUESTION 16: THROW KEYWORD
            // ══════════════════════════════════════════════════════════════════════
            //
            // Q: What is the difference between 'throw' and 'throw ex' when 
            //    re-throwing an exception? Which one preserves the stack trace?
            //
            // ══════════════════════════════════════════════════════════════════════

            Console.WriteLine("\nQuestion 16:\n");

            // throw: will throw the same exception
            
            try
            {
                Question16Method2();
            } catch(Exception ex)
            {
                Console.WriteLine("the exception message: " + ex.Message);
            }


            // throw ex: will create a new object of Exception and copy the info
            // of the old one into the new one

            #endregion

            #region Question 17: Stack and Heap Memory _ done
            // ══════════════════════════════════════════════════════════════════════
            // QUESTION 17: STACK AND HEAP MEMORY
            // ══════════════════════════════════════════════════════════════════════
            //
            // Q: Explain the differences between Stack and Heap memory in C#. 
            //    What types of data are stored in each?
            //
            // ══════════════════════════════════════════════════════════════════════


            /*
              -> Stack:
                1. Fast, managed through LIFO (Last in first out) through push and pop 
                   operation.
                2. managed through runtime
                3. each thread has its stack frame
                4. Contains value type variabels like: int, bool, char, and referenece to
                   objects located in the heap.

             -> Heap:
               1. managed by garbage collector
               2. used for dynamic allocation
               3. contains objects created by 'new' keyword where the reference of these
                  objects is stored in stack
             */


            #endregion

            #region Question 18: Value Types vs Reference Types _ done
            // ══════════════════════════════════════════════════════════════════════
            // QUESTION 18: VALUE TYPES VS REFERENCE TYPES
            // ══════════════════════════════════════════════════════════════════════
            //
            // Q: Write a code example showing how value types and reference types 
            //    behave differently when assigned to another variable.
            //
            // ══════════════════════════════════════════════════════════════════════

            Console.WriteLine("\nQuestion 18:\n");

            // value type
            int x = 3, y = 5;

            Console.WriteLine("Values before changing it:\n");
            Console.WriteLine("x -> " + x + " , y -> "+ y);

            x = y;
            Console.WriteLine("Values after changing it: x = y \n");
            Console.WriteLine("x -> " + x + " , y -> "+ y);

            // reference type:
            string str1 = "Youssef" , str2 = "Khaled";

            // here assigning the reference that is stored in str2 in str1
            // not the value as the value is stored in heap not stack.
            str1 = str2;


            #endregion

            #region Question 19: Object in C# _ done
            // ══════════════════════════════════════════════════════════════════════
            // QUESTION 19: OBJECT IN C#
            // ══════════════════════════════════════════════════════════════════════
            //
            // Q: Why is 'object' considered the base type of all types in C#? 
            //    What methods does every type inherit from System.Object?
            //
            // ══════════════════════════════════════════════════════════════════════

            // object is the base type from which all other types are derived 

            /* 
             * Methods inherited are: 
             * ToString() – string representation
             * Equals() – value comparison
             * GetType() – runtime type information
             */

            #endregion

        }



        /* Method implemented to show the difference between Class-level and       *
         * Method-level Scope where there is a variable defined in the class level *
         * scop and other defined in the method-level scopr and both printed       */
        static void Question4Method()
        {
            int Question4MethodVar = 150; // Method scope variable

            // printing the method-level variable
            Console.WriteLine("Question 4 method\nMethod-level scope variable: "+Question4MethodVar);

            // printing the class-level variable
            Console.WriteLine("\nClass-level scope variable: " + classField);
        }

        static void Question16Method1()
        {
            throw new Exception("this is a new exception for question 16");
        }
        static void Question16Method2()
        {
            try
            {
                Question16Method1();
            }
            catch
            {
                throw;
            }
        }
    }

    
}