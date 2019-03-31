Overall Organization of the program: ------------------------------------------------ 
 
This program consists of a main function “startEval” which acts as our interpreter and takes the Racket program as a parameter and outputs the result. 
 
However, in order to implement the use of a dictionary containing all local variables and their bound values, the program also includes a recursive function “recEval” which performs the true interpretation of the program. This function takes the Racket program as its first parameter, and the current dictionary as its second parameter. The dictionary is initialized to an empty list, to which additional pairings of variables and values are appended as the function is recursively called. 
 
Additionally a dictionary specific to undefined functions was added to the recEval parameters in order for letrec to evaluate undefined functions. However, this parameter currently provides little functionality. 
 
Since each racket program is a list, we examine the first element in the list which we call “key”.We use condition expression to determine the key and take appropriate action based on that. 
 
Our recEval function uses is passed a stack which is called “dictionary” that holds the declared variables and their corresponding values saved as a pair. Each time we enter a new scope via nested lets we make a new dictionary by copying the last version and adding new pairs in the beginning of the stack. 
 
 
Data Structures and Algorithms Used in the Project --------------------------------------------------------------------- 
 
The use of data structures native to Racket consists entirely of lists and pairs. The lists were used for the dictionary of variables and values, while the pairs were 
primarily used for the variables themselves, particularly after the use of the zipperMerge function. List operations such as ​car 
​ and ​cdr
​ were also used in the evaluation of the program being interpreted itself. This approach allowed for simplicity and readability. However, to implement the complicated nature of a Racket interpreter, several data structures were created in the form of functions to allow for more effective processing: 
 
● zipperMerge: This function is used in the implementation of lambda expressions. Due to the fact that lambda lists all of its variables before list all of their values, a simple pairing between each variable and its following value is not possible as it is with ​let
​ . Therefore, this helper function is used, which takes the list of variables and the list of values as parameters. This function then iterates through each list and pairs the respective variable to its respective value as dictated by the original lambda expression. For example, given the lambda expression: ((lambda (x y) (+ x y)) 1 2) The zipperMerge function will take the variable list (x y) and the value list (1 2), and return the list ((x 1) (y 2)), which ensures that each variable is matched to its proper value in lambda, provided the number of inputs are correct. 
 
● Find-expr : This function is used to return the dictionary entry matching the given label. The returned value consists of the pair of dictionary label and definition itself, rather than the evaluated definition. For example, when passed the variable ​a
​ and the dictionary ((a 1) (b 2)), this function will return (a 1). 
 ● Find-dic: This function returns the recursively-evaluated expression equivalent to the variable being passed into it. The returned value is not the pair itself, but rather the true value of the pair’s label. For example, when passed the variable ​a and the dictionary ((a 1) (b 2)), this function will return 1 by passing (1) to the recEval function to be evaluated. 
 
● Eval :This function’s process of calling the evaluation function ensures that the results of expressions are compared rather than the expressions themselves. This function is used in all of our arithmetic and relational operations. All the operands in our operations would be passed to this function along with the current version of the dictionary, Then this function will evaluate the operands and if it is a list it would be recursively passed to the recEval to retrieve the actual value of the operand or if it is a variable, it finds the corresponding value of it in the current version of the dictionary.  
 
  
Testing Strategy: ---------------------- 
 
We tried to test each construct of racket we implemented as our project’s development progressed. In keeping with this approach, we first tested simple arithmetic operations and relational operations, after which we combined some of them and tested them together: ● (startEval ‘(if (< (car ‘(1 2 3)) 2) (+ ( -(/ 9 3) (+ 2 3)) (* 2 3)) (= 1 1))) This expression is equivalent to 3 - 5 + 6, and returns 4. 
 
For testing let we first tested simple “let” expressions then more complex “let” expressions and also nested “let” expressions:  ● (startEval '(let ([x 5])               (let ([s 2]                     [y 3])                 (+ y x)))) This expression is equivalent to 3 + 5, and returns 8. 
 
“Letrec” was also tested: ● (startEval '(letrec ((factorial (lambda (n)                                   (if (= n 0)                                       1                                       (* n (factorial (- n 1)))))))               (factorial 5))) This expression is equivalent to !5, and returns 120. 
 
Lambda was tested: ● (startEval '((lambda (x y) (+ x y))(+ 1 2) (* 1 2))) 
 
Known Limitations and Bugs: ---------------------------------------- 
 
While this interpreter successfully evaluates most simple expressions, including those containing ​let
​ , ​letrec
​ , and​ lambda
​ , the interpreter contains several bugs which prevent the proper evaluation of more complex forms of expressions which affect the dictionary: 
● The identification of a function which is yet to be defined is performed via an ​else statement in the evaluation of the program’s operator, or key value. This interpretation of unknown functions means that ​let
​ and ​letrec
​ perform identically, with ​let
​ and ​letrec
​ both being capable of evaluating expressions with unknown functions inside. This issue was initially intended to be curtailed via the use of the undef
​ dictionary, which contains only the names of undefined functions, and which is only added to via ​letrec
​ , but ultimately this distinction was never properly implemented. 
 
● Lambda expressions are currently passed the values of their variables only if the function call with its list of values is in the same level as the list containing the lambda 
​ expression. This method is sufficient for simple uses of ​lambda
​ where the the values are immediately provided. However, when the ​lambda
​ expression is at a deeper level in the list than the ​lambda
​ variables’ values, such as in a nested expression, our interpretation of the ​lambda 
​ expression cannot find the values to be passed into the variables of the lambda expression. A proper fix of this bug would involve the recursive search for ​lambda
​ in order to append its variables and their values to the dictionary prior to evaluation, but this fix was not implemented. 
 
● This interpreter does not allow for the overwriting of any of the native data types or operators that it is designed to evaluate. A fix for this issue was attempted by checking the dictionary for the program’s operator prior to further evaluation, but we were unable to implement this fix without creating additional bugs. 
