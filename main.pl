%create_register(Size, Register) -> 'Register' is a list with a size of 'Size' full of zeros    
create_register(0, []):-!.
create_register(Size, Register):- NewSize is Size - 1, create_register(NewSize, NewRegister), append(NewRegister, [0], Register). 

%read_register(Register, Index, Value) -> 'Value' is the value at 'Index' in 'Register'
read_register([H|_], 0, H):-!.
read_register([_|T], Index, Value):- NewIndex is Index - 1, read_register(T, NewIndex, Value).

%change_register(Register, Index, Value, NewRegister) -> 'NewRegister' is the 'Register' with the value at 'Index' changed to 'Value'
change_register([_|T], 0, Value, [Value|T]):-!.
change_register([H|T], Index, Value, [H|NewT]):- NewIndex is Index - 1, change_register(T, NewIndex, Value, NewT).

%nth_element(List, Index, Value)
nth_element([],_,'').
nth_element([H|_], 0, H):-!.
nth_element([_|T], Index, Value):- NewIndex is Index - 1, nth_element(T, NewIndex, Value).

%nth_line(FileName, N, Line) -> 'Line' is the Nth line of the file 'FileName'
nth_line(FileName, N, Line):- 
    open(FileName, read, File), 
    line_processor(File, N, 0, Line),
    close(File).

%line_processor(File, N, CurrentLine, Line):-
%   Given file 'File' is being processed line by line, 
%   'N' is the line to be read, 
%   'CurrentLine' is the current line being read,
%   'Line' is the Nth line of the file.
line_processor(File, N, CurrentLine, Line):-
    read_line_to_string(File, ReadLine),
    (ReadLine == end_of_file ->  
        writeln("-EOF IS BEING READ-"), 
        fail %If by anyhow the programmer decides to use their freewill, punish the programmer by failing the execution
    ;   
        (CurrentLine =:= N -> %Good programmer... Keep obeying the "not finishing the program without halting it rule"
            Line = ReadLine
        ;   
            NextLine is CurrentLine + 1,
            line_processor(File, N, NextLine, Line)
        )
    ).

split_by(String, Delimiter, X):-
    string_codes(String, NewString),
    string_codes(Delimiter, NewDelimiter),
    nth_element(NewDelimiter, 0, FinalDelimiter),  % I am doing this part because it needs to be an atom not a list
                                                % and I dont know if there is a way to get the first element of a list without a function
    split_helper(NewString, FinalDelimiter, Left, Right),
    append([Left],[Right],X). % joins the left and right parts of the 

%split_helper(String, Delimiter, Left, Right) ->
split_helper([], _, [], []):-!.

split_helper([H|T], H, [], T):-!.

split_helper([H|T], Del, [H|Left], Right):-
    H \= Del,
    split_helper(T, Del, Left, Right).

%   Discussion with myself
% What should os know? - Os should probably know about Register and the new version of that register
% - maybe line number to keep track of the program.
% okay then we will make a os/1 that is going to get the 'ProgramName' and it will create register and send it to os/3???
%os(ProgramName, Register/ExceptionValue, LineNumber) 

%Funnily this is the most important predicate in this whole program :D
%It gets something and assigns it to the other value... In a way it is like "A is X"
%but for some reason I can not set the value of the predicate arguments without it
%IMPORTANT UPDATE (for me); 
%       Apparently we can and we should use 'A = X' to change this and NOT 'A is X'
%   I am a little confused because of the way this works but yeah and I changed "line_proccessor" accordingly
%   to use this way but I am just to lazy to change other places I used this predicate... Lucky one. 
set_something(X,X). %Thanks for saving me cool predicate B)

%Base case to init registers.
os(ProgramName):-
    create_register(32, Register),
    os(ProgramName, Register, 0).

%Halting case fo os/3 
os(_, _, -1):-
    writeln("-END OF PROGRAM-"), !.

%Recursively calls the os to make it run the program line by line
os(ProgramName, Register, LineNumber) :-
    os_helper(ProgramName, LineNumber, NewLineNumber, Register, NewRegister),
    os(ProgramName, NewRegister, NewLineNumber).    

%Honestly I could just remove this but at this point... It just works so I am not going to mess with it
%This predicate just calls 2 other predicates that I already created 
os_helper(ProgramName, LineNumber, NewLineNumber, Register, NewRegister) :-
    nth_line(ProgramName, LineNumber, Line),
    match_and_act(Line, LineNumber, NewLineNumber, Register, NewRegister).

%Takes all of those arguments to run a line of program and returns the 'NewRegister' and 'NewLineNumber'
match_and_act(Line, LineNumber, NewLineNumber, Register, NewRegister) :-
    TempLine is LineNumber + 1, %Increasing the line number to assure program slowly progresses through the program one by one
    split_by(Line, " ", LineParts), % I made this function so let me use this at least once :)
    nth_element(LineParts, 0, Target),
    nth_element(LineParts, 1, Args),
    (Target = `halt` -> %Since halt is not like the other system calls it doesn't have any arguments and it is making the life 
                        % hell for me. So I decided to just not parse the arguments if the 'halt' is being called.
        true % true :)
    ; %Else part of the if-else
        split_string(Args, ",", "", ArgsList), %splits the arguments by the delimiter ',' -> "abc,def" => ["abc","def"]
        nth_element(ArgsList, 0, Arg0Char), 
        (Arg0Char = '' -> true; atom_number(Arg0Char, Arg0)), %If the argument is set convert the string to a number
        
        nth_element(ArgsList, 1, Arg1Char),
        (Arg1Char = '' -> true; atom_number(Arg1Char, Arg1)), % Same thing there

        nth_element(ArgsList, 2, Arg2Char),
        (Arg2Char = '' -> true; atom_number(Arg2Char, Arg2)) % Same thine here also >:)
    ),
    
    %Expected output -> "ln.X call arg0,arg1      - "
    write("ln."), write(LineNumber),write(" "),
    write(Line), write("\t\t- "),

    %if the writtten system call is <X> execute its code
    %Honestly if I were not this lazy I would probably wrap all of it in functions, but this also does the job for this time 
    (Target = `add` ->  
        read_register(Register, Arg0, Value0), 
        read_register(Register, Arg1, Value1),
        AddResult is Value0 + Value1, 
        change_register(Register, Arg1, AddResult, NewRegister),
        NewLineNumber is TempLine,
        
        %Expected output of this mess -> "RegisterA (ResultA) + RegisterB (ResultB) is ResultA+ResultB"
        write("Register"), write(Arg0), write(" ("), write(Value0), write(") + Register"), write(Arg1), write(" ("), write(Value1), write(") is "), writeln(AddResult)

    ;Target = `put` ->
        change_register(Register, Arg1, Arg0, NewRegister),
        NewLineNumber is TempLine,

        %Expected output -> "RegisterX is now <Arg0>"
        write("Register"), write(Arg1), write(" is now "), writeln(Arg0)

    ;Target = `prn` ->
        read_register(Register, Arg0, Value0),
        NewLineNumber is TempLine,
        set_something(Register, NewRegister),
        
        %RegisterX is <Value0>
        write("Register"), write(Arg0), write(" is "), writeln(Value0)

    ;Target = `jmpe` ->
        read_register(Register, Arg0, Value0),
        read_register(Register, Arg1, Value1),
        set_something(NewRegister, Register),
        (Value0 = Value1 -> %checks if Value0 and Value1 are the same and if same
            NewLineNumber is Arg2, %line to execute is being altered.
            write("Jumping conditionally to the line: "),
            writeln(Arg2),
            writeln("------------------------- jump-E SEPERATOR") %Say hi to the "Cool Seperator" B)
        ;%If they are NOT the same 
            NewLineNumber is TempLine, %LineNumber + 1 is being set as the new line
            write("Jump condition is not met, next line: "),
            writeln(TempLine)

        )

    ;Target = `jmpu` ->
        NewLineNumber is Arg0, %Alters the line to execute without any checks
        set_something(NewRegister, Register),
        write("Jumping unconditionally to the line "),
        writeln(Arg0),
        writeln("------------------------- jump-U SEPERATOR") %Brother of the "Cool Seperator", "Cooler Seperator"

    ;Target = `halt` ->
        set_something(NewRegister, Register),
        NewLineNumber is -1 %By changing the line number to `-1` it will activate the halting predicate instead of this predicate 
    ;   
        writeln("No match") %Error handling for the program, because I have fat fingers. yommey 
    ).