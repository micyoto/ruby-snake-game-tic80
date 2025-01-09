# title:   Snake Game
# author:  Guilherme Alvarenga, Joao P., Maria Eduarda, Michael Todoroki, Pedro Freitas
# desc:    LP - Grupo Skane Game (Ruby)
# version: 0.1
# script:  ruby

# Variaveis
def init
  $score = 0
  $snake = [[10, 10]]
  $direction = [1, 0]
  $next_direction = [1, 0]
  $food = [rand(30), rand(17)]
  $game_over = false
  $frame_counter = 0
end

def update
  return if $game_over

  # Captura a proxima direcao imediatamente
  if btn(0)
    $next_direction = [0, -1] if $direction != [0, 1]
  elsif btn(1) 
    $next_direction = [0, 1] if $direction != [0, -1]
  elsif btn(2) 
    $next_direction = [-1, 0] if $direction != [1, 0]
  elsif btn(3)
    $next_direction = [1, 0] if $direction != [-1, 0]
  end

  # Incrementa o contador de frames
  $frame_counter += 1

  # Mover a cobra a cada 10 frames
  if $frame_counter % 10 == 0
    $direction = $next_direction
    move_snake
  end
end

def move_snake
  head = [$snake[0][0] + $direction[0], $snake[0][1] + $direction[1]]

  # Permitir que a cobrinha atravesse as bordas da tela
  head[0] = 29 if head[0] < 0
  head[0] = 0 if head[0] > 29
  head[1] = 16 if head[1] < 0
  head[1] = 0 if head[1] > 16

  if head == $food
    $snake.unshift(head)
    $food = [rand(30), rand(17)]
    $score += 30  # Incrementa o score em 30 pontos
  else
    $snake.pop
    $snake.unshift(head)
  end

  check_collision
end

def check_collision
  head = $snake[0]
  if $snake[1..-1].include?(head)
    $game_over = true
  end
end

def draw
  cls(0)

  # Exibe o score
  print("SCORE: #{$score}", 10, 10, 12)

  # Desenha a cobra
  $snake.each do |segment|
    rect(segment[0] * 8, segment[1] * 8, 8, 8, 11)
  end

  # Desenha a comida
  rect($food[0] * 8, $food[1] * 8, 8, 8, 6)

  # Mensagem de Game Over
  if $game_over
    text = "GAME OVER"
    x = 95
    y = 68
    print(text, x, y, 12)
  end
end

init
def TIC
  update
  draw
end
