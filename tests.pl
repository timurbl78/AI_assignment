% :- module(tests, [
%   test1/0,
%   test2/0,
%   test3/0,
%   test4/0,
%   test5/0,
%   test6/0
% ]).



% TEST 1
% size(5).
%maxLength(18).
%actor(1, 1).
%covid(2,3).
%covid(3,3).
%mask(2, 5). % mask = doctor
%mask(3, 5). % mask = doctor
%home(1, 5).
% Result
% [[2,1],[3,1],[4,1],[5,2],[5,3],[5,4],[4,5],[3,5],[2,5],[1,5]]
% 10 steps



% TEST 2
% size(9).
%maxLength(25).
%actor(1, 1).
%covid(2,7).
%covid(5,2).
%mask(5, 5). % mask = doctor
%mask(4, 8). % mask = doctor
%home(8, 4).
% Result
% [[2,2],[3,3],[4,4],[5,4],[6,4],[7,4],[8,4]|]
% 7 steps


% TEST 3
% size(9).
% maxLength(25).
% actor(1, 1).
% covid(2, 3).
% covid(5, 3).
% mask(8, 2).
% mask(9, 8).
% mask(9, 9).
% home(1, 8).
% Result
% [[2,1],[3,1],[4,1],[5,1],[6,1],[7,2],[7,3],[7,4],[6,5],[5,5],[4,5],[3,6],[2,7],[1,8]]
% 14 steps

% TEST 4
% size(9).
% maxLength(25).
% actor(1, 1).
% covid(1, 3).
% covid(3, 1).
% mask(3, 5).
% mask(5, 5).
% home(5, 9).
% Result
% false

% TEST 5
% size(9).
% maxLength(25).
% actor(1, 1).
% covid(6, 1).
% covid(5, 2).
% mask(1, 8).
% mask(7, 3).
% home(9, 2).
% Result
% [[2,2],[3,3],[4,4],[5,4],[6,4],[7,4],[8,3],[9,2]]
% 8 Steps

% TEST 6 (result path contains mask)
% size(9).
% maxLength(25).
% actor(1, 1).
% covid(8, 3).
% covid(7, 1).
% mask(3, 8).
% mask(7, 7).
% home(9, 1).
% Result
% [[1,1],[2,2],[3,3],[4,4],[5,5],[6,6],[7,7],[8,6],[9,5],[9,4],[9,3],[9,2],[9,1]]
% 13 steps