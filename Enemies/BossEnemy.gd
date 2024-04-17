extends CharacterBody2D

const EnemyDeathEffect = preload("res://Effects/enemy_death_effect.tscn")

@onready var player = get_parent().find_child("Player")
@onready var sprite = $Sprite2D
@onready var progress_bar = $UI/BossHPBar
@onready var healthbar = $HealthBar
@onready var animationPlayer = $AnimationPlayer
@onready var hurtbox = $Hurtbox
@export var KNOCKOUT_RANGE = 100
@export var bossHP = 500
@onready var meleeAttackDir = $FiniteStateMachine/MeleeAttack/MeleeAOE
@onready var damage_numbers_origin = $DamageNumbersOrigin

var direction : Vector2
var DEF = 0
 
var health = bossHP:
	set(value):
		health = value
		progress_bar.max_value = bossHP
		progress_bar.value = value
		
		var LOW_HEALTH = progress_bar.max_value * 0.3
		var HALF_HEALTH = progress_bar.max_value * 0.5
	
		healthbar.max_value = progress_bar.max_value
		healthbar.value = progress_bar.value
	
		if health >= progress_bar.max_value:
			healthbar.visible = false
		else:
			healthbar.visible = true
		
		if health <= HALF_HEALTH and health > LOW_HEALTH:
			#Much hp has been lost turn yellow
			healthbar.modulate = Color(1,1,0)
		elif health <= LOW_HEALTH:
			#Health is critical, turn red
			healthbar.modulate = Color(1, 0, 0)
			
		if value <= 0:
			progress_bar.visible = false
			find_child("FiniteStateMachine").change_state("Death")
			#Puts the death effect where the enemy died.
			var enemyDeathEffect = EnemyDeathEffect.instantiate()
			get_parent().add_child(enemyDeathEffect)
			enemyDeathEffect.global_position = global_position
		elif value <= progress_bar.max_value / 2 and DEF == 0: # Phase two of the fight he gets tankier
			DEF = 5
			find_child("FiniteStateMachine").change_state("ArmorBuff") 
 
func _ready():
	set_physics_process(false)
 
func _process(_delta):
	if player != null:
		direction = player.position - position
 
	if direction.x < 0:
		sprite.flip_h = true
		meleeAttackDir.position.x = -31
	else:
		sprite.flip_h = false
		meleeAttackDir.position.x = 17
 
func _physics_process(delta):
	velocity = direction.normalized() * 45
	move_and_collide(velocity * delta)
 
func take_damage(area):
	var is_critical = false
	var damage_taken

	if area.damage - DEF > 0:
		damage_taken = (area.damage - DEF)
	else:
		damage_taken = area.damage

	var critical_chance = randf()

	if critical_chance <= 0.5:
		is_critical = true
		var critical_multiplier = randf_range(1.2, 2)
		damage_taken *= critical_multiplier

	health -= damage_taken
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)
	DamageNumbers.display_number(damage_taken, damage_numbers_origin.global_position, is_critical)


func _on_hurtbox_area_entered(area):
	if health > 0:
		take_damage(area)
		
	if area.has_method("projectile"):
		queue_free()
	
func _on_hurtbox_invincibility_started():
	animationPlayer.play("Start")

func _on_hurtbox_invincibility_ended():
	animationPlayer.play("Stop")
	
