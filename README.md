# Q-learning-maze
 A demo using Q-learning to solve a maze
 
 
 
 >Created with Matlab, it uses a learning agent to solve a maze which is stored in a text file. Two such samples are provided for experimentation. This is an extension of Asad Ali's work found on Matlab's file exchange site. The additions include the implementation of flagging already visited routes and the use of eligibility traces, alongside some optimizations. The program can graphically show the current progress and position of the agent, however, this greatly reduces the speed. It is more tweaked for gathering statistical data. Thus, it saves the number of steps it took to solve the maze after each learning episode and saves that in a .csv file.
 
 ### How to use:
 - Set the options in maze_solver, these exclude alpha and gamma, as those will be passed in as parameters.
 - Run maze_solver(alpha,gamma)
 - You will see the maze graphically if it was enabled.
 - The output will be saved as a .csv file with the columns representing the learning episodes and the rows representing the repeated runs. It will contain the number of steps it took to solve the maze.
 - There is another auto_maze_solver() function, which speeds up testing with a range of parameter pairs using a parallel for loop.
 
#### The following is used to update the Q-matrix
```
Q(prevX,prevY,direction) = Q(prevX,prevY,direction) + alpha*(R+gamma*max(Q(X,Y,:)) - Q(prevX,prevY,direction));
```
 
#### It changes to the below if eligibility traces are enabled
```
delta = R + gamma*max(Q(X,Y,:)) - Q(prevX,prevY,direction);
E(prevX,prevY,direction) = E(prevX,prevY,direction) + 1;
Q = Q + alpha*delta*E;
E = gamma*lambda*E;
```
 
### Credits

Asad Ali (2020). Reinforcement Learning (Q-Learning) (https://www.mathworks.com/matlabcentral/fileexchange/63407-reinforcement-learning-q-learning), MATLAB Central File Exchange.
 
 
