require 'gosu' # Biblioteca gráfica
require 'bigdecimal' # Para cálculo de precisão das posições na tela

Std_Width_Info = 500 # Tamanho da região lateral que contém os dados do jogador
Std_Width_Game = 1080 # Tamanho da largura da área do jogo
Std_Width =	Std_Width_Game + Std_Width_Info # Tamanho total da largura da tela
Std_Height = 1920 # Tamanho total da altura da tela
Vida = 1500 # Qtdade de pontos de vida inicial do jogador
Std_Meteor_Speed = 10 # Qtdade de pixels que o meteoro se move por frame
Std_Helper_Speed = 2 # Qtdade de pixels que os helpers se movem por frame 
Std_Tiro_Speed = 40 # Qtdade de pixels que o tiro se move por frame
Std_Ship_Speed = 9 # Qtdade de pixels que o meteoro se move por frame
Ammo_Inicial = 1000 # Qtdade de pixels que a nave se move por frame
Dano_municao_ini = 30 # Qtdade de pontos de vida que o disparo do inimigo tira dos pontos de vida do Heroi
Meteoros = ["res/mt1.png", "res/mt2.png"] # Array com lista de paths das imagens dos meteoros 
Helpers = ["res/h1.png", "res/h2.png"] # Array com lista de paths das imagens dos helpers 
Tipos_Helpers = ["Ammo", "Cura"] # Tipos de helper, Ammo = aumenta munição, Cura = aumenta qtdade de pontos de vida
Inimigos = ["res/enemy1.png"] # Array com lista de paths das imagens dos Inimigos 
Helper_Qt_Vida = 350 # Qtdade de pontos de vida que o helper Cura adiciona ao Heroi
Helper_Qt_Ammo = 500 # Qtdade de munição que o helper Ammo adiciona ao Heroi



=begin
              Árvore de hierarquia de classes

              Entidade_________________
                |         |           |
                |         |           |
              Projetil   Ajuda     EntidadeViva_____
                |                     |             |
                |                     |             |
              IniTiro             Inimigo         Heroi
=end

=begin
   classe base para todos as entidades que serão printadas na tela
   contém dados básicos como posição X, Y, Z, função de detecção de colisão e detecção se está fora dos limites da tela
   px - Posição eixo X
   py - Posição eixo Y
   pz - Posição eixo Z
   img - Imagem (Gosu::Image) que representa a entidade na tela
=end
class Entidade
	def initialize px, py, pz, img
		@px = px
		@py = py
		@pz = pz
		@img = img
	end
	
	def px=(px)
		@px = px
	end	
	
	def py=(py)
		@py = py
	end
	
	def pz=(pz)
		@pz = pz
	end
	
	public
	def px
		@px
	end
	
	def py
		@py
	end	
	
	def pz
		@pz
	end	
	
	def img
		@img
	end
	
	# verifica se a entidade está fora dos limites da tela
	def esta_fora_tela
		@px > Std_Width_Game || @px < 0 || py > Std_Height || py < 0
	end
	
	# verifica se está a colidir com o meio de outra instância de Entidade
	def colide_com ent
		(self.px + self.img.width) > (ent.px + ent.img.width/2) && (ent.px + ent.img.width/2) > self.px && self.py + self.img.height > ent.py && ent.py > self.py
	end
end

=begin
	Projectil, incluem os tiros e os meteoros
	dano - Quantidade de pontos de vida que o Projetil retira do alvo ao acertá-lo
	tipo - Descrição do tipo do projetil
=end
class Projetil < Entidade
	def initialize px, py, pz, img, dano, tipo
		super px, py, pz, img
		@dano = dano
		@tipo = tipo
	end
	
	def tipo=(tipo)
		@tipo = tipo
	end
	
	def tipo
		@tipo
	end
	
	def dano
		@dano
	end
end

=begin
	Classe para descrever o tiro que o inimigo dispara
	hpx - Posição X que o heroi está na hora que o disparo é feito
	hpy - Posição Y que o heroi está na hora que o disparo é feito
	pxini - Posição X que o inimigo está na hora que o disparo é feito
	pyini - Posição Y que o inimigo está na hora que o disparo é feito
	
	hpx, hpy, pxini e pyini são usados para cálculo do coeficiênte ângular da reta que descreve o movimento do projetil
=end
class IniTiro < Projetil
	def initialize px, py, pz, img, dano, hpx, hpy, pxini, pyini
		super px, py, pz, img, dano, "IniTiro"
		@hpx = hpx
		@hpy = hpy
		@pxini = pxini
		@pyini = pyini
	end
	
	def pxini
		@pxini
	end
	
	def pyini
		@pyini
	end
	
	def hpx
		@hpx
	end
	
	def hpy
		@hpy
	end
	
end

=begin
	Classe de ajudas
	tipo - Tipo da ajuda, pode ser +pontos de vida ou +munição
=end
class Ajuda < Entidade
	def initialize px, py, pz, img, tipo
		super px, py, pz, img
		@tipo = tipo
	end
	
	def tipo
		@tipo
	end

end

=begin
	Entidade viva, uma entidade que tem pontos de vida
	vida - Pontos de vida
=end
class EntidadeViva < Entidade
	def initialize px, py, pz, img, vida
		super px, py, pz, img
		@vida = vida
	end
	
	def vida=(vida)
		@vida = vida
	end
	
	def vida
		@vida
	end
end

=begin
	Inimigos que disparam contra o heroi e tentam destrui-lo
	tempo_ultimo_tiro - Tempo em milisegundos em que o último disparo foi feito pela instância, usado para cálculo de frequência de tiros por tempo
	tiro_especial - Booleano que diz se o inimigo pode usar o tiro especial
=end
class Inimigo < EntidadeViva
	def initialize px, py, pz, img, vida, tempo_ultimo_tiro, tiro_especial
		super px, py, pz, img, vida
		@tempo_ultimo_tiro = tempo_ultimo_tiro
		@tiro_especial = tiro_especial
	end

	def tempo_ultimo_tiro=(tempo_ultimo_tiro)
		@tempo_ultimo_tiro = tempo_ultimo_tiro
	end
	
	def tempo_ultimo_tiro
		@tempo_ultimo_tiro
	end
	
	def tiro_especial=(tiro_especial)
		@tiro_especial = tiro_especial
	end
	
	def tiro_especial
		@tiro_especial
	end
	
end

=begin
	Heroi é a entidade que o jogador controla
	ammo - Quantidade de munições que o Heroi tem a disparar
	exp - Quantidade de pontos de experiência. Incrementado a cada alvo que o heroi destroi. É usado para subir o level do mesmo
	dano_municao - Quantidade de pontos de vida que o disparo do heroi tira do alvo ao atingi-lo (EntidadeViva)
	level - Level do heroi, usado de base para definir max_vida_level e dano_municao
	max_vida_level - Quantidade máxima de pontos de vida que o Heroi pode ter
	exp_level_atual - Quantidade de exp que o heroi precisa ter para o level
=end
class Heroi < EntidadeViva
	def initialize px, py, pz, img, vida, ammo, exp, dano_municao, level, max_vida_level, exp_level_atual
		super px, py, pz, img, vida
		@ammo = ammo
		@exp = exp
		@dano_municao = dano_municao
		@level = level
		@max_vida_level = max_vida_level
		@exp_level_atual = exp_level_atual
		
	end
		
	def ammo=(ammo)
		@ammo = ammo
	end
	
	def ammo
		@ammo
	end
	
	def exp=(exp)
		@exp = exp
	end
	
	def exp
		@exp
	end
	
	def dano_municao=(dano_municao)
		@dano_municao = dano_municao
	end
	
	def dano_municao
		@dano_municao
	end
	
	def level=(level)
		@level = level
	end
	
	def level
		@level
	end
	
	def max_vida_level
		@max_vida_level
	end
	
	# retorna um booleano dizendo se tem ou não munição disponível
	def tem_ammo
		return @ammo > 0
	end
	
	# função que recalcula os atributos do Heroi ao subir de level
	def upa_level
		@level += 1
		@dano_municao += @level * 2
		@exp_level_atual = exp_prox_level
		@max_vida_level += (0.05 * @max_vida_level).to_i
		@vida = @max_vida_level
	end
	
	# função que define a quantidade de exp exijida para o próximo level
	def exp_prox_level
		(2*@exp_level_atual + 0.1*@exp_level_atual).to_i
	end
	
end

=begin
	Classe que define a interface gráfica do jogo
	current_width - Largura total da tela ao instanciar o jogo
	current_height - Alturar total da tela ao instanciar o jogo
=end
class JanelaPrincipal < Gosu::Window
	protected
	def initialize width, height, argv
		define_tamanho_tela width, height
		
		super @current_width , @current_height
		self.caption = "Space shooter"
		
		prepara_fontes
		prepara_componentes_visuais
		seta_estado_inicial argv
		
	end
	
	def define_tamanho_tela width, height
		@current_height = height == 0 ? Std_Height : height
		@current_width = width == 0 ? Std_Width : width
	end
	
	def prepara_fontes 
		@fonte_stats = Gosu::Font.new(44)
		@fonte_game_over = Gosu::Font.new(150)
	end
	
	def seta_estado_inicial argv
		if argv.length > 0
			# Se o argv[0] não for algo do tipo: (qualquercoisa).txt ou se houver mais do que 1 parâmetro, Input inválido
			if /.*\.txt/.match(argv[0]) == nil || argv.length > 1
				puts "\nInput inválido\nEncerrando aplicação"
				fecha_programa
			else 
				@heroi = inicia_heroi_arq argv[0] 
			end
		else 
			@heroi = Heroi.new(@current_width/2-100, @current_height-150, 0, Gosu::Image.new("res/nave1.png"), Vida, Ammo_Inicial, 0, 10, 1, Vida, 100)
		end
		
		
		@ultimo_tempo = @ultimo_tempo_hlp = @ultimo_tempo_ini = @ultimo_tiro = Gosu::milliseconds
		
		@entidades = []
		@tiros = []
		@helpers = []
		@inimigos = []
		@tiros_inimigos = []
	end
	
	def inicia_heroi_arq argv
		dados_arquivo = /^.*@px=([0-9]+),\s+@py=([0-9]+).*@vida=([0-9]+).*@ammo=([0-9]+).*@exp=([0-9]+).*@dano_municao=([0-9]+).*@level=([0-9]+).*@max_vida_level=([0-9]+).*@exp_level_atual=([0-9]+).*\z/.match(IO.readlines(argv).to_s) 
 
		Heroi.new(@current_width/2-100, @current_height-150, 0, Gosu::Image.new("res/nave1.png"), dados_arquivo[3].to_i, dados_arquivo[4].to_i, dados_arquivo[5].to_i, dados_arquivo[6].to_i, dados_arquivo[7].to_i, dados_arquivo[8].to_i, dados_arquivo[9].to_i)
	end
	
	def prepara_componentes_visuais
		@bg_img = Gosu::Image.new("res/space1.jpg")
	
	end
	
	
  
  
	def move_entidades_array
		@entidades.each do |ent|
			ent.py+=Std_Meteor_Speed
		end
	
	end
	
	def move_tiros
		@tiros.each do |tiro|
			tiro.py-=Std_Tiro_Speed
		end
	end
	
	def move_helpers
		@helpers.each do |hlp|
			hlp.py+=Std_Helper_Speed
			if rand(1 ... 6) % 2 == 0
				if rand(1 ... 2) % 2 == 0
					hlp.px+=Std_Helper_Speed
				else
					hlp.px-=Std_Helper_Speed
				end
			end
		end
	end
	
	def move_inimigos
		@inimigos.each do |inimigo|
			if rand(1 ... 100) % 4 == 0
				if rand(1 ... 2) % 2 == 0
					if inimigo.py + Std_Helper_Speed < Std_Height
						inimigo.py+=Std_Helper_Speed
					end
				else
					if inimigo.py - Std_Helper_Speed > 0
						inimigo.py-=Std_Helper_Speed
					end
				end
			end
			if rand(1 ... 100) % 4 == 0
				if rand(1 ... 2) % 2 == 0
					if inimigo.px + Std_Helper_Speed < Std_Width_Game
						inimigo.px+=Std_Helper_Speed
					end
				else
					if inimigo.px - Std_Helper_Speed <= 1
						inimigo.px-=Std_Helper_Speed
					end
				end
			end
		end
	end
  
	def move_entidades
		move_entidades_array
		move_tiros
		move_helpers
		move_inimigos
	end
	
	def desenha_entidades
		(@entidades + @tiros + @helpers + @inimigos +@tiros_inimigos).each do |ent|
			ent.img.draw(ent.px.to_f, ent.py.to_f, 0)
		end	
	end
	  
	def desenha_background
		@bg_img.draw  0, 0, 0 
	end
	
	def desenha_heroi
		@heroi.img.draw(@heroi.px, @heroi.py, 0)
	end
	
	def desenha_strings
		@fonte_stats.draw("Munição: #{@heroi.ammo}", Std_Width_Game + 25, 100, 1, 1, 1, Gosu::Color::WHITE)
		@fonte_stats.draw("Level: #{@heroi.level}", Std_Width_Game + 25, 200, 1, 1, 1, Gosu::Color::WHITE) 
		@fonte_stats.draw("Exp: #{@heroi.exp}", Std_Width_Game + 25, 300, 1, 1, 1, Gosu::Color::WHITE)
		@fonte_stats.draw("Exp prox level: #{@heroi.exp_prox_level}", Std_Width_Game + 25, 400, 1, 1, 1, Gosu::Color::WHITE)
		@fonte_stats.draw("Vida: #{@heroi.vida}/#{@heroi.max_vida_level}", Std_Width_Game + 25, 500, 1, 1, 1, Gosu::Color::WHITE)
	end
	
		
	def desenha_msg_gaveover
		@fonte_game_over.draw("VOCÊ PERDEU!", (Std_Width/2) - 500 , Std_Height/2, 1, 1, 1,  Gosu::Color.argb(0xbb_990099) )
		@fonte_stats.draw("APERTE 'N' PARA RECOMEÇAR",  (Std_Width/2) - 290 , Std_Height/2 + 180, 1, 1, 1,  Gosu::Color.argb(0x88_ffffff) )
		@fonte_stats.draw("OU 'ESC' PARA SAIR", (Std_Width/2) - 220 , Std_Height/2 + 250, 1, 1, 1,  Gosu::Color.argb(0x88_ffffff) )
	end
	
	
	def add_exp ent
		case ent.class.to_s
			when "Projetil"
				if ent.tipo.include? "mt1"
					@heroi.exp += 5
				elsif ent.tipo.include? "mt2"
					@heroi.exp += 2
				end
			when "Inimigo"
				@heroi.exp += 10
			else
				puts "\nClasse não identificada\n"
		end	
	end
	
	def atira px, py
		add_tiro px, py
		@heroi.ammo -= 1
	end
	
	def ini_atira inix, iniy
		add_tiro_ini inix, iniy, 0
	end
	
	def ini_atira_especial inix, iniy, qt
		(0 .. qt).each do |counter|
			add_tiro_ini inix, iniy, counter.even? ? counter * 60 : -counter * 60
		end
	end
	
	def perdeu_jogo
		@heroi.vida <= 0
	end
	
	def add_tiro px, py
		@tiros << Entidade.new(  px + 30, py, 0, Gosu::Image.new("res/tiro2.png"))
	end
	
	def add_tiro_ini ix, iy, offset
		@tiros_inimigos << IniTiro.new(  BigDecimal.new(ix), BigDecimal.new(iy), 0, Gosu::Image.new("res/tiro3.png"), Dano_municao_ini, BigDecimal.new((@heroi.px + @heroi.img.width/2 + offset)), BigDecimal.new(@heroi.py), BigDecimal.new(ix), BigDecimal.new(iy))
		#@tiros_inimigos << IniTiro.new(  ix, iy, 0, Gosu::Image.new("res/tiro3.png"), Dano_municao_ini, (@heroi.px + @heroi.img.width/2 + offset), @heroi.py, ix, iy)
	end

	def move_tiros_ini		
		begin
			@tiros_inimigos.each do |tiro|
				if tiro.hpx > tiro.pxini
					tiro.px += Std_Tiro_Speed * Math.cos(Math.atan((tiro.hpy - tiro.pyini) / (tiro.hpx - tiro.pxini)))
					tiro.py += Std_Tiro_Speed * Math.sin(Math.atan((tiro.hpy - tiro.pyini) / (tiro.hpx - tiro.pxini)))
				elsif tiro.hpx < tiro.pxini
					tiro.px -= Std_Tiro_Speed * Math.cos(Math.atan((tiro.hpy - tiro.pyini) / (tiro.hpx - tiro.pxini)))
					tiro.py -= Std_Tiro_Speed * Math.sin(Math.atan((tiro.hpy - tiro.pyini) / (tiro.hpx - tiro.pxini)))
				else
					if tiro.hpy > tiro.pyini
						tiro.py += Std_Tiro_Speed
					else
						tiro.py -= Std_Tiro_Speed
					end
				end
			end
			rescue ZeroDivisionError => err
				puts err.message
				puts err.backtrace.inspect
		end
	end
  
	def trata_input
		if self.button_down? (Gosu::KB_ESCAPE)
			fecha_programa
		end
		if self.button_down? (Gosu::KB_LEFT)
			if @heroi.px - Std_Ship_Speed > -25
				@heroi.px -= Std_Ship_Speed
			end
		end
		if self.button_down? (Gosu::KB_RIGHT)
			if @heroi.px + @heroi.img.width - 25 + Std_Ship_Speed < Std_Width_Game
				@heroi.px += Std_Ship_Speed
			end
		end
		if self.button_down? (Gosu::KB_UP)
			if @heroi.py - Std_Ship_Speed + 15 > 0
				@heroi.py -= Std_Ship_Speed
			end
		end
		if self.button_down? (Gosu::KB_DOWN)
			if @heroi.py + @heroi.img.height < Std_Height
				@heroi.py += Std_Ship_Speed
			end
		end
		if self.button_down? (Gosu::KB_SPACE)
			if @heroi.tem_ammo
				atira @heroi.px, @heroi.py
			end
		end
		
		if (self.button_down? (Gosu::KB_LEFT_CONTROL )) && (self.button_down? (Gosu::KB_S))
			salva_estado_heroi
			print "control + S\n" 
		end
		
		if (self.button_down? (Gosu::KB_N)) && perdeu_jogo
			restarta_jogo
		end
	end
  
	def salva_estado_heroi
		begin
			arquivo_dados_heroi = File.new("Heroi.txt", "w")
			if arquivo_dados_heroi
				arquivo_dados_heroi.syswrite(@heroi.inspect)
			else
				puts "Erro ao abrir arquivo para salvar dados\n"
			end
			
			arquivo_dados_heroi.close
			
			rescue Exception => exx
				puts exx.message
				puts exx.backtrace.inspect
		end
		
		
	end
  
	def restarta_jogo
		seta_estado_inicial ARGV
	end
  
	def remove_entidades_fora_tela
		@entidades.each do |ent|
			if ent.esta_fora_tela
				@entidades.delete(ent)
			end
		end
		@tiros.each do |tiro|
			if tiro.esta_fora_tela
				@tiros.delete(tiro)
			end
		end
		@tiros_inimigos.each do |tiro|
			if tiro.esta_fora_tela
				@tiros_inimigos.delete(tiro)
			end
		end
		@helpers.each do |hlp|
			if hlp.esta_fora_tela
				@helpers.delete(hlp)
			end
		end
	end
	
	def detecta_colisoes_entidades
		# Verifica se algum tiro bateu em alguma entidade e se alguma entidade bateu no herói
		@entidades.each do |ent|
			if ent.colide_com @heroi
				@heroi.vida -= ent.dano
				@entidades.delete(ent)
			end
			@tiros.each do |tiro|
				if ent.colide_com tiro
					add_exp ent
					@entidades.delete(ent)
					@tiros.delete(tiro)
				end
			end
		end
		@helpers.each do |hlp|
			if hlp.colide_com @heroi
				helper_colide_heroi hlp.tipo
				@helpers.delete(hlp)
			end
		end
		
		@tiros_inimigos.each do |tiro|
			if tiro.colide_com @heroi
				@heroi.vida -= tiro.dano
				@tiros_inimigos.delete(tiro)
			end
			
			@tiros.each do |tirom|
				if tiro.colide_com tirom
					@tiros_inimigos.delete(tiro)
					@tiros.delete(tirom)
				end
			end
		end
		
		
		@inimigos.each do |inimigo|
			@tiros.each do |tiro|
				if inimigo.colide_com tiro
					inimigo.vida -= @heroi.dano_municao
					if inimigo.vida <= 0
						add_exp inimigo
						@inimigos.delete(inimigo)
					end
				end
			end
		end
		
	end
	
	def helper_colide_heroi tipo
		case tipo
			when "Ammo"
				@heroi.ammo += Helper_Qt_Ammo
			when "Cura"
				if @heroi.vida + Helper_Qt_Vida <= @heroi.max_vida_level
					@heroi.vida += Helper_Qt_Vida
				else
					@heroi.vida += (@heroi.max_vida_level - @heroi.vida)
				end
		end
	end
	
	def precisa_atualizar_tela
		needs_redraw?
	end
	
	def desenha_componentes_visuais
		desenha_background
		desenha_entidades
		desenha_strings
		desenha_heroi
	end

	
	# spwana uma nova entidade a cada X segundos, onde X entre 20 milisegundos e 2,5 segundos
	def add_nova_entidade
		if (Gosu::milliseconds - @ultimo_tempo ) / rand(20 ... 2500) == 1 
			tipo_proj = rand(0 ... Meteoros.length )
			img_size = Gosu::Image.new(Meteoros[rand(0 ... Meteoros.length )]).width
			@entidades << Projetil.new(  rand(4 ... (Std_Width_Game-(2*img_size))) , 1, 0, Gosu::Image.new(Meteoros[tipo_proj]), rand(50 ... 300), Meteoros[tipo_proj])
			@ultimo_tempo = Gosu::milliseconds
		end
	end
	
	def add_helpers
		if (Gosu::milliseconds - @ultimo_tempo_hlp ) / rand(10000 ... 20000) == 1 
			tipo_helper = rand(0 ... Helpers.length )
			img_size = Gosu::Image.new(Helpers[tipo_helper]).width
			@helpers << Ajuda.new(  rand(4 ... (Std_Width_Game-img_size)) , 1, 0, Gosu::Image.new(Helpers[tipo_helper]), Tipos_Helpers[tipo_helper])
			@ultimo_tempo_hlp = Gosu::milliseconds
		end
	end
	
	def add_inimigos
		if (Gosu::milliseconds - @ultimo_tempo_ini ) / rand(2000 ... 40000) == 1 #&& @inimigos.length < 1
			tipo_ini = rand(0 ... Inimigos.length )
			img_size = Gosu::Image.new(Inimigos[tipo_ini]).width
			@inimigos << Inimigo.new( rand(4 ... (Std_Width_Game-img_size))  , 50, 0, Gosu::Image.new(Inimigos[tipo_ini]), 1000, Gosu::milliseconds, rand(0 ... 99) % 3 == 0 ? true : false)
			@ultimo_tempo_ini = Gosu::milliseconds
		end
	end
  
	def inimigos_atiram
		@inimigos.each do |inimigo|
			if (Gosu::milliseconds - inimigo.tempo_ultimo_tiro ) / rand(10 ... 500) == 1 
				if inimigo.tiro_especial 
					ini_atira_especial inimigo.px + inimigo.img.width/2, inimigo.py + inimigo.img.height, 2
				else
					ini_atira inimigo.px + inimigo.img.width/2, inimigo.py + inimigo.img.height
				end
				inimigo.tempo_ultimo_tiro = Gosu::milliseconds
			end
		end	
	end
  
	def verifica_level
		if @heroi.exp >= @heroi.exp_prox_level
			@heroi.upa_level
		end
	end
  
	def fecha_programa
		self.close
	end
	
	def update
		srand Gosu::milliseconds
		trata_input
		if not perdeu_jogo
			add_nova_entidade
			add_helpers
			add_inimigos
			inimigos_atiram
			move_tiros_ini
			remove_entidades_fora_tela
			move_entidades
			detecta_colisoes_entidades
			verifica_level
		end
		sleep(0.008)
	end
  
	def draw
		if not perdeu_jogo
			if precisa_atualizar_tela
				desenha_componentes_visuais
			end
		else
			desenha_msg_gaveover
		end
	end

end



JanelaPrincipal.new(Std_Width, Std_Height, ARGV).show
