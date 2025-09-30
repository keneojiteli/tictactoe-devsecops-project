import React, { useState, useEffect } from 'react';
import { RefreshCw, Award } from 'lucide-react';
import Board from './components/Board';
import ScoreBoard from './components/ScoreBoard';
import GameHistory from './components/GameHistory';
import { calculateWinner, checkDraw } from './utils/gameLogic';

function App() {
  // Game state
  const [board, setBoard] = useState(Array(9).fill(null));
  const [xIsNext, setXIsNext] = useState(true);
  const [scores, setScores] = useState({ X: 0, O: 0, draws: 0 });
  const [gameHistory, setGameHistory] = useState<Array<{
    winner: string | null;
    board: Array<string | null>;
    date: Date;
  }>>([]);
  const [gameStatus, setGameStatus] = useState<'playing' | 'won' | 'draw'>('playing');
  const [winningLine, setWinningLine] = useState<number[] | null>(null);

  // Check for winner or draw
  useEffect(() => {
    const result = calculateWinner(board);
    
    if (result) {
      setGameStatus('won');
      setWinningLine(result.line);
      
      // Update scores
      setScores(prevScores => ({
        ...prevScores,
        [result.winner]: prevScores[result.winner as keyof typeof prevScores] + 1
      }));
      
      // Add to history
      setGameHistory(prev => [
        ...prev, 
        { winner: result.winner, board: [...board], date: new Date() }
      ]);
    } else if (checkDraw(board)) {
      setGameStatus('draw');
      
      // Update draw count
      setScores(prevScores => ({
        ...prevScores,
        draws: prevScores.draws + 1
      }));
      
      // Add to history
      setGameHistory(prev => [
        ...prev, 
        { winner: null, board: [...board], date: new Date() }
      ]);
    }
  }, [board]);

  // Handle square click
  const handleClick = (index: number) => {
    // Return if square is filled or game is over
    if (board[index] || gameStatus !== 'playing') return;
    
    const newBoard = [...board];
    newBoard[index] = xIsNext ? 'X' : 'O';
    
    setBoard(newBoard);
    setXIsNext(!xIsNext);
  };

  // Reset the game
  const resetGame = () => {
    setBoard(Array(9).fill(null));
    setXIsNext(true);
    setGameStatus('playing');
    setWinningLine(null);
  };

  // Reset all stats
  const resetStats = () => {
    resetGame();
    setScores({ X: 0, O: 0, draws: 0 });
    setGameHistory([]);
  };

  // Get current game status message
  const getStatusMessage = () => {
    if (gameStatus === 'won') {
      const winner = !xIsNext ? 'X' : 'O';
      return `Player ${winner} wins!`;
    } else if (gameStatus === 'draw') {
      return "It's a draw!";
    } else {
      return `Next player: ${xIsNext ? 'X' : 'O'}`;
    }
  };


  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-gray-800 to-black flex flex-col items-center justify-center p-6">
      <div className="max-w-5xl w-full bg-gray-900 border border-gray-700 rounded-2xl shadow-2xl overflow-hidden">
        
        {/* Header */}
        <div className="p-6 bg-gradient-to-r from-teal-600 to-orange-500 text-white text-center">
          <h1 className="text-4xl font-extrabold tracking-wide flex items-center justify-center gap-2">
            <Award className="h-8 w-8 text-yellow-300" />
            Tic Tac Toe
          </h1>
          <p className="text-gray-100 mt-1 italic">Play smart. Win big. ✨</p>
        </div>
        
        {/* Body */}
        <div className="p-8 grid grid-cols-1 md:grid-cols-3 gap-8">
          
          {/* Game board */}
          <div className="md:col-span-2 flex flex-col items-center">
            <div className="mb-4 text-center">
              <h2 className="text-2xl font-semibold text-teal-400 drop-shadow-md">{getStatusMessage()}</h2>
            </div>
            
            <Board 
              squares={board} 
              onClick={handleClick} 
              winningLine={winningLine}
            />
            
            {/* Buttons */}
            <div className="mt-6 flex gap-4">
              <button 
                onClick={resetGame}
                className="flex items-center gap-2 bg-teal-600 hover:bg-teal-700 text-white py-2 px-6 rounded-lg shadow-md transition-transform transform hover:scale-105"
              >
                <RefreshCw className="h-4 w-4" />
                New Game
              </button>
              <button 
                onClick={resetStats}
                className="bg-orange-500 hover:bg-orange-600 text-white py-2 px-6 rounded-lg shadow-md transition-transform transform hover:scale-105"
              >
                Reset All
              </button>
            </div>
          </div>
          
          {/* Sidebar: Scores + History */}
          <div className="flex flex-col gap-6">
            <div className="bg-gray-800 rounded-xl p-4 shadow-md">
              <ScoreBoard scores={scores} />
            </div>
            <div className="bg-gray-800 rounded-xl p-4 shadow-md overflow-y-auto max-h-80">
              <GameHistory history={gameHistory} />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;

//         <div className="min-h-screen bg-red-600 flex items-center justify-center">
//   <h1 className="text-white text-4xl">Hello Tailwind!</h1>
// </div>

