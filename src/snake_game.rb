# title:   Snake Game
# author:  Guilherme Alvarenga, Joao P., Maria Eduarda, Michael Todoroki, Pedro Freitas
# desc:    LP - Grupo Skane Game (Ruby)
# version: 0.2
# script:  ruby

# Variáveis globais para o menu
$menu = true # Define se o jogo está no menu ou não
$food_count = 1 # Número inicial de comidas
$option_index = 0 # Índice da opção selecionada
$menu_cooldown = 0  # Controla a sensibilidade da navegação

# Constantes globais para dimensões da malha
GRID_WIDTH = 28
GRID_HEIGHT = 15  # Reduzido de 17 para 15
CELL_SIZE = 8

# Função para inicializar o jogo
def init
  $score = 0
  $snake = [[10, 10]]
  $direction = [1, 0]
  $next_direction = [1, 0]
  $foods = []
  $food_count.times do
    new_food = nil
    loop do
      new_food = [rand(GRID_WIDTH), rand(GRID_HEIGHT)]
      break unless $snake.include?(new_food) || $foods.include?(new_food)
    end
    $foods << new_food
  end
  $game_over = false
  $game_win = false
  $frame_counter = 0 
  $speed_factor = 10 
  $last_speed_update = 0
end

# No início, defina o botão com valores iniciais adequados
$botao_confirmar = { x: 160, y: 130, w: 65, h: 200, texto: "APERTE ENTER" }

def menu_update
  # Reduz o cooldown a cada frame
  $menu_cooldown = [$menu_cooldown - 1, 0].max

  # Navegação com botões UP (0) e DOWN (1)
  if $menu_cooldown <= 0
    if btn(0)  # Botão UP
      $option_index = ($option_index - 1) % 4
      $menu_cooldown = 10  # Define o cooldown para 10 frames
    elsif btn(1)  # Botão DOWN
      $option_index = ($option_index + 1) % 4
      $menu_cooldown = 10
    end
  end

  # Verifica se a tecla Enter foi pressionada
  if keyp(50)  # Corrigido para usar o código de tecla correto para Enter no TIC-80, se disponível
    case $option_index
    when 0 then $food_count = 1
    when 1 then $food_count = 3
    when 2 then $food_count = 5
    when 3 then $food_count = [1, 2, 3, 4, 5, 6].sample
    end
    $menu = false
    init   # Inicializa o jogo com a configuração escolhida
  end
end

def menu_draw
  cls(0)  # Tenta usar a cor 2 para fundo verde. Ajuste conforme necessário.

  screen_width = 240
  screen_height = 120

  # Título do jogo
  title = "SNAKE GAME"
  print(title, ((screen_width - title.length * 5)  -  10)/ 2, 15, 11) # PRINT(texto, x, y, cor)

  # Definição das opções
  options = [1, 3, 5, "Aleatório"]
  start_y = 40
  option_gap = 20
  sprite_spacing = 12  # Aumenta o espaçamento para melhor visualização

  options.each_with_index do |opt, index|
    y = start_y + index * option_gap

    # Destacar a opção selecionada com setas
    if index == $option_index
      print(">", 30, y, 15)  # Seta para a esquerda
      print("<", screen_width - 40, y, 15)  # Seta para a direita
    end

    # Desenha sprites conforme a opção
    if opt.is_a?(Integer)
      count = opt
      total_width = count * sprite_spacing
      start_x = (screen_width - total_width) / 2
      count.times do |i|
        spr(70, start_x + i * sprite_spacing, y, 6)  # Sprite de comida
      end
    else
      # Opção "Aleatório": sprite de comida + ponto de interrogação
      base_x = (screen_width - sprite_spacing) / 2 
      spr(70, base_x, y, 6)  # Sprite de comida
      print("?", base_x + 2, y + 2, 15)  # Ponto de interrogação
    end
  end

  # Configurar e desenhar o botão de confirmação
  button_width = 85 # Largura do botão
  button_height = 200 # Altura do botão
  button_x = (screen_width - button_width) / 2 # Posição X do botão
  button_y = start_y + options.size * option_gap + 5 # Posição Y do botão

  # Atualiza as coordenadas do botão
  $botao_confirmar[:x] = button_x
  $botao_confirmar[:y] = button_y
  $botao_confirmar[:w] = button_width
  $botao_confirmar[:h] = button_height

  # Desenhar o botão de confirmação
  desenha_botao($botao_confirmar)
end

def desenha_botao(botao)
  # Desenha o retângulo do botão com uma cor de destaque
  rect(botao[:x], botao[:y], botao[:w], botao[:h], 12)  # Cor 12 pode ser azul ou outra de destaque
  # Desenha o texto do botão centralizado
  print(botao[:texto], botao[:x] + ((botao[:w] / 2) - 8) - (botao[:texto].length * 2), botao[:y] + 3, 15) # Texto na cor 15 (branco)
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
  
  # Verifica se a cabeça da cobra ultrapassou as bordas da malha
  if head[0] < 0 || head[0] >= GRID_WIDTH || head[1] < 0 || head[1] >= GRID_HEIGHT
    $game_over = true
    return  # Para a execução da função se a cobra atingir as bordas
  end

  if $foods.include?(head)
    $snake.unshift(head)
    $foods.delete(head)  # Remove a maçã comida
    $score += 1      # Incrementa o score em 1 ponto

    # Gera um novo alimento para substituir o que foi comido
    new_food = nil
    loop do
      new_food = [rand(GRID_WIDTH), rand(GRID_HEIGHT)]
      break unless $snake.include?(new_food) || $foods.include?(new_food)
    end
    $foods << new_food
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
  if $snake.length == GRID_WIDTH * GRID_HEIGHT
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

  offset_x = 8
  offset_y = 8

  # Desenha o fundo da malha, agora centralizado
  (0...GRID_WIDTH).each do |x|
    (0...GRID_HEIGHT).each do |y|
      spr((x + y) % 2 == 0 ? 69 : 75, offset_x + x * CELL_SIZE, offset_y + y * CELL_SIZE, -1)
    end
  end

  if $snake.length == 1
    $snake.unshift([$snake[0][0] + $direction[0], $snake[0][1] + $direction[1]])
  end
 
  # Determina o sprite para a cabeça baseado na direção atual
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
   
  # Desenha a cabeça da cobra com o offset aplicado
  spr(head_sprite, offset_x + $snake[0][0] * CELL_SIZE, offset_y + $snake[0][1] * CELL_SIZE, 6)
  
  # Determina o sprite para a cauda baseado na direção entre os dois últimos segmentos
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

    # Desenha a cauda da cobra com o offset aplicado
    spr(tail_sprite, offset_x + $snake[-1][0] * CELL_SIZE, offset_y + $snake[-1][1] * CELL_SIZE, 6)
  end
    # Pinta o corpo da cobra
    if $snake.length > 1
      $snake[1..-2].each do |segment|
        directions = direction_change(segment)
        prev_direction, next_direction = directions
        body = 64  # Valor padrão para o corpo
  
        if prev_direction == [1, 0] && next_direction == [0, 1] || prev_direction == [0, 1] && next_direction == [1, 0]
          body = prev_direction == [1, 0] ? 79 : 77
        elsif prev_direction == [1, 0] && next_direction == [0, -1] || prev_direction == [0, -1] && next_direction == [1, 0]
          body = prev_direction == [1, 0] ? 63 : 78
        elsif prev_direction == [-1, 0] && next_direction == [0, 1] || prev_direction == [0, 1] && next_direction == [-1, 0]
          body = prev_direction == [-1, 0] ? 78 : 63
        elsif prev_direction == [-1, 0] && next_direction == [0, -1] || prev_direction == [0, -1] && next_direction == [-1, 0]
          body = prev_direction == [-1, 0] ? 77 : 79
        else
          body = case [$snake[$snake.index(segment) - 1][0] - segment[0], $snake[$snake.index(segment) - 1][1] - segment[1]]
          when [1, 0], [-1, 0]  # Horizontal
            64
          when [0, -1], [0, 1]  # Vertical
            76
          else
            64
          end
        end
  
        # Desenha o corpo da cobra com o offset aplicado
        spr(body, offset_x + segment[0] * CELL_SIZE, offset_y + segment[1] * CELL_SIZE, 6)
      end
    end
  
    # Desenha a cauda e a cabeça da cobra com os offsets aplicados
    tail = $snake[-1]
    spr(tail_sprite, offset_x + tail[0] * CELL_SIZE, offset_y + tail[1] * CELL_SIZE, 6)
  
    head = $snake[0]
    spr(head_sprite, offset_x + head[0] * CELL_SIZE, offset_y + head[1] * CELL_SIZE, 6)
  
    # Desenha as comidas com os offsets aplicados
    $foods.each do |food|
      spr(70, offset_x + food[0] * CELL_SIZE, offset_y + food[1] * CELL_SIZE, -1)
    end
  
    # Pinta o corpo da cobra
  if $snake.length > 1
    $snake[1..-2].each do |segment|
      directions = direction_change(segment)
      prev_direction, next_direction = directions
      body = 64  # Valor padrão para o corpo

      if prev_direction == [1, 0] && next_direction == [0, 1] || prev_direction == [0, 1] && next_direction == [1, 0]
        body = prev_direction == [1, 0] ? 79 : 77
      elsif prev_direction == [1, 0] && next_direction == [0, -1] || prev_direction == [0, -1] && next_direction == [1, 0]
        body = prev_direction == [1, 0] ? 63 : 78
      elsif prev_direction == [-1, 0] && next_direction == [0, 1] || prev_direction == [0, 1] && next_direction == [-1, 0]
        body = prev_direction == [-1, 0] ? 78 : 63
      elsif prev_direction == [-1, 0] && next_direction == [0, -1] || prev_direction == [0, -1] && next_direction == [-1, 0]
        body = prev_direction == [-1, 0] ? 77 : 79
      else
        body = case [$snake[$snake.index(segment) - 1][0] - segment[0], $snake[$snake.index(segment) - 1][1] - segment[1]]
        when [1, 0], [-1, 0]  # Horizontal
          64
        when [0, -1], [0, 1]  # Vertical
          76
        else
          64
        end
      end

      # Desenha o corpo da cobra com o offset aplicado
      spr(body, offset_x + segment[0] * CELL_SIZE, offset_y + segment[1] * CELL_SIZE, 6)
    end
  end

  # Desenha a cauda e a cabeça da cobra com os offsets aplicados
  tail = $snake[-1]
  spr(tail_sprite, offset_x + tail[0] * CELL_SIZE, offset_y + tail[1] * CELL_SIZE, 6)

  head = $snake[0]
  spr(head_sprite, offset_x + head[0] * CELL_SIZE, offset_y + head[1] * CELL_SIZE, 6)

  # Desenha as comidas com os offsets aplicados
  $foods.each do |food|
    spr(70, offset_x + food[0] * CELL_SIZE, offset_y + food[1] * CELL_SIZE, -1)
  end
    # Mensagem de Game Over
    if $game_over
      # Centraliza a mensagem "GAME OVER" horizontalmente e ajusta verticalmente
      text = "GAME OVER"
      x_centered = (240 - text.length * 6) / 2  # Cada caractere geralmente ocupa 6 pixels de largura
      y_centered = (136 - 8) / 2  # 8 pixels é a altura aproximada de uma linha de texto
      print(text, x_centered, y_centered, 12)
    end
  
    # Mensagem de Vitória
    if $game_win
      # Centraliza a mensagem "PARABÉNS PELA VITÓRIA!" horizontalmente e ajusta verticalmente
      text = "PARABÉNS PELA VITÓRIA!"
      x_centered = (240 - text.length * 6) / 2  # Cada caractere geralmente ocupa 6 pixels de largura
      y_centered = (136 - 8) / 2  # 8 pixels é a altura aproximada de uma linha de texto
      print(text, x_centered, y_centered, 12)
    end
  
  # Exibe o score
  print("SCORE: #{$score}", 8, 1, 11)  
end
 
def TIC
  if $menu
    menu_update
    menu_draw
  else
    update
    draw
  end
end