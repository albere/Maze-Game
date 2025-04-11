import random
from collections import deque
from functools import cached_property

import pygame


# Initialize Pygame
pygame.init()

# Constants
CELL_SIZE = 15
ROWS, COLS = 41, 41  # Maze grid is now 41x41
BORDER_WIDTH = 2  # 2 rows/columns of blue border around the maze (reduced)
WIDTH, HEIGHT = (COLS + BORDER_WIDTH * 2) * CELL_SIZE, (ROWS + BORDER_WIDTH * 2) * CELL_SIZE  # Total window size

# Colors
WHITE = (255, 255, 255)
DARK_BLUE = (17, 57, 124)  # Wall color
ORANGE = (232, 181, 48)  # Trail color

MOVE_DELAY = 200  # milliseconds

# Load images
player_img = pygame.image.load("supe.png")
player_img = pygame.transform.scale(player_img, (CELL_SIZE, CELL_SIZE))

heart_img = pygame.image.load("/home/albere/heart.png")
heart_img = pygame.transform.scale(heart_img, (CELL_SIZE, CELL_SIZE))

brain_img = pygame.image.load("/home/albere/brain.png")
brain_img = pygame.transform.scale(brain_img, (CELL_SIZE, CELL_SIZE))

# Create window
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Maze Game")


class Maze:
    
    def __init__(self, cols: int, rows: int) -> None:
        self.cols = cols
        self.rows = rows
    
    def breadth_first_search(self, maze: list[list], visited: list[list], x, y) -> None:
        queue = deque([(x, y)])
        visited[y][x] = True
        while queue:
            cx, cy = queue.popleft()
            for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                nx, ny = cx + dx, cy + dy
                if 0 <= nx < self.cols and 0 <= ny < self.rows and not visited[ny][nx] and maze[ny][nx] == 0:
                    visited[ny][nx] = True
                    queue.append((nx, ny))
        
    def carve_passages(
            self,
            maze: list[list],
            visited: list[list],
            cx: int,
            cy: int) -> None:
        dirs = [(0, -1), (1, 0), (0, 1), (-1, 0)]
        random.shuffle(dirs)
        visited[cy][cx] = True
        maze[cy][cx] = 0
    
        for dx, dy in dirs:
            nx, ny = cx + dx * 2, cy + dy * 2
            if self.is_valid(nx, ny) and not visited[ny][nx]:
                maze[cy + dy][cx + dx] = 0
                self.carve_passages(maze, visited, nx, ny)
    
    # Function to generate the maze using recursive backtracking
    def generate(self):
        maze = [[1 for _ in range(self.cols)] for _ in range(self.rows)]  # 1 represents walls
        visited = [[False for _ in range(self.cols)] for _ in range(self.rows)]
    
        self.carve_passages(maze, visited, 1, 1)
    
        for _ in range(100):
            x, y = random.randrange(1, self.cols - 1), random.randrange(1, self.rows - 1)
            unknown_condition = (
                maze[y][x] == 1 
                and sum(
                    maze[ny][nx] == 0
                    for dx, dy
                    in [(-1, 0), (1, 0), (0, -1), (0, 1)]
                    if 0 <= (nx := x + dx) < self.cols
                    and 0 <= (ny := y + dy) < self.rows) >= 2)
            if unknown_condition:
                maze[y][x] = 0
                
        
        return maze

    def is_accessible(self, start_x, start_y, maze):
        visited = [[False for _ in range(self.cols)] for _ in range(self.rows)]
        self.breadth_first_search(maze, visited, start_x, start_y)
        return visited[start_y][start_x]
    
    def is_valid(self, nx: int, ny: int) -> bool:
        return 0 <= nx < self.cols and 0 <= ny < self.rows
    
    def reset(self, maze: list[list]) -> tuple[list[list], list[tuple[int, int]], int, int]:
        player_x, player_y = self.cols // 2, self.rows // 2  # Set player at the center
        maze[player_y][player_x] = 0  # Make sure the center is an open path
    
        if not self.is_accessible(player_x, player_y, maze):
            maze = self.generate()
    
        trail = [(player_x, player_y)]
        return maze, trail, player_x, player_y
    

class MazeGame:
    rows = ROWS
    cols = COLS
    
    @cached_property
    def maze(self):
        return Maze(self.cols, self.rows)

    def run(self):    
        # Place heart and brain within the maze (inside the maze, not in the border)
        end_x1, end_y1 = 1, 1  # Move heart one row below the previous position (now at (1, 1))
        end_x2, end_y2 = COLS - 2, 1  # Move brain one row below the previous position (now at (COLS-2, 1))
        maze = self.maze.generate()
        maze[end_y1][end_x1] = 0  # Place heart at (1, 1) inside the maze
        maze[end_y2][end_x2] = 0  # Place brain at (COLS-2, 1) inside the maze
        maze, trail, player_x, player_y = self.maze.reset(maze)
        last_move_time = pygame.time.get_ticks()
    
        running = True
        clock = pygame.time.Clock()
        
        while running:
            clock.tick(60)
        
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    running = False
        
            keys = pygame.key.get_pressed()
            if keys[pygame.K_r]:
                maze, trail, player_x, player_y = self.maze.reset(maze)
                last_move_time = pygame.time.get_ticks()
        
            current_time = pygame.time.get_ticks()
            if current_time - last_move_time > MOVE_DELAY:
                prev_x, prev_y = player_x, player_y
                moved = False
        
                if keys[pygame.K_LEFT] and player_x > 0 and maze[player_y][player_x - 1] == 0:
                    player_x -= 1
                    moved = True
                elif keys[pygame.K_RIGHT] and player_x < COLS - 1 and maze[player_y][player_x + 1] == 0:
                    player_x += 1
                    moved = True
                elif keys[pygame.K_UP] and player_y > 0 and maze[player_y - 1][player_x] == 0:
                    player_y -= 1
                    moved = True
                elif keys[pygame.K_DOWN] and player_y < ROWS - 1 and maze[player_y + 1][player_x] == 0:
                    player_y += 1
                    moved = True
        
                if moved:
                    last_move_time = current_time
                    new_pos = (player_x, player_y)
                    if len(trail) > 1 and new_pos == trail[-2]:
                        trail.pop()
                    elif new_pos != trail[-1]:
                        trail.append(new_pos)
        
                if (player_x, player_y) == (end_x1, end_y1):
                    screen.fill(DARK_BLUE)
                    font = pygame.font.Font(None, 50)
                    text = font.render("Heart", True, WHITE)
                    text_rect = text.get_rect(center=(WIDTH // 2, HEIGHT // 2))
                    screen.blit(text, text_rect)
                    pygame.display.update()
                    pygame.time.delay(2000)
                    maze, trail, player_x, player_y = self.maze.reset(maze)
                    last_move_time = pygame.time.get_ticks()
                    pygame.time.delay(1000)
                elif (player_x, player_y) == (end_x2, end_y2):
                    screen.fill(DARK_BLUE)
                    font = pygame.font.Font(None, 50)
                    text = font.render("Brain", True, WHITE)
                    text_rect = text.get_rect(center=(WIDTH // 2, HEIGHT // 2))
                    screen.blit(text, text_rect)
                    pygame.display.update()
                    pygame.time.delay(2000)
                    maze, trail, player_x, player_y = self.maze.reset(maze)
                    last_move_time = pygame.time.get_ticks()                
                    pygame.time.delay(1000)
        
            screen.fill(DARK_BLUE)  # Draw the border
        
            # Draw maze (with adjusted positions for the border)
            for y in range(ROWS):
                for x in range(COLS):
                    color = WHITE if maze[y][x] == 0 else DARK_BLUE
                    pygame.draw.rect(screen, color, ((x + BORDER_WIDTH) * CELL_SIZE, (y + BORDER_WIDTH) * CELL_SIZE, CELL_SIZE, CELL_SIZE))
        
            # Draw heart and brain (moved one space below)
            screen.blit(heart_img, ((end_x1 + BORDER_WIDTH) * CELL_SIZE, (end_y1 + BORDER_WIDTH) * CELL_SIZE))
            screen.blit(brain_img, ((end_x2 + BORDER_WIDTH) * CELL_SIZE, (end_y2 + BORDER_WIDTH) * CELL_SIZE))
        
            for i in range(1, len(trail)):
                x1, y1 = trail[i - 1]
                x2, y2 = trail[i]
                x1, y1 = (x1 + BORDER_WIDTH) * CELL_SIZE + CELL_SIZE // 2, (y1 + BORDER_WIDTH) * CELL_SIZE + CELL_SIZE // 2
                x2, y2 = (x2 + BORDER_WIDTH) * CELL_SIZE + CELL_SIZE // 2, (y2 + BORDER_WIDTH) * CELL_SIZE + CELL_SIZE // 2
                pygame.draw.line(screen, ORANGE, (x1, y1), (x2, y2), 2)
        
            screen.blit(player_img, ((player_x + BORDER_WIDTH) * CELL_SIZE, (player_y + BORDER_WIDTH) * CELL_SIZE))
            pygame.display.update()
        
        pygame.quit()
    
        
def main():
    game = MazeGame()
    game.run()

if __name__ == "__main__":
    main()
