:- dynamic(size/1).
:- dynamic(maxLength/1).
:- dynamic(actor/2).
:- dynamic(covid/2).
:- dynamic(mask/2).
:- dynamic(home/2).

%--------------TESTS--------------
test1 :-
    assert(size(5)),
    assert(actor(1, 1)),
    assert(covid(2, 3)),
    assert(covid(3, 3)),
    assert(mask(2, 5)), % mask = doctor
    assert(mask(3, 5)), % mask = doctor
    assert(home(1, 5)).

test2 :-
    assert(size(9)),
    assert(actor(1, 1)),
    assert(covid(2, 7)),
    assert(covid(5, 2)),
    assert(mask(5, 5)), % mask = doctor
    assert(mask(4, 8)), % mask = doctor
    assert(home(8, 4)).

test3 :-
    assert(size(9)),
    assert(actor(1, 1)),
    assert(covid(2, 3)),
    assert(covid(5, 3)),
    assert(mask(8, 2)), % mask = doctor
    assert(mask(9, 8)), % mask = doctor
    assert(home(1, 8)).

test4 :-
    assert(size(9)),
    assert(actor(1, 1)),
    assert(covid(1, 3)),
    assert(covid(3, 1)),
    assert(mask(3, 5)), % mask = doctor
    assert(mask(5, 5)), % mask = doctor
    assert(home(5, 9)).

test5 :-
    assert(size(9)),
    assert(actor(1, 1)),
    assert(covid(6, 1)),
    assert(covid(5, 2)),
    assert(mask(1, 8)), % mask = doctor
    assert(mask(7, 3)), % mask = doctor
    assert(home(9, 2)).

test6 :-
    assert(size(9)),
    assert(actor(1, 1)),
    assert(covid(8, 3)),
    assert(covid(7, 1)),
    assert(mask(3, 8)), % mask = doctor
    assert(mask(7, 7)), % mask = doctor
    assert(home(9, 1)).


squareLattice(X, Y) :-
    size(Size),
    between(1, Size, X),
    between(1, Size, Y).


main :-
    actor(ActorX, ActorY),
    home(HomeX, HomeY),
    size(Size),
    calculateMaxLength(Size, M),

    % looking for paths consisting of 0...M steps 
    between(0, M, N),
        backtracking(ActorX, ActorY, HomeX, HomeY,[[ActorX, ActorY]], ResultPath, N),
        write([ActorX, ActorY]),
        write(ResultPath), nl,
        length(ResultPath, L),
    	L1 is L + 1,
        write(L1), write(" steps"), nl.

% main function
backtracking(X, Y, X, Y, _, _, _).
backtracking(FromX, FromY, ToX, ToY, Path, ResultPath, MaxLength) :-
    length(Path, Length),
    Length =< MaxLength,
    dontNeedToBacktrack(FromX, FromY, ToX, ToY, MaxLength, Length),
    
    % for all possible steps from current point run backtracking
    allPossibleSteps(FromX, FromY, NewX, NewY, Path),
        append(Path, [[NewX, NewY]], NewPath),
        backtracking(NewX, NewY, ToX, ToY, NewPath, PathFromRecursion, MaxLength),
        ResultPath = [[NewX, NewY] | PathFromRecursion].

% we don't need to run backtracking further if we can't get from the current point to home by the shortest route.
dontNeedToBacktrack(FromX, FromY, ToX, ToY, MaxLength, Length) :-
    max(abs(FromX - ToX), abs(FromY - ToY)) =< MaxLength - Length.

calculateMaxLength(Size, M) :-
    M is Size * Size.

isCovidZone(X, Y) :-
    covid(A, B),
    A0 is A-1,
    A1 is A+1,
    B0 is B-1,
    B1 is B+1,
    between(A0, A1, X),
    between(B0, B1, Y).

% check whether the position is valid or not
isPositionValid(X, Y, Path) :-
    squareLattice(X, Y),
    isSafePlace(X, Y, Path),
    not(member([X, Y], Path)).

% find all possible steps from X Y
allPossibleSteps(X, Y, NewX, NewY, Path) :-
    stepRight(X, Y, NewX, NewY),
    isPositionValid(NewX, NewY, Path).
allPossibleSteps(X, Y, NewX, NewY, Path) :-
    stepLeft(X, Y, NewX, NewY),
    isPositionValid(NewX, NewY, Path).
allPossibleSteps(X, Y, NewX, NewY, Path) :-
    stepTop(X, Y, NewX, NewY),
    isPositionValid(NewX, NewY, Path).
allPossibleSteps(X, Y, NewX, NewY, Path) :-
    stepBottom(X, Y, NewX, NewY),
    isPositionValid(NewX, NewY, Path).
allPossibleSteps(X, Y, NewX, NewY, Path) :-
    stepRightTop(X, Y, NewX, NewY),
    isPositionValid(NewX, NewY, Path).
allPossibleSteps(X, Y, NewX, NewY, Path) :-
    stepRightBottom(X, Y, NewX, NewY),
    isPositionValid(NewX, NewY, Path).
allPossibleSteps(X, Y, NewX, NewY, Path) :-
    stepLeftTop(X, Y, NewX, NewY),
    isPositionValid(NewX, NewY, Path).
allPossibleSteps(X, Y, NewX, NewY, Path) :-
    stepLeftBottom(X, Y, NewX, NewY),
    isPositionValid(NewX, NewY, Path).

% safe place if we have a mask or we not in CovidZone
isSafePlace(X, Y, Path) :-
    ((isCovidZone(X, Y)),
        (mask(MaskX, MaskY), member([MaskX, MaskY], Path))
    );
    not(isCovidZone(X, Y)).

% all steps from X Y
stepRightTop(X, Y, NewX, NewY) :-
    NewY is Y + 1,
    NewX is X + 1.
stepRightBottom(X, Y, NewX, NewY) :-
    NewY is Y - 1,
    NewX is X + 1.
stepLeftTop(X, Y, NewX, NewY) :-
    NewY is Y + 1,
    NewX is X - 1.
stepLeftBottom(X, Y, NewX, NewY) :-
    NewY is Y - 1,
    NewX is X - 1.
stepRight(X, Y, NewX, NewY) :-
    NewY is Y,
    NewX is X + 1.
stepTop(X, Y, NewX, NewY) :-
    NewY is Y + 1,
    NewX is X.
stepLeft(X, Y, NewX, NewY) :-
    NewY is Y,
    NewX is X - 1.
stepBottom(X, Y, NewX, NewY) :-
    NewY is Y - 1,
    NewX is X.
