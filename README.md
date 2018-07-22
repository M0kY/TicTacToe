# TicTacToe

This TicTacToe app written in **Swift** was made within the scope of my graduation thesis. 

# Features

There are two versions of the game. In each the AI is implemented using a different algorithm

  - MinMax with Alpha-Beta Pruning
  - Reinforcement Learning (Temporal Difference Algorithm)

# Training the AI

The training method was to let 2 AI-s which use the same algorithm (TD) play against each other for 10,000 iterations. Below are presented the results of the AI against a human player after different number of training iterations.

|  | 1,000 iterations | 5,000 iterations | 10,000 iterations |
| ------ | ------ | ------ | ------ |
| **Human Wins** | 5 | 7 | 0 |
| **Draw** | 5 | 3 | 10 |
| **AI Wins** | 0 | 0 | 0 |

Better results for the 1,000 iteration case are due to the human player requiring more time to find out the stategy to abuse.
