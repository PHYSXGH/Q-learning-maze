function maze_solver(alpha, gamma)
close all;

global maze2D;
global tmpMaze2D;
global visitFlag;

%THE X AND Y COORDINATES ARE SWITCHED AROUND. THE ROWS ARE THE X AND THE
%COLUMNS ARE THE Y VALUES

%OPTIONS

DISPLAY_ANIMATION = false; % whether or not to display the animation during training. greatly slows down the process.
NUM_ITERATIONS = 10; % the number of learning episodes in each run
RUNS = 15; % no. of runs to average at the end
FLAG_VISITED = true; %mark the visited spots to increase the reward for stepping on them

ELIG_TRACES = 1; %enable the use of eligibility traces and change the algorithm. it adds the E matrix to store the additional values
lambda = 0.9; %this values is only used WITH the eligibility traces

maze = 'maze-61-21.txt'; %the maze to be used by the algorithm

%/OPTIONS

%STATISTICS COUNTERS

%two rows with the gamma in the first and the no. of steps to find the target in the second
stepsPerIteration = int32.empty(1,0);
%the distance from the target after each iteration [movement of the square] of the maze
distanceFromTarget = zeros(NUM_ITERATIONS, 1);

%/STATISTICS COUNTERS

%FILE OUTPUT PARAMETERS
stringsToCombine = string.empty(0,7);

stringsToCombine(1,2) = "alpha";
stringsToCombine(1,4) = "gamma";
stringsToCombine(1,6) = "flag";
if FLAG_VISITED == 0
    stringsToCombine(1,7) = "false";
else
    stringsToCombine(1,7) = "true";
end

%/FILE OUTPUT PARAMETERS

%read the maze from the file
[maze2D,startX,startY] = Read_Maze(maze); %returns maze with starting point
imagesc(maze2D) % show the maze

% a copy of the maze that we will use for display
tmpMaze2D = maze2D;
%and reset the starting value to 50 for the working matrix
maze2D(startX,startY) = 50;

%get the coordinates of the endpoint
[goalX,goalY] = find(maze2D == 100);

%create a reward matrix
%the layers represent the directions of movement as follows
%1-up / 2-left / 3-down / 4-right
Q = zeros(size(maze2D,1),size(maze2D,2),4);



%the possible states the process can be in are
WALL = 0;
SEARCHING = 1;
FOUND = 5;

%execute multiple runs for averaging the results
for n = 1 : RUNS

    %run the training episodes
    for i = 1 : NUM_ITERATIONS
        X = startX; Y = startY;
        status = SEARCHING; %status of processing

        %counts the movements of the square
        stepCounter = 0;
        
        %create a new matrix for the visited flags if they are enabled
        if FLAG_VISITED == true
            visitFlag = zeros(size(maze2D,1),size(maze2D,2));
            visitFlag(X,Y) = 1;
        end
        
        if ELIG_TRACES == 1
            E = zeros(size(maze2D,1),size(maze2D,2),4);
        end

        while status ~= FOUND
            %save the previous location for the algorithm
            prevX = X;
            prevY = Y;
            
            %find the step with the highest Q value
            %if two have the same value, then it will be randomly selected from
            %them
            
            %val is the value and index is the ':' or the layer in which
            %the value was found / was [val,index] = ~
            val = max(Q(X,Y,:));
            
            %since the previous line only returns the first occurence, we
            %need to search once more to get all occurences if there are
            %more than one. Returns the numbers of the layers that contain
            %the largest number
            indices = find(Q(X,Y,:) == val);
            
            if FLAG_VISITED == false
                if size(indices,1) > 1
                    %get a random layer to choose the direction of movement
                    %if 'indices' has multiple entries. Direction is the
                    %layer number in which we will move.
                    direction = indices(randperm(length(indices),1)); 
                else
                    direction = indices(1);
                end
            else
                direction = checkFlags(X,Y,indices);
                visitFlag(X,Y) = 1;
            end
            
            %move the square to the chosen direction
            [X,Y,status] = Move(X,Y,direction);

            %add a step to the counter, even if the move to the chosen direction
            %was unsuccessful. Can be used to track the progress
            stepCounter = stepCounter + 1;
            
            %define the reward value based on the outcome of the move
            if status == WALL
                R = -1;
            elseif status == FOUND
                R = 1;
            else
                R = 0;
            end
            
            if ELIG_TRACES == 0
                %use the equation to update the Q matrix
                Q(prevX,prevY,direction) = Q(prevX,prevY,direction) + alpha*(R+gamma*max(Q(X,Y,:)) - Q(prevX,prevY,direction));
            else
                %use the equation with eligibility traces to update the Q
                %and E matrices.
                if status == SEARCHING | status == FOUND
                    delta = R + gamma*max(Q(X,Y,:)) - Q(prevX,prevY,direction);
                    E(prevX,prevY,direction) = E(prevX,prevY,direction) + 1;

                    Q = Q + alpha*delta*E;
                    E = gamma*lambda*E;
                elseif status == WALL
                    Q(prevX,prevY,direction) = Q(prevX,prevY,direction) + alpha*(R+gamma*max(Q(X,Y,:)) - Q(prevX,prevY,direction));
                end
            end

            %display the animation
            if rem(stepCounter,1) == 0 && DISPLAY_ANIMATION == true
                drawX = [X Y];
                drawY = [goalX goalY];
                dist = norm(drawX-drawY,1);
                s = sprintf('Manhattan Distance = %f',dist);
                distanceFromTarget(i,stepCounter) = dist;
                imagesc(tmpMaze2D);%,colorbar;
                title(s);
                drawnow
            end
        end

        %remove the old square after finding the goal
        tmpMaze2D(X,Y) = 50;

        %save the steps
        stepsPerIteration(n,i) = stepCounter;
        
        %iteration counter
        iteration = i
    end
    %dislpay the loop no. as a progress indicator
    run = n
    %reset the Q-matrix
    Q = zeros(size(maze2D,1),size(maze2D,2),4);
end

avgStep = mean(stepsPerIteration,1);
stepsPerIteration(RUNS+1,:) = avgStep;

stringsToCombine(1,3) = alpha;
stringsToCombine(1,5) = gamma;

stringsToCombine(1,1) = "steps";
filename = join(stringsToCombine,"_");
filename = strcat(filename,".csv");
charFilename = convertStringsToChars(filename);

csvwrite(charFilename,stepsPerIteration);

end

%function to move to the new position given the coordinates and direction
%it does not allow movements towards walls.
function [newX,newY,status] = Move(currentX,currentY,direction)
global tmpMaze2D;

newX = currentX;
newY = currentY;
if direction == 1
    value = tmpMaze2D(currentX-1,currentY);
elseif direction == 2
    value = tmpMaze2D(currentX,currentY-1);
elseif direction == 3
    value = tmpMaze2D(currentX+1,currentY);
elseif direction == 4
    value = tmpMaze2D(currentX,currentY+1);
end

if value == 0 %walls
    status = 0;
    
elseif value == 50 %corridors
        
    if direction == 1
        newX = currentX-1;
    elseif direction == 2
        newY = currentY-1;
    elseif direction == 3
        newX = currentX+1;
    elseif direction == 4
        newY = currentY+1;
    end
    status = 1;
    
elseif value == 100 %goal/exit
    status = 5;

else
    status = 1;
end

%update graphics
tmpMaze2D(currentX,currentY) = 50;
tmpMaze2D(newX,newY) = 60;
end

%function to check if a cell has been visited and return the direction of
%the unvisited cell with the highest Q-value, or if there is no unvisited
%cell, it returns the direction of the cell with the highest Q-value.
function [directionRet] = checkFlags(currentX,currentY,directionList)
global visitFlag;

directionSize = size(directionList, 1);
cellpairs = zeros(directionSize,2);
cellpairsFilt = int16.empty(0,2);

    %get the visited flags for the cells of interest
    for n = 1 : directionSize
        direction = directionList(n,1);
        cellpairs(n,1) = direction;

        if direction == 1
            cellpairs(n,2) = visitFlag(currentX-1,currentY);
        elseif direction == 2
            cellpairs(n,2) = visitFlag(currentX,currentY-1);
        elseif direction == 3
            cellpairs(n,2) = visitFlag(currentX+1,currentY);
        elseif direction == 4
            cellpairs(n,2) = visitFlag(currentX,currentY+1);
        end
    end
   
    %copy the unvisited pairs to a different matrix
    for m = 1 : size(cellpairs,1)
        if cellpairs(m,2) == 0
            nextRowIndex = size(cellpairsFilt,1);
            cellpairsFilt(nextRowIndex+1,:) = cellpairs(m,:);
        end
    end
    
    %if the matrix of the unvisited cells is not empty
    if size(cellpairsFilt,1) > 0
        %choose randomly from cellpairsFilt
        directionRet = cellpairsFilt(randperm(size(cellpairsFilt,1),1));
    else
        %choose randomly from cellpairs
        directionRet = cellpairs(randperm(size(cellpairs,1),1));
    end
    
end
