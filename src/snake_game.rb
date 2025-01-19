# title:   Snake Game
# author:  Guilherme Alvarenga, Joao P., Maria Eduarda, Michael Todoroki, Pedro Freitas
# desc:    LP - Grupo Skane Game (Ruby)
# version: 0.2
# script:  ruby

# Variáveis globais
def init
  $score = 0
  $snake = [[10, 10]]   
  $direction = [1, 0]   
  $next_direction = [1, 0]
  $foods = Array.new(1 + rand(3)) { [rand(30), rand(17)] }  # Substituído rand(1..3) por 1 + rand(3)
  $game_over = false
  $game_win = false
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
    $score += 50  # Incrementa o score em 50 pontos

    # Gera novas maçãs se todas tiverem sido comidas
    if $foods.empty?
      # as maçãs só aparecem em posições válidas, fora do corpo da cobra
      $foods = Array.new(1 + rand(3)) { [rand(30), rand(17)] }  # Substituído rand(1..3) por 1 + rand(3)
      $foods.reject! { |food| $snake.include?(food) }
    end
  else
    $snake.pop
    $snake.unshift(head)
  end

  check_collision
  check_win
end

def check_collision
  head = $snake[0]
  if $snake[1..-1].include?(head)
    $game_over = true
  end
end

def check_win
  if $snake.length == 30 * 17
    $game_win = true
  end
end

def direction_change(segment)
  index = $snake.index(segment)
  return nil if index == 0 || index == $snake.length - 1

  prev_segment = $snake[index - 1]
  next_segment = $snake[index + 1]

  prev_direction = [segment[0] - prev_segment[0], segment[1] - prev_segment[1]]
  next_direction = [next_segment[0] - segment[0], next_segment[1] - segment[1]]

  [prev_direction, next_direction]
end

def draw
  cls(0)
  if $snake.length == 1
    $snake.unshift([$snake[0][0] + $direction[0], $snake[0][1] + $direction[1]])
  end
 
  #Pinta o fundo com o sprite 69 alternadamente com o sprite 75
  (0..29).each do |x|
    (0..16).each do |y|
      spr((x + y) % 2 == 0 ? 69 : 75, x * 8, y * 8)
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
  
  #Pinta o corpo
  if $snake.length > 1
    $snake[1..-2].each do |segment|
      # Pinta o corpo da cobra com o sprite 64, se a direção do sprite for horizontal, ou 76, se for vertical
      # se for no canto para a 0, pinta com o sprite 77
      directions = direction_change(segment)

      prev_direction, next_direction = directions
      body = 64

      if prev_direction == [1, 0] && next_direction == [0, 1] || prev_direction == [0, 1] && next_direction == [1, 0]
        if prev_direction == [1, 0]
          body = 79
        else
          body = 77
        end
      elsif prev_direction == [1, 0] && next_direction == [0, -1] || prev_direction == [0, -1] && next_direction == [1, 0]
        if prev_direction == [1, 0]
          body = 63
        else
          body = 78
        end
      elsif prev_direction == [-1, 0] && next_direction == [0, 1] || prev_direction == [0, 1] && next_direction == [-1, 0]
        if prev_direction == [-1, 0]
          body = 78
        else
          body = 63
        end
      elsif prev_direction == [-1, 0] && next_direction == [0, -1] || prev_direction == [0, -1] && next_direction == [-1, 0]
        if prev_direction == [-1, 0]
          body = 77
        else
          body = 79
        end
      else
        body = case [$snake[$snake.index(segment) - 1][0] - segment[0], $snake[$snake.index(segment) - 1][1] - segment[1]]
        when [1, 0]  # Direita
          64  
        when [-1, 0] # Esquerda
          64  
        when [0, -1] # Cima
          76   
        when [0, 1]  # Baixo
          76  
        else
          64
        end
      end
      
      spr(body, segment[0] * 8, segment[1] * 8, 6)
    end
  end

  tail = $snake[-1]
  spr(tail_sprite, tail[0] * 8, tail[1] * 8, 6)

  head = $snake[0]
  spr(head_sprite, head[0] * 8, head[1] * 8, 6)

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

  # Mensagem de Vitória
  if $game_win
    text = "PARABÉNS PELA VITÓRIA!"
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
