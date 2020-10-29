function [] = auto_maze_solver()
%AUTO_MAZE_SOLVER Automatically calls the maze_solver function with different variables
%   This can be used to automatically run the agent with different alpha and
%   gamma pairs to gather statistical data. One set will have a fixed aplha
%   and the other will have a fixed gamma value, which can be set below.
%   The other parameter will be varied from 0.1 to 1 in 0.1 increments.

%default values are
alpha = 0.5;
gamma = 0.8;

parfor n = 1:20
    if n <= 10
        maze_solver(n/10,gamma)
    else
        maze_solver(alpha,(n-10)/10)
    end
end

end
