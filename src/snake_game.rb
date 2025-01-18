# title:   Snake Game
# author:  Guilherme Alvarenga, Joao P., Maria Eduarda, Michael Todoroki, Pedro Freitas
# desc:    LP - Grupo Skane Game (Ruby)
# version: 0.2
# script:  ruby

# Variáveis
def init
  $score = 0
  $snake = [[10, 10]]   
  $direction = [1, 0]   
  $next_direction = [1, 0]
  $foods = Array.new(1 + rand(3)) { [rand(30), rand(17)] }  # Substituído rand(1..3) por 1 + rand(3)
  $game_over = false
  $frame_counter = 0
  $speed_factor = 10 
end


def update
  return if $game_over


  adjust_speed

  # Captura a próxima direção imediatamente
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
  if $frame_counter % $speed_factor == 0
    $direction = $next_direction
    move_snake
  end
end

def adjust_speed
  # Garante que $last_speed_update e $score são números
  $last_speed_update ||= 0
  $score ||= 0

  # Reduz o speed_factor quando o score ultrapassa múltiplos de 500, até um mínimo de 2
  if $score >= $last_speed_update + 500
    $speed_factor = [2, $speed_factor - 1].max
    $last_speed_update += 500
  end
end

def move_snake
  head = [$snake[0][0] + $direction[0], $snake[0][1] + $direction[1]]

  # Permitir que a cobrinha atravesse as bordas da tela
  head[0] = 29 if head[0] < 0
  head[0] = 0 if head[0] > 29
  head[1] = 16 if head[1] < 0
  head[1] = 0 if head[1] > 16

  if $foods.include?(head)
    $snake.unshift(head)
    $foods.delete(head)  # Remove a maçã comida
    $score += 30  # Incrementa o score em 30 pontos

    # Gera novas maçãs se todas tiverem sido comidas
    if $foods.empty?
      $foods = Array.new(1 + rand(3)) { [rand(30), rand(17)] } 
    end
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
 
  #Pinta o fundo com o sprite 69
  (0..29).each do |x|  
    (0..17).each do |y|   
      spr(69, x * 8, y * 8)   
    end
  end

  #Muda a direção da cabeça 
  head_sprite = case $direction
  when [1, 0]  # Direita
    65
  when [-1, 0] # Esquerda
    67
  when [0, -1] # Cima
    66
  when [0, 1]  # Baixo
    68
  else 
    65
  end
   
  #Pinta o rabo
  tail_sprite = 64
  if $snake.length > 1  
    tail_sprite = case [$snake[-2][0] - $snake[-1][0], $snake[-2][1] - $snake[-1][1]]
    when [1, 0]  # Direita
      71  
    when [-1, 0] # Esquerda
      73  
    when [0, -1] # Cima
      74   
    when [0, 1]  # Baixo
      72  
    else
      64
    end
  end
  
  #Pinta o corpo
  if $snake.length > 1
    $snake[1..-2].each do |segment|
      spr(64, segment[0] * 8, segment[1] * 8)   
    end
  end

  tail = $snake[-1]
  spr(tail_sprite, tail[0] * 8, tail[1] * 8)

  head = $snake[0]
  spr(head_sprite, head[0] * 8, head[1] * 8)

  if $snake.length == 1  
    spr(head_sprite, $snake[0][0] * 8, $snake[0][1] * 8)   
  end  

  # Desenha as comidas com sprites
  $foods.each do |food|
    spr(70, food[0] * 8, food[1] * 8)  
  end

  # Mensagem de Game Over
  if $game_over
    text = "GAME OVER"
    x = 95
    y = 68
    print(text, x, y, 12)
  end

# Exibe o score
print("SCORE: #{$score}", 10, 10, 12)
     

end
 
init

def TIC
  update
  draw
end
