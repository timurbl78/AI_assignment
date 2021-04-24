:- dynamic(queue/1).
:- dynamic(costsArray/1).
:- dynamic(pathsArray/1).
:- dynamic(visited/1).
:- dynamic(size/1).
:- dynamic(maxLength/1).
:- dynamic(actor/2).
:- dynamic(covid/2).
:- dynamic(mask/2).
:- dynamic(home/2).

queue([]).
costsArray([]).
pathsArray([]).
infinity(1000).
visited([]).

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



% create costs array, [inf, inf, inf, inf, ...] and cost 0 on [ActorX, ActorY] cell
% create paths array [[], [], [], ...] and path [ActorX, ActorY] on [ActorX, ActorY] cell
% create visited array [0, 0, 0, ...]
% create Queue [[ActorX, ActorY]]
% run Dijkstra
% after dijkstra we need to find the shortest pat
% there are two options
% Actor -> Home
% Actor -> Mask -> Home
% lets check it
% write answer
main :-
    actor(ActorX, ActorY),
    size(Size),
    Size1 is Size * Size,
    infinity(Inf),
    fillArray([], Inf, CArray, Size1),
    changeValueOfCell(ActorX, ActorY, 0, CArray, CostsArray),
    costsArray(CurrCostsArray),
    asserta(costsArray(CostsArray)),
    retract(costsArray(CurrCostsArray)),

    Queue = [[ActorX, ActorY]],
    queue(CurrQueue),
    asserta(queue(Queue)),
    retract(queue(CurrQueue)),
    
    fillArray([], 0, VisitedArray, Size1),
    visited(CurrVisitedArray),
    asserta(visited(VisitedArray)),
    retract(visited(CurrVisitedArray)),
    
    fillArray([], [], PArray, Size1),
    changeValueOfCell(ActorX, ActorY, [[ActorX, ActorY]], PArray, PathsArray),
    pathsArray(CurrPathsArray),
    asserta(pathsArray(PathsArray)),
    retract(pathsArray(CurrPathsArray)),
    dijkstra,
    % after dijkstra we need to find the shortest pat
    % there are two options
    % Actor -> Home
    % Actor -> Mask -> Home
    % lets check it
    findShortestPath(Path),
    write(Path), nl,
    length(Path, L),
    write(L), write(" steps").

    
dijkstra :-
    queue(Queue),
    length(Queue, L),
    L = 0.
dijkstra :-
    queue(Queue),
    not(length(Queue, 0)),
    Queue = [[HeadX, HeadY]|_],

    %update VisitedArray

    getIndexOfCell(HeadX, HeadY, HeadIndex),
    HeadIndexMinus1 is HeadIndex - 1,
    visited(VisitedArray),
    nth0(HeadIndexMinus1, VisitedArray, 0),
    changeAt(HeadIndex, 1, VisitedArray, NewVisitedArray),
    assert(visited(NewVisitedArray)),
    retract(visited(VisitedArray)),

    % for all possible steps apply testFunc
    allPossibleSteps(HeadX, HeadY, Steps),
    forall(member([NewX, NewY], Steps), testFunc(HeadX, HeadY, NewX, NewY)),
    dijkstra.

% compares costs and updates the path if needed
testFunc(HeadX, HeadY, NewX, NewY) :-
    pathsArray(PathsArray),
    costsArray(CostsArray),
    queue(Queue),
    getIndexOfCell(HeadX, HeadY, HeadIndex),
	getIndexOfCell(NewX, NewY, NewIndex),
    	HeadIndexMinus1 is HeadIndex - 1,
    	HewIndexMinus1 is NewIndex - 1,
    	nth0(HeadIndexMinus1, CostsArray, HeadCost),
    	nth0(HeadIndexMinus1, PathsArray, HeadPath),
    	nth0(HewIndexMinus1, CostsArray, NewCost),
    	
    	HeadCostPlus1 is HeadCost + 1,

    	% if we find a better way - update
    	((HeadCostPlus1 < NewCost,
        	% Path = HeadPath + CurrentCell    
        	append(HeadPath, [[NewX, NewY]], NewPath),
            % update Path
            changeAt(NewIndex, NewPath, PathsArray, NewPathsArray),
            % Cost = CostHead + 1
        	changeAt(NewIndex, HeadCostPlus1, CostsArray, NewCostsArray),
            % add cell to queue
            append(Queue, [[NewX, NewY]], NQueue),
    		delete(NQueue, [HeadX, HeadY], NewQueue));

        % else just change names of vars
		(HeadCostPlus1 >= NewCost,
        	NewPathsArray = PathsArray,
            NewCostsArray = CostsArray,
            NQueue = Queue,
            delete(NQueue, [HeadX, HeadY], NewQueue)
        )),
    
    % update rules
    asserta(pathsArray(NewPathsArray)),
    retract(pathsArray(PathsArray)),

    asserta(queue(NewQueue)),
    retract(queue(Queue)),

    asserta(costsArray(NewCostsArray)),
    retract(costsArray(CostsArray)).

% build the shortest path to home from X, Y
buildPath(X, Y, Path) :-
    pathsArray(ResultPathsArray),
    getIndexOfCell(X, Y, Index),
    IndexMinus1 is Index - 1,
    nth0(IndexMinus1, ResultPathsArray, Path1),
    getShortestPath(X, Y, [_|Path2]),
    append(Path1, Path2, Path).

getShortestPath(X, Y, Path) :-
    home(X, Y),
    Path = [[X, Y]].
getShortestPath(X, Y, Path) :-
    home(HomeX, HomeY),
    % we need to go diagonally while we can
    (
        (HomeX < X, NewX is X - 1);
        (HomeX > X, NewX is X + 1);
        (HomeX = X, NewX is X)
    ),
    (
        (HomeY < Y, NewY is Y - 1);
        (HomeY > Y, NewY is Y + 1);
        (HomeY = Y, NewY is Y)
    ),
    getShortestPath(NewX, NewY, NewPath),
    Path = [[X, Y] | NewPath].

% compares two options:
% Actor -> Home
% Actor -> Mask -> Home
findShortestPath(Path) :-
    home(HomeX, HomeY),
    getIndexOfCell(HomeX, HomeY, HomeIndex),
    HomeIndexMinus1 is HomeIndex - 1,
    infinity(Inf),
    
    pathsArray(ResultPathsArray),
    costsArray(ResultCostsArray),
    
    findall([X, Y], visitedMask(X, Y), Masks),
    chooseChortest(Masks, [MaskX, MaskY]),
    pathLengthThroughMask(MaskX, MaskY, MaskL),

    nth0(HomeIndexMinus1, ResultCostsArray, HomeCost),
    % check if the path exists or not
    min(MaskL, HomeCost) < Inf,
    ((
        HomeCost =< MaskL,
        nth0(HomeIndexMinus1, ResultPathsArray, Path)
    );(
        HomeCost > MaskL,
        buildPath(MaskX, MaskY, Path)
    )).


chooseChortest([[X, Y] | []], [X, Y]).
chooseChortest([[X1, Y1] | T], [X2, Y2]) :-
    chooseChortest(T, [X3, Y3]),
    pathLengthThroughMask(X1, Y1, L1),
    pathLengthThroughMask(X3, Y3, L3),
    ((
        L1 < L3,
        X2 is X1,
        Y2 is Y1
    );(
        L1 >= L3,
        X2 is X3,
        Y2 is Y3
    )).

pathLengthThroughMask(X, Y, Length) :-
    getIndexOfCell(X, Y, Index),
    home(HomeX, HomeY),
    costsArray(ResultCostsArray),
    IndexMinus1 is Index - 1,
    nth0(IndexMinus1, ResultCostsArray, Cost),
    distance(HomeX, HomeY, X, Y, DistanceMaskHome),
    Length is Cost + DistanceMaskHome.
 
visitedMask(X, Y) :-
    visited(VisitedArray),
    mask(X, Y),
    getIndexOfCell(X, Y, Index),
    IndexMinus1 is Index - 1,
    nth0(IndexMinus1, VisitedArray, 1).


getIndexOfStep(X, Y, NewX, NewY) :-
    NewX is X - 1,
    NewY is Y - 1.

getIndexOfCell(X, Y, Index) :-
    size(Size),
    Index is Size * (Y - 1) + X.
getCellOfIndex(Index, X, Y) :-
    I is Index - 1,
    size(Size), 
    Y1 is (I div Size),
    X1 is (I mod (Size)),
    X is X1 + 1,
    Y is Y1 + 1.

changeValueOfCell(X, Y, Value, Array, ResultArray) :-
    getIndexOfCell(X, Y, Index),
    changeAt(Index, Value, Array, ResultArray).

changeAt(Index, Value, Array, ResultArray) :-
    insertAt(Value, Array, Index, ArrayAfterInsert),
    Index1 is Index + 1,
    removeAt(_, ArrayAfterInsert, Index1, ResultArray).

fillArray(I, _, Cells, Size) :-
    length(I, Size),
    Cells = [].
fillArray(I, Value, Cells, Size) :-
    length(I, Len),
    Len < Size,
    append(I, [1], NewI),
    fillArray(NewI, Value, ResultCells, Size),
    Cells = [Value | ResultCells].


% Remove the K'th element from a list.
% Taken from https://www.ic.unicamp.br/~meidanis/courses/mc336/2009s2/prolog/problemas/
removeAt(X,[X|Xs],1,Xs).
removeAt(X,[Y|Xs],K,[Y|Ys]) :- K > 1, 
   K1 is K - 1, removeAt(X,Xs,K1,Ys).

% Insert an element at a given position into a list.
% Taken from https://www.ic.unicamp.br/~meidanis/courses/mc336/2009s2/prolog/problemas/
insertAt(X,L,K,R) :- removeAt(X,R,K,L).


% find the distance to some point
distance(FromX, FromY, ToX, ToY, Distance) :-
    Distance is max(abs(ToX - FromX), abs(ToY - FromY)).

% covid zone = covid cell and adjacent cells
isCovidZone(X, Y) :-
    covid(A, B),
    A0 is A-1,
    A1 is A+1,
    B0 is B-1,
    B1 is B+1,
    between(A0, A1, X),
    between(B0, B1, Y).

% check whether the position is valid or not
isPositionValid(X, Y) :-
    squareLattice(X, Y),
    isSafePlace(X, Y).

% safe place if we not in CovidZone
isSafePlace(X, Y) :-
    not(isCovidZone(X, Y)).

equal(X1, Y1, X2, Y2) :-
    X1 = X2,
    Y1 = Y2.

adjacent(X1, Y1, X2, Y2) :-
    squareLattice(X1, Y1),
    squareLattice(X2, Y2),
    abs(X1 - X2) =< 1,
    abs(Y1 - Y2) =< 1,
    not(equal(X1, Y1, X2, Y2)).

%  returns an array of all possible steps
allPossibleSteps(X, Y, Steps) :-
    findall([X1, Y1], (adjacent(X, Y, X1, Y1), isSafePlace(X1, Y1)), Steps).
