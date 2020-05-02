import itertools
import random

from copy import deepcopy
from collections import deque


class Minesweeper():
    """
    Minesweeper game representation
    """

    def __init__(self, height=8, width=8, mines=8):

        # Set initial width, height, and number of mines
        self.height = height
        self.width = width
        self.mines = set()

        # Initialize an empty field with no mines
        self.board = []
        for i in range(self.height):
            row = []
            for j in range(self.width):
                row.append(False)
            self.board.append(row)

        # Add mines randomly
        while len(self.mines) != mines:
            i = random.randrange(height)
            j = random.randrange(width)
            if not self.board[i][j]:
                self.mines.add((i, j))
                self.board[i][j] = True

        # At first, player has found no mines
        self.mines_found = set()

    def print(self):
        """
        Prints a text-based representation
        of where mines are located.
        """
        for i in range(self.height):
            print("--" * self.width + "-")
            for j in range(self.width):
                if self.board[i][j]:
                    print("|X", end="")
                else:
                    print("| ", end="")
            print("|")
        print("--" * self.width + "-")

    def is_mine(self, cell):
        i, j = cell
        return self.board[i][j]

    def nearby_mines(self, cell):
        """
        Returns the number of mines that are
        within one row and column of a given cell,
        not including the cell itself.
        """

        # Keep count of nearby mines
        count = 0

        # Loop over all cells within one row and column
        for i in range(cell[0] - 1, cell[0] + 2):
            for j in range(cell[1] - 1, cell[1] + 2):

                # Ignore the cell itself
                if (i, j) == cell:
                    continue

                # Update count if cell in bounds and is mine
                if 0 <= i < self.height and 0 <= j < self.width:
                    if self.board[i][j]:
                        count += 1

        return count

    def won(self):
        """
        Checks if all mines have been flagged.
        """
        return self.mines_found == self.mines


class Sentence():
    """
    Logical statement about a Minesweeper game
    A sentence consists of a set of board cells,
    and a count of the number of those cells which are mines.
    """

    def __init__(self, cells, count):
        self.cells = set(cells)
        self.count = count
        self.mines = set()
        self.safes = set()

    def __eq__(self, other):
        return self.cells == other.cells and self.count == other.count and self.mines == other.mines and self.safes == other.safes

    def __str__(self):
        return f"{self.cells} = {self.count}, mines:{self.mines}, safes:{self.safes}"

    def known_mines(self):
        """
        Returns the set of all cells in self.cells known to be mines.
        """
        self.mines

    def known_safes(self):
        """
        Returns the set of all cells in self.cells known to be safe.
        """
        self.safes

    def mark_mine(self, cell):
        """
        Updates internal knowledge representation given the fact that
        a cell is known to be a mine.
        """
        if cell in self.cells:
            self.mines.add(cell)
            self.cells.remove(cell)
            self.count -= 1

    def mark_safe(self, cell):
        """
        Updates internal knowledge representation given the fact that
        a cell is known to be safe.
        """
        if cell in self.cells:
            self.safes.add(cell)
            self.cells.remove(cell)


class MinesweeperAI():
    """
    Minesweeper game player
    """

    def __init__(self, height=8, width=8):

        # Set initial height and width
        self.height = height
        self.width = width

        # Keep track of which cells have been clicked on
        self.moves_made = set()

        # Keep track of cells known to be safe or mines
        self.mines = set()
        self.safes = set()

        # List of sentences about the game known to be true
        self.knowledge = deque()

    def mark_mine(self, cell):
        """
        Marks a cell as a mine, and updates all knowledge
        to mark that cell as a mine as well.
        """
        self.mines.add(cell)
        for sentence in self.knowledge:
            sentence.mark_mine(cell)

    def mark_safe(self, cell):
        """
        Marks a cell as safe, and updates all knowledge
        to mark that cell as safe as well.
        """
        self.safes.add(cell)
        for sentence in self.knowledge:
            sentence.mark_safe(cell)

    def add_knowledge(self, cell, count):
        """
        Called when the Minesweeper board tells us, for a given
        safe cell, how many neighboring cells have mines in them.

        steps:
            1) mark the cell as a move that has been made
            2) mark the cell as safe
            3) add a new sentence to the AI's knowledge base
               based on the value of `cell` and `count`
            4) mark any additional cells as safe or as mines
               if it can be concluded based on the AI's knowledge base
            5) add any new sentences to the AI's knowledge base
               if they can be inferred from existing knowledge
        """
        self.moves_made.add(cell)

        self.mark_safe(cell)

        neighbors, updated_count = self.get_neighbors(cell, count)
        if neighbors != set():
            self.knowledge.appendleft(Sentence(cells=neighbors, count=updated_count))

        for sentence in self.knowledge:
            if sentence.count == 0:
                for cell in deepcopy(sentence.cells):
                    self.mark_safe(cell)
            elif sentence.count >= len(sentence.cells):
                for cell in deepcopy(sentence.cells):
                    self.mark_mine(cell)

        self.knowledge_refresh()

    def make_safe_move(self):
        """
        Returns a safe cell to choose on the Minesweeper board.
        The move must be known to be safe, and not already a move
        that has been made.

        This function may use the knowledge in self.mines, self.safes
        and self.moves_made, but should not modify any of those values.
        """
        for safe in self.safes:
            if not safe in self.moves_made and not safe in self.mines:
                return safe

        return None


    def make_random_move(self):
        """
        Returns a move to make on the Minesweeper board.
        Should choose randomly among cells that:
            1) have not already been chosen, and
            2) are not known to be mines
        """
        # get copy of the empty board
        board = set([(i, j) for i in range(self.height) for j in range(self.width)])

        for move in board:
            if not move in self.moves_made and not move in self.mines:
                return move

        return None

    def get_neighbors(self, cell, count):
        """ 
        get the set containing all the neighboring cells of the given cell which are hidden or yet to B evaluated
        i.e. get those neighbours which are not marked for mines nor are known safe and are within the given cell {helper:mask it}
        """
        row, col = cell
        # get all the neighbors
        neighbors = set([(min(self.height - 1, max(row + i, 0)), min(self.width - 1, max(col + j, 0))) 
                            for i in range(-1, 2)
                                for j in range(-1, 2)])

        for neighbor in deepcopy(neighbors):
            if neighbor in self.safes or neighbor == cell:
                neighbors.remove(neighbor)
            elif neighbor in self.mines:
                neighbors.remove(neighbor)
                count -= 1

        return neighbors, count

    def knowledge_refresh(self):
        """ 
        If, based on any of the sentences in self.knowledge, new sentences can be inferred (using the subset method), then those sentences should be added to the knowledge base as well.
        """
        knowledge_len = len(self.knowledge)
        for i, sentence in enumerate(deepcopy(self.knowledge)):
            if sentence.cells != set():
                for j in range(i+1, knowledge_len):
                    if self.knowledge[j].cells != set() and sentence.cells != self.knowledge[j].cells:
                        if sentence.cells.issubset(self.knowledge[j].cells):
                            new_set = self.knowledge[j].cells.difference(sentence.cells)
                            new_count = self.knowledge[j].count - sentence.count
                            if new_set != set():
                                new_sentence = Sentence(cells=new_set, count=new_count)
                                if not new_sentence in self.knowledge:
                                    self.knowledge.append(new_sentence)

                        elif self.knowledge[j].cells.issubset(sentence.cells):
                            new_set = sentence.cells.difference(self.knowledge[j].cells)
                            new_count = sentence.count - self.knowledge[j].count
                            if new_set != set():
                                new_sentence = Sentence(cells=new_set, count=new_count)
                                if not new_sentence in self.knowledge:
                                    self.knowledge.append(new_sentence)
            
            # remove unnecessery knowledge
            if sentence.cells == set() and sentence.known_mines() == set() and sentence.known_safes() == set():
                self.knowledge.remove(sentence)