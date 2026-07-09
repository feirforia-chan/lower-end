class_name Manager
extends Node2D

# Here go the variables
var month = 1
var year = 1

var adults = 730
var children = 200
var elderly = 70
var soldiers = 0

var money = 10000
var population = adults + children + elderly + soldiers
var food = 2000
var materials = 100
var happiness = 75
var stability = 75
var subversion = 0

var farms = 3
var workshop = 4
var barracks = 1
var center = 0
var hospital = 0
var smithies = 0
var labs = 0

var farmupkeep = farms * 25
var workshopupkeep = workshop * 50
var barracksupkeep = barracks * 50
var hallupkeep = center * 65
var hospitalupkeep = hospital * 40
var smithyupkeep = smithies * 30
var labsupkeep = labs * 60
var soldierupkeep = soldiers * 7
var totalupkeep = farmupkeep + workshopupkeep + barracksupkeep + hallupkeep + hospitalupkeep + smithyupkeep + labsupkeep + soldierupkeep

var soldierlimit = barracks * 10

# Total building count for calculating upkeep
var buildingsCount = farms + barracks + center + hospital + smithies + labs

# Stat multipliers from Policy.
var Fmult = Policy.current_modifiers.get("foodMult", 1.0)
var Mmult = Policy.current_modifiers.get("matMult", 1.0)
var Hmult = Policy.current_modifiers.get("happyMult", 1.0)
var StaMult = Policy.current_modifiers.get("staMult", 1.0)
var SubMult = Policy.current_modifiers.get("subvMult", 1.0)
var TaxMult = Policy.current_modifiers.get("taxMult", 1.0)

# This is the start of the queue system.
var building_queue: Array = []

# Here go the element definitions
@onready var monthlabel = $Camera2D/CanvasLayer/ControlsOutliner/HBoxContainer/HBoxContainer/MonthLabel
@onready var yearlabel = $Camera2D/CanvasLayer/ControlsOutliner/HBoxContainer/HBoxContainer/YearLabel
@onready var foodlabel = $Camera2D/CanvasLayer/StatsContainer/VBoxContainer/FoodLabel
@onready var poplabel = $Camera2D/CanvasLayer/StatsContainer/VBoxContainer/PopulationLabel
@onready var starvelabel = $Camera2D/CanvasLayer/StatsContainer/VBoxContainer/StarvationLabel
@onready var happylabel = $Camera2D/CanvasLayer/StatsContainer/VBoxContainer/HappinessLabel
@onready var farmslabel = $Camera2D/CanvasLayer/BuildingsPanel/GeneralOrdainer/NumBuildingsColumn/FarmsLabel
@onready var workshoplabel = $Camera2D/CanvasLayer/BuildingsPanel/GeneralOrdainer/NumBuildingsColumn/WorkshopLabel
@onready var matlabel = $Camera2D/CanvasLayer/StatsContainer/VBoxContainer/MaterialsLabel
@onready var stalabel = $Camera2D/CanvasLayer/StatsContainer/VBoxContainer/StabilityLabel
@onready var subversionlabel = $Camera2D/CanvasLayer/StatsContainer/VBoxContainer/SubversionLabel
@onready var BuildingsPanel = $Camera2D/CanvasLayer/BuildingsPanel
@onready var moneylabel = $Camera2D/CanvasLayer/StatsContainer/VBoxContainer/MoneyLabel
@onready var barracks_label = $Camera2D/CanvasLayer/BuildingsPanel/GeneralOrdainer/NumBuildingsColumn/BarracksLabel
@onready var halls_label = $Camera2D/CanvasLayer/BuildingsPanel/GeneralOrdainer/NumBuildingsColumn/HallsLabel
@onready var hospitals_label = $Camera2D/CanvasLayer/BuildingsPanel/GeneralOrdainer/NumBuildingsColumn/HospitalsLabel
@onready var smithies_label = $Camera2D/CanvasLayer/BuildingsPanel/GeneralOrdainer/NumBuildingsColumn/SmithiesLabel
@onready var labs_label = $Camera2D/CanvasLayer/BuildingsPanel/GeneralOrdainer/NumBuildingsColumn/LabsLabel
@onready var adult_label = $Camera2D/PanelContainer/VBoxContainer/AdultLabel
@onready var soldier_label = $Camera2D/PanelContainer/VBoxContainer/SoldierLabel
@onready var children_label = $Camera2D/PanelContainer/VBoxContainer/ChildrenLabel
@onready var elderly_label = $Camera2D/PanelContainer/VBoxContainer/ElderlyLabel

# Here be dragons.

func updateLabels():
	population = adults + children + elderly + soldiers
	monthlabel.text = "Month " + str(month)
	yearlabel.text = "Year " + str(year)
	foodlabel.text = "Food " + str(food)
	poplabel.text = "Population " + str(population)
	happylabel.text = "Happiness " + str(happiness)
	matlabel.text = "Materials " + str(materials)
	farmslabel.text = "N° Farms " + str(farms)
	stalabel.text = "Stability % " + str(stability)
	subversionlabel.text = "Subversion % " + str(subversion)
	workshoplabel.text = "N° Workshops " + str(workshop)
	moneylabel.text = "Money " + str(money)
	barracks_label.text = "N° Barracks " + str(barracks)
	halls_label.text = "N° Halls " + str(center)
	hospitals_label.text = "N° Hospitals " + str(hospital)
	smithies_label.text = "N° Smithies " + str(smithies)
	labs_label.text = "N° Labs " + str(labs)
	adult_label.text = "Adults: " + str(adults)
	soldier_label.text = "Soldiers: " + str(soldiers)
	children_label.text = "Children: " + str(children)
	elderly_label.text = "Elderly: " + str(elderly)

static var game_timer: Timer

func update_queue_labels() -> void:
	# Loop through all 10 slots
	for i in range(1, 11):
		# Dynamically get the node path for List1, List2, etc.
		var label_path = "Camera2D/CanvasLayer/BuildingsPanel/GeneralOrdainer/NumBuildingsColumn/VBoxContainer/List" + str(i)
		var list_label = get_node_or_null(label_path)
		
		# Safety check just in case a label is missing or named wrong in the scene tree
		if list_label == null:
			continue
			
		# The queue array is 0-indexed, so slot 1 looks at index 0
		var queue_index = i - 1
		
		if queue_index < building_queue.size():
			var project = building_queue[queue_index]
			var building_name = project["type"].capitalize() # Turns "farm" into "Farm"
			var months = project["months_left"]
			
			list_label.text = str(i) + ". " + building_name + " (" + str(months) + "m left)"
		else:
			list_label.text = str(i) + ". Vacant"

# Create a timer for the game logic
func _ready() -> void:
	
	Policy.set("queue_container", $Camera2D/CanvasLayer/PoliciesPanel/GeneralOrdainer/PoliciesColumn/VBoxContainer)
	
	Policy.set("autocracy_label", $Camera2D/CanvasLayer/PoliciesPanel/GeneralOrdainer/PoliciesColumn/AutocracyLabel)
	Policy.set("rationing_label", $Camera2D/CanvasLayer/PoliciesPanel/GeneralOrdainer/PoliciesColumn/RationingLabel)
	Policy.set("work_rights_label", $Camera2D/CanvasLayer/PoliciesPanel/GeneralOrdainer/PoliciesColumn/WorkRightsLabel)
	
	Policy.set("rights_label", $Camera2D/CanvasLayer/PoliciesPanel/GeneralOrdainer/PoliciesColumn/RightsLabel)
	Policy.set("government_label", $Camera2D/CanvasLayer/PoliciesPanel/GeneralOrdainer/PoliciesColumn/GovernmentLabel)
	Policy.set("statfoodlabel", $Camera2D/CanvasLayer/PoliciesPanel/GeneralOrdainer/PoliciesColumn/StatFoodMult)
	Policy.set("statmatlabel", $Camera2D/CanvasLayer/PoliciesPanel/GeneralOrdainer/PoliciesColumn/StatMatMult)
	Policy.set("stathappylabel", $Camera2D/CanvasLayer/PoliciesPanel/GeneralOrdainer/PoliciesColumn/StatHappyMult)
	Policy.set("statstabilitylabel", $Camera2D/CanvasLayer/PoliciesPanel/GeneralOrdainer/PoliciesColumn/StatStaMult)
	Policy.set("statsubvlabel", $Camera2D/CanvasLayer/PoliciesPanel/GeneralOrdainer/PoliciesColumn/StatSubvMult)
	Policy.set("stattaxlabel", $Camera2D/CanvasLayer/PoliciesPanel/GeneralOrdainer/PoliciesColumn/StatTaxMult)
	
	Policy.update_policy_ui()
	
	game_timer = Timer.new()
	add_child(game_timer)
	game_timer.wait_time = 1
	game_timer.one_shot = false # Keep looping!
	
	# Connect the timer's timeout to the game logic
	game_timer.timeout.connect(_on_tick)
	
	updateLabels()
	update_queue_labels()
	
	# Ticking the population on start
	print(population)
	
	# Update starve label (it is not included in the function)
	starvelabel.text = ""

# These functions define clock speed
func _on_faster_time_button_pressed() -> void:
	game_timer.wait_time = 0.85
	print("Set faster time")
func _on_slower_time_button_pressed() -> void:
	game_timer.wait_time = 2
	print("Set slower time")
func _on_normal_time_button_pressed() -> void:
	game_timer.wait_time = 1
	print("Set normal time")

# The time start button and time stop respectively
func _on_start_button_pressed() -> void:
	if game_timer.is_stopped():
		game_timer.start()
		print("Time begins to flow...")
func _on_stop_button_pressed() -> void:
	if not game_timer.is_stopped():
		game_timer.stop()
		print("Time has stopped.")

var taxIntensity = 2
var incoming_taxes = ((adults + elderly) * 0.66) * TaxMult


func taxIntensitySystem():
	if taxIntensity == 4:
		incoming_taxes *= 1.50
		$Camera2D/CanvasLayer/PoliciesPanel/GeneralOrdainer/ButtonsColumn/HigherTaxesButton.disabled = true
		$Camera2D/CanvasLayer/PoliciesPanel/GeneralOrdainer/ButtonsColumn/LowerTaxesButton.disabled = false
	elif taxIntensity == 3:
		incoming_taxes *= 1.33
		$Camera2D/CanvasLayer/PoliciesPanel/GeneralOrdainer/ButtonsColumn/HigherTaxesButton.disabled = false
		$Camera2D/CanvasLayer/PoliciesPanel/GeneralOrdainer/ButtonsColumn/LowerTaxesButton.disabled = false
	elif taxIntensity == 2:
		incoming_taxes *= 1
		$Camera2D/CanvasLayer/PoliciesPanel/GeneralOrdainer/ButtonsColumn/HigherTaxesButton.disabled = false
		$Camera2D/CanvasLayer/PoliciesPanel/GeneralOrdainer/ButtonsColumn/LowerTaxesButton.disabled = false
	elif taxIntensity == 1:
		incoming_taxes *= 0.66
		$Camera2D/CanvasLayer/PoliciesPanel/GeneralOrdainer/ButtonsColumn/HigherTaxesButton.disabled = false
		$Camera2D/CanvasLayer/PoliciesPanel/GeneralOrdainer/ButtonsColumn/LowerTaxesButton.disabled = false
	elif taxIntensity == 0:
		incoming_taxes *= 0.40
		$Camera2D/CanvasLayer/PoliciesPanel/GeneralOrdainer/ButtonsColumn/HigherTaxesButton.disabled = false
		$Camera2D/CanvasLayer/PoliciesPanel/GeneralOrdainer/ButtonsColumn/LowerTaxesButton.disabled = true

func _on_higher_taxes_button_pressed():
	taxIntensity = clampi(taxIntensity + 1, 0, 4)
func _on_lower_taxes_button_pressed() -> void:
	taxIntensity = clampi(taxIntensity - 1, 0, 4)

# This gives functionality to the buildings panel
func _on_buildings_button_pressed() -> void:
	if BuildingsPanel.visible == true:
		BuildingsPanel.visible = false
	elif BuildingsPanel.visible == false:
		BuildingsPanel.visible = true

# This would be the 'Start Time' button function
func _on_tick():
	# Check for game over treshold early to prevent continuing time at zero population
	if population <= 0:
		print("Game Over - you are dead and so are your people")
		return
	if stability <= 0:
		print("Game Over - you were kicked out of your throne")
		return
	if subversion >= 100:
		print("Game Over - your population was subverted into letting an enemy enter")
		return
	
	if farms >= 25:
		$Camera2D/CanvasLayer/BuildingsPanel/GeneralOrdainer/ButtonsColumn/Farm/FarmButton.disabled = true
	if barracks >= 10:
		$Camera2D/CanvasLayer/BuildingsPanel/GeneralOrdainer/ButtonsColumn/Barracks/BarracksButton.disabled = true
	if workshop >= 25:
		$Camera2D/CanvasLayer/BuildingsPanel/GeneralOrdainer/ButtonsColumn/Workshop/WorkshopButton.disabled = true
	if center >= 10:
		$Camera2D/CanvasLayer/BuildingsPanel/GeneralOrdainer/ButtonsColumn/Center/CenterButton.disabled = true
	if hospital >= 5:
		$Camera2D/CanvasLayer/BuildingsPanel/GeneralOrdainer/ButtonsColumn/Hospital/HospitalButton.disabled = true
	if smithies >= 5:
		$Camera2D/CanvasLayer/BuildingsPanel/GeneralOrdainer/ButtonsColumn/Smithy/SmithyButton.disabled = true
	if labs >= 5:
		$Camera2D/CanvasLayer/BuildingsPanel/GeneralOrdainer/ButtonsColumn/Labs/LabsButton.disabled = true
	
	
	# Month and year translation at month 13
	# If you're seeing this as 'month 12 doesn't exist', that's a lie, because the variable update happens after this block
	if month == 12:
		year += 1
		month = 0
	
	# ^ The functions above simulate the passage of time.
	
	if building_queue.size() > 0:
		var current_project = building_queue[0]
		current_project["months_left"] -= 1
		print("Building ", current_project["type"], "... Months left: ", current_project["months_left"])
		
		# If it's done, pop it from the queue and add it to your empire!
		if current_project["months_left"] <= 0:
			if current_project["type"] == "farm":
				farms += 1
				print("A farm has finished construction!")
			elif current_project["type"] == "workshop":
				workshop += 1
				print("A workshop has finished construction!")
			elif current_project["type"] == "barracks":
				barracks += 1
				print("A barracks has finished construction!")
			elif current_project["type"] == "center":
				center += 1
				print("A hall has finished construction!")
			elif current_project["type"] == "hospital":
				hospital += 1
				print("A hospital has finished construction!")
			elif current_project["type"] == "smithy":
				smithies += 1
				print("A smithy has finished construction!")
			elif current_project["type"] == "labs":
				labs += 1
				print("A laboratory complex has finished construction!")
				
			building_queue.pop_front()
			buildingsCount = farms + barracks + center + hospital + smithies + labs
	
	update_queue_labels()
	Policy.advance_policy_tick()
	
	# The functions below would simulate the production and usage of resources.
	
	# Food
	if population >= 100:
		food = clampi((food + (int(adults * 1.3) + randi_range(20, 60) + (farms * 200)) * Fmult), 0, 10000)
	elif population < 100:
		food = clampi((food + (int(adults * 1.6) + randi_range(20, 60) + (farms * 100)) * Fmult), 0, 10000)
		# These two clamp integer statements aggregate the monthly food, but also means that food cannot go below zero (or you'd be causing a violation of the laws of matter conservation), or above 10000 (because it'd be too overpowered)
	food = clampi(food - (int(adults * 1) + int(children * 0.3) + int(elderly * 0.5) + int(soldiers * 1.2)), 0, 10000)
	food = max(0, food)
	
	# Materials
	materials = clampi(materials + int((workshop * 5) * Mmult), 0, 500)
	materials = clampi(materials - int((buildingsCount * 2) / Mmult), 0, 500)
	
	# Happiness is defined later
	
	# Stability is also defined later, but add this:
	stability = clampi(stability + int((center * 2) * StaMult), 0, 100)
	# Subversion is also defined later, but add this:
	subversion = clampi(subversion - int((center * 2) * SubMult), 0, 100)
	
	# Money
	money = clampi(money + incoming_taxes, -1000, 10000)
	money = clampi(money - totalupkeep, -1000, 10000)
	
	# I know soldiers are a pop and not a resource, but here goes this. It defines barracks functionality as the soldierlimit is barracks * 10
	var new_soldiers = randi_range(0, 2)
	soldiers = clampi(soldiers + new_soldiers, 0, soldierlimit)
	
	# The following functions describes the consequences of not having enough of a certain resource.
	if food <= 0:
		children -= randi_range(2, 10)
		elderly -= randi_range(3, 20)
		soldiers -= randi_range(1, 3)
		adults -= randi_range(1, 5)
		happiness = clampi(happiness - 5, 0, 100)
		starvelabel.text = "Your people are starving!"
		population = adults + children + elderly + soldiers
	elif food > 0 and food < 100:
		children += randi_range(0, 5)
		elderly -= randi_range(0, 1)
		
		var age_progression_adults = randi_range(0, 2)
		elderly += age_progression_adults
		adults -= age_progression_adults
		
		var age_progression_children = randi_range(0, 4)
		adults += age_progression_children
		children -= age_progression_children
		happiness = clampi(happiness + int(randi_range(1, 3) * Hmult), 0, 100)
		starvelabel.text = ""
		population = adults + children + elderly + soldiers
	elif food > 100:
		children += randi_range(2, 10)
		elderly -= randi_range(0, 1)
		
		var age_progression_adults = randi_range(1, 6)
		elderly += age_progression_adults
		adults -= age_progression_adults
		
		var age_progression_children = randi_range(1, 10)
		adults += age_progression_children
		children -= age_progression_children
		happiness = clampi(happiness + int(randi_range(2, 4) * Hmult), 0, 100)
		population = adults + children + elderly + soldiers
	
	if elderly >= (adults * 0.33):
		elderly -= randi_range (3, 12)
	
	if happiness >= 50:
		stability = clampi(stability + int(randi_range(1, 2) * StaMult), 0, 100)
	elif happiness >= 25 and happiness < 50:
		stability = clampi(stability - int(randi_range(1, 2) / StaMult), 0, 100)
	elif happiness < 25:
		stability = clampi(stability - int(randi_range(2, 3) / StaMult), 0, 100)
	
	if stability >= 50:
		subversion = clampi(subversion - int(randi_range(1, 2) / SubMult), 0, 100)
	elif stability >= 25 and stability < 50:
		subversion = clampi(subversion + int(randi_range(1, 2) * SubMult), 0, 100)
	elif stability < 25:
		subversion = clampi(subversion + int(randi_range(2, 3) * SubMult), 0, 100)
	
	if money <= -1000:
		print("Your nation has defaulted financially.")
		stability = clampi(stability - 50, 0, 100)
		happiness = clampi(happiness - 20, 0, 100)
		subversion += 10
		money = 100
		updateLabels()
		
		var lost_food = int(food * randf_range(0.8, 0.9))
		var lost_materials = int(materials * randf_range(0.8, 0.9))
		food -= lost_food
		materials -= lost_materials
		
		farms = 1
		workshop = 2
		barracks = 1
		center = 0
		hospital = 0
		smithies = 0
		labs = 0	
	elif money < 0:
		stability = clampi(stability - int(randi_range(5, 10) / StaMult), 0, 100)
		var lost_soldiers: int = randi_range(1, 2)
		soldiers -= lost_soldiers
		adults += lost_soldiers
		
	
	# Update both the variables and the labels
	month += 1
	updateLabels()
	
	# To be printed for debugging
	print("Year ", year, " - Month ", month)
	print("Population ", population, " - Food ", food)
	
# These functions would define the functionality of the building buttons
func _on_farm_button_pressed() -> void:
	if building_queue.size() >= 10:
		print("Construction queue is full! Wait for a project to finish.")
		return
	
	if materials < 50 or money < 250:
		return 
	
	materials -= 50
	money -= 250
	building_queue.append({"type": "farm", "months_left": 36})
	print("Farm added to the construction queue.")
	updateLabels()
	update_queue_labels()

func _on_workshop_button_pressed() -> void:
	if building_queue.size() >= 10:
		print("Construction queue is full! Wait for a project to finish.")
		return
	
	if materials < 100 or money < 300:
		return 
	
	materials -= 100
	money -= 300
	building_queue.append({"type": "workshop", "months_left": 48})
	print("Workshop added to the construction queue.")
	updateLabels()
	update_queue_labels()

func _on_barracks_button_pressed() -> void:
	if building_queue.size() >= 10:
		print("Construction queue is full! Wait for a project to finish.")
		return
	
	if materials < 100 or money < 350: 
		# Later add in a notifications setting that it is not possible because x resource is missing
		return 
	
	materials -= 100
	money -= 350
	building_queue.append({"type": "barracks", "months_left": 60})
	print("Barracks added to the construction queue.")
	updateLabels()
	update_queue_labels()

func _on_center_button_pressed() -> void:
	if building_queue.size() >= 10:
		print("Construction queue is full! Wait for a project to finish.")
		return
	
	if materials < 200 or money < 400:
		return
	
	materials -= 200
	money -= 400
	building_queue.append({"type": "center", "months_left": 60})
	print("Hall added to the construction queue.")
	updateLabels()
	update_queue_labels()

func _on_hospital_button_pressed() -> void:
	if building_queue.size() >= 10:
		print("Construction queue is full! Wait for a project to finish.")
		return
	
	if materials < 150 or money < 500:
		return
	
	materials -= 150
	money -= 500
	building_queue.append({"type": "hospital", "months_left": 48})
	print("Hospital added to the construction queue.")
	updateLabels()
	update_queue_labels()

func _on_smithy_button_pressed() -> void:
	if building_queue.size() >= 10:
		print("Construction queue is full! Wait for a project to finish.")
		return
	
	if materials < 100 or money < 400:
		return
	
	materials -= 100
	money -= 400
	building_queue.append({"type": "smithy", "months_left": 60})
	print("Smithy added to the construction queue.")
	updateLabels()
	update_queue_labels()

func _on_labs_button_pressed() -> void:
	if building_queue.size() >= 10:
		print("Construction queue is full! Wait for a project to finish.")
		return
	
	if materials < 300 or money < 600:
		return
	
	materials -= 300
	money -= 600
	building_queue.append({"type": "labs", "months_left": 60})
	print("Laboratory complex added to the construction queue.")
	updateLabels()
	update_queue_labels()

# DO NOT TOUCH

func _on_rationing_button_pressed() -> void:
	Policy.queue_policy_project("Rationing")

func _on_free_usage_button_pressed() -> void:
	Policy.queue_policy_project("Free Usage")

func _on_autocracy_button_pressed() -> void:
	Policy.queue_policy_project("Autocracy")

func _on_democracy_button_pressed() -> void:
	Policy.queue_policy_project("Democracy")

func _on_stricter_work_discipline_button_pressed() -> void:
	Policy.queue_policy_project("Stricter Work Discipline")

func _on_work_regulations_button_pressed() -> void:
	Policy.queue_policy_project("Work Regulations")

func _on_rights_button_pressed() -> void:
	Policy.queue_policy_project("Expanding the Rights")  # Ties to code key string

func _on_less_rights_button_pressed() -> void:
	Policy.queue_policy_project("Stricter Restrictions") # Ties to code key string
