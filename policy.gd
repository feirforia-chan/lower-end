class_name PolicyScript
extends Node

enum Rationing { RATIONING = 0, NEUTRAL = 1, MARKET_CAPITALISM = 2 }
enum Government { AUTOCRACY = 0, OLIGARCHY = 1, DEMOCRACY = 2 }
enum Labor { DISCIPLINE = 0, REGISTERED = 1, FREE = 2 }
enum Personal { AUTHORITARIANISM = 0, MEDIUM_RESTRICTIONS = 1, GUARANTEED = 2 }

var current_rationing: int = 1 
var current_government: int = 1 
var current_labor: int = 1
var current_personal: int = 1

var law_progress = {
	"Rationing": 0, "Free Usage": 0,
	"Autocracy": 0, "Democracy": 0,
	"Stricter Work Discipline": 0, "Work Regulations": 0, 
	"Expanding the Rights": 0, "Stricter Restrictions": 0
}

const RATIONING_NAMES = ["Strict rationing", "Rationing", "Food Market"]
const GOVT_NAMES = ["Autocracy", "Oligarchy", "Democracy"]
const LABOR_NAMES = ["Work discipline", "Registered workers", "Unionised workers"]
const PERSONAL_NAMES = ["Authoritarianism", "Mild Restrictions", "Guaranteed Rights"]

var policy_queue: Array = []
const MAX_QUEUE_SIZE: int = 10
var MONTHS_TO_RESEARCH: int = 24

var autocracy_label: Label
var rationing_label: Label
var work_rights_label: Label
var rights_label: Label
var government_label: Label
var statfoodlabel: Label
var statmatlabel: Label
var stathappylabel: Label
var statstabilitylabel: Label
var statsubvlabel: Label
var stattaxlabel: Label

func _ready() -> void:
	update_ideology()

func advance_policy_tick() -> void:
	if policy_queue.size() == 0:
		return
		
	var active_project = policy_queue[0]
	active_project["months_left"] -= 1
	
	if active_project["months_left"] <= 0:
		complete_policy_project(active_project["project_name"])
		policy_queue.pop_front()
		
	update_policy_ui()

func queue_policy_project(project_name: String) -> void:
	if policy_queue.size() >= MAX_QUEUE_SIZE:
		print("Policy queue is maxed out at 10 items!")
		return
		
	if not law_progress.has(project_name): 
		return
		
	policy_queue.append({
		"project_name": project_name,
		"months_left": MONTHS_TO_RESEARCH
	})
	
	update_policy_ui()

func complete_policy_project(project_name: String) -> void:
	if not law_progress.has(project_name): return
	
	law_progress[project_name] += 1
	
	if law_progress[project_name] == 1:
		law_progress[project_name] = 0
		apply_policy_change(project_name)
		
	update_ideology()
	update_policy_ui() # Added here so updates automatically cascade to the UI upon law completion!

func apply_policy_change(project_name: String) -> void:
	match project_name:
		"Rationing":
			current_rationing = max(0, current_rationing - 1)
			law_progress["Free Usage"] = 0
		"Free Usage":
			current_rationing = min(2, current_rationing + 1)
			law_progress["Rationing"] = 0
			
		"Autocracy":
			current_government = max(0, current_government - 1)
			law_progress["Democracy"] = 0
		"Democracy":
			current_government = min(2, current_government + 1)
			law_progress["Autocracy"] = 0
			
		"Stricter Work Discipline":
			current_labor = max(0, current_labor - 1)
			law_progress["Work Regulations"] = 0
		"Work Regulations":
			current_labor = min(2, current_labor + 1)
			law_progress["Stricter Work Discipline"] = 0
			
		"Stricter Restrictions":
			current_personal = max(0, current_personal - 1)
			law_progress["Expanding the Rights"] = 0
		"Expanding the Rights":
			current_personal = min(2, current_personal + 1)
			law_progress["Stricter Restrictions"] = 0

var current_ideology_name: String = "Centrist Oligarchy"
var current_modifiers: Dictionary = {}

func update_ideology() -> void:
	var config_id = "%d-%d-%d-%d" % [current_rationing, current_government, current_labor, current_personal]
	
	match config_id:
		"2-2-2-2":
			current_ideology_name = "Liberal Republic"
			current_modifiers = {"foodMult": 1.25, "matMult": 0.80, "happyMult": 1.30, "staMult": 0.70, "subvMult": 0.90, "taxMult": 0.50}
		"2-2-2-1":
			current_ideology_name = "Centrist Republic"
			current_modifiers = {"foodMult": 1.15, "matMult": 0.90, "happyMult": 1.10, "staMult": 0.90, "subvMult": 1.0, "taxMult": 1.20}
		"2-2-2-0":
			current_ideology_name = "Faux-Democracy"
			current_modifiers = {"foodMult": 1.05, "matMult": 1.00, "happyMult": 0.90, "staMult": 1.10, "subvMult": 1.10, "taxMult": 1.60}
		"2-2-1-2":
			current_ideology_name = "Bureaucratic Labour Republic"
			current_modifiers = {"foodMult": 1.40, "matMult": 1.00, "happyMult": 0.90, "staMult": 0.90, "subvMult": 0.70, "taxMult": 1.30}
		"2-2-0-2":
			current_ideology_name = "Corporate Democracy"
			current_modifiers = {"foodMult": 1.50, "matMult": 1.20, "happyMult": 0.80, "staMult": 0.80, "subvMult": 1.30, "taxMult": 2.10}
		"2-1-2-2":
			current_ideology_name = "Benevolent Junta"
			current_modifiers = {"foodMult": 1.00, "matMult": 1.30, "happyMult": 0.95, "staMult": 1.30, "subvMult": 0.60, "taxMult": 1.2}
		"2-0-2-2":
			current_ideology_name = "Benevolent Dictatorship"
			current_modifiers = {"foodMult": 1.05, "matMult": 1.40, "happyMult": 0.85, "staMult": 1.50, "subvMult": 0.40, "taxMult": 1.6}
		"1-2-2-2":
			current_ideology_name = "Socialist Democracy"
			current_modifiers = {"foodMult": 1.60, "matMult": 1.00, "happyMult": 0.70, "staMult": 0.90, "subvMult": 1.20, "taxMult": 1.8}
		"0-2-2-2":
			current_ideology_name = "Anarchosocialist Commune"
			current_modifiers = {"foodMult": 2.35, "matMult": 0.80, "happyMult": 0.50, "staMult": 0.60, "subvMult": 1.50, "taxMult": 0.4}
		"2-2-1-1":
			current_ideology_name = "Centrist Democracy"
			current_modifiers = {"foodMult": 0.90, "matMult": 1.10, "happyMult": 1.10, "staMult": 0.90, "subvMult": 1.00, "taxMult": 1.1}
		"2-1-2-1":
			current_ideology_name = "Syndicalists"
			current_modifiers = {"foodMult": 0.80, "matMult": 1.20, "happyMult": 1.30, "staMult": 0.70, "subvMult": 0.70, "taxMult": 0.2}
		"1-2-2-1":
			current_ideology_name = "Welfare Democracy"
			current_modifiers = {"foodMult": 1.05, "matMult": 1.00, "happyMult": 0.90, "staMult": 1.10, "subvMult": 1.10, "taxMult": 1.8}
		"2-1-1-2":
			current_ideology_name = "Technocratic Republic"
			current_modifiers = {"foodMult": 1.30, "matMult": 1.15, "happyMult": 1.05, "staMult": 1.00, "subvMult": 0.80, "taxMult": 1.5}
		"1-2-1-2":
			current_ideology_name = "Social Democratic Republic"
			current_modifiers = {"foodMult": 1.70, "matMult": 0.95, "happyMult": 1.15, "staMult": 0.75, "subvMult": 1.35, "taxMult": 1.4}
		"1-1-2-2":
			current_ideology_name = "Distributist State"
			current_modifiers = {"foodMult": 1.55, "matMult": 1.15, "happyMult": 0.95, "staMult": 1.00, "subvMult": 0.85, "taxMult": 1.8}
		"2-1-1-1":
			current_ideology_name = "Managed Constitutionalism"
			current_modifiers = {"foodMult": 1.10, "matMult": 1.10, "happyMult": 0.85, "staMult": 1.20, "subvMult": 0.80, "taxMult": 0.9}
		"1-2-1-1":
			current_ideology_name = "Democratic Regulated State"
			current_modifiers = {"foodMult": 1.50, "matMult": 0.95, "happyMult": 1.00, "staMult": 0.90, "subvMult": 1.15, "taxMult": 1.3}
		"1-1-2-1":
			current_ideology_name = "Corporatist Republic"
			current_modifiers = {"foodMult": 1.20, "matMult": 1.25, "happyMult": 0.75, "staMult": 1.25, "subvMult": 0.75, "taxMult": 1.5}
		"1-1-1-2":
			current_ideology_name = "Civil Directorate"
			current_modifiers = {"foodMult": 1.55, "matMult": 1.05, "happyMult": 0.90, "staMult": 1.05, "subvMult": 0.80, "taxMult": 1.2}
		"1-1-1-1":
			current_ideology_name = "Centrist Oligarchy"
			current_modifiers = {"foodMult": 1.30, "matMult": 1.05, "happyMult": 0.75, "staMult": 1.20, "subvMult": 0.85, "taxMult": 1}
		"2-2-0-0":
			current_ideology_name = "Hyper-Capitalist Police State"
			current_modifiers = {"foodMult": 0.85, "matMult": 1.35, "happyMult": 0.70, "staMult": 1.40, "subvMult": 1.20, "taxMult": 0.6}
		"2-0-2-0":
			current_ideology_name = "National Syndicalist Dictatorship"
			current_modifiers = {"foodMult": 0.60, "matMult": 1.50, "happyMult": 0.50, "staMult": 1.70, "subvMult": 0.30, "taxMult": 0.50}
		"0-2-2-0":
			current_ideology_name = "Command Economy Democracy"
			current_modifiers = {"foodMult": 2.10, "matMult": 1.10, "happyMult": 0.75, "staMult": 0.90, "subvMult": 1.40, "taxMult": 2.1}
		"2-0-0-2":
			current_ideology_name = "Libertarian Autocracy"
			current_modifiers = {"foodMult": 1.30, "matMult": 1.25, "happyMult": 0.95, "staMult": 1.20, "subvMult": 0.40, "taxMult": 0.6}
		"0-2-0-2":
			current_ideology_name = "Syndicalist Commune"
			current_modifiers = {"foodMult": 2.50, "matMult": 0.75, "happyMult": 1.10, "staMult": 0.50, "subvMult": 1.60, "taxMult": 0.5}
		"0-0-2-2":
			current_ideology_name = "Proletarian Dictatorship"
			current_modifiers = {"foodMult": 2.00, "matMult": 1.40, "happyMult": 0.55, "staMult": 1.30, "subvMult": 0.50, "taxMult": 3.3}
		"2-0-0-0":
			current_ideology_name = "Corporate Kleptocracy"
			current_modifiers = {"foodMult": 0.75, "matMult": 1.45, "happyMult": 0.35, "staMult": 1.65, "subvMult": 0.50, "taxMult": 3.5}
		"0-2-0-0":
			current_ideology_name = "Authoritarian Socialist Republic"
			current_modifiers = {"foodMult": 2.05, "matMult": 0.85, "happyMult": 0.60, "staMult": 1.15, "subvMult": 1.30, "taxMult": 2.1}
		"0-0-2-0":
			current_ideology_name = "Stratocracy"
			current_modifiers = {"foodMult": 1.60, "matMult": 1.50, "happyMult": 0.30, "staMult": 1.80, "subvMult": 0.20, "taxMult": 1.4}
		"0-0-0-2":
			current_ideology_name = "Feudal Monarchy"
			current_modifiers = {"foodMult": 2.20, "matMult": 0.90, "happyMult": 0.65, "staMult": 1.25, "subvMult": 0.30, "taxMult": 0.3}
		"0-0-0-0":
			current_ideology_name = "Totalitarian Dystopia"
			current_modifiers = {"foodMult": 1.70, "matMult": 1.10, "happyMult": 0.15, "staMult": 2.00, "subvMult": 0.40, "taxMult": 5}
		"1-1-1-0":
			current_ideology_name = "Authoritarian Bureaucracy"
			current_modifiers = {"foodMult": 1.20, "matMult": 1.10, "happyMult": 0.55, "staMult": 1.40, "subvMult": 0.70, "taxMult": 1.5}
		"1-1-0-1":
			current_ideology_name = "Protectionist State"
			current_modifiers = {"foodMult": 1.45, "matMult": 1.15, "happyMult": 0.85, "staMult": 1.10, "subvMult": 0.90, "taxMult": 1.1}
		"1-0-1-1":
			current_ideology_name = "Paternalistic Autocracy"
			current_modifiers = {"foodMult": 1.30, "matMult": 1.25, "happyMult": 0.65, "staMult": 1.40, "subvMult": 0.45, "taxMult": 1.3}
		"0-1-1-1":
			current_ideology_name = "State Capitalist Oligarchy"
			current_modifiers = {"foodMult": 1.80, "matMult": 1.25, "happyMult": 0.60, "staMult": 1.30, "subvMult": 0.80, "taxMult": 1.5}
		"1-1-0-0":
			current_ideology_name = "Bureaucratic Police State"
			current_modifiers = {"foodMult": 1.20, "matMult": 1.20, "happyMult": 0.50, "staMult": 1.50, "subvMult": 0.80, "taxMult": 1.3}
		"1-0-1-0":
			current_ideology_name = "Illiberal Dictatorship"
			current_modifiers = {"foodMult": 1.10, "matMult": 1.30, "happyMult": 0.45, "staMult": 1.60, "subvMult": 0.40, "taxMult": 1.7}
		"0-1-1-0":
			current_ideology_name = "Regulated One-Party State"
			current_modifiers = {"foodMult": 1.70, "matMult": 1.30, "happyMult": 0.45, "staMult": 1.45, "subvMult": 0.70, "taxMult": 1.9}
		"0-1-0-1":
			current_ideology_name = "Command Council"
			current_modifiers = {"foodMult": 2.15, "matMult": 1.00, "happyMult": 0.70, "staMult": 1.15, "subvMult": 0.95, "taxMult": 1.8}
		"1-0-0-0":
			current_ideology_name = "Absolute Martial Law"
			current_modifiers = {"foodMult": 1.10, "matMult": 1.30, "happyMult": 0.25, "staMult": 1.85, "subvMult": 0.50, "taxMult": 2}
		"0-1-0-0":
			current_ideology_name = "Totalitarian Oligarchy"
			current_modifiers = {"foodMult": 1.95, "matMult": 1.10, "happyMult": 0.35, "staMult": 1.55, "subvMult": 0.85, "taxMult": 1.15}
		"0-0-1-0":
			current_ideology_name = "Police Bureaucracy"
			current_modifiers = {"foodMult": 1.75, "matMult": 1.35, "happyMult": 0.30, "staMult": 1.75, "subvMult": 0.30, "taxMult": 1.6}
		"0-0-0-1":
			current_ideology_name = "Totalitarian Autocracy"
			current_modifiers = {"foodMult": 1.95, "matMult": 1.00, "happyMult": 0.35, "staMult": 1.80, "subvMult": 0.25, "taxMult": 3.5}
		"2-2-1-0":
			current_ideology_name = "Illiberal Capitalist Republic"
			current_modifiers = {"foodMult": 0.85, "matMult": 1.15, "happyMult": 1.00, "staMult": 1.10, "subvMult": 1.10, "taxMult": 3.3}
		"2-2-0-1":
			current_ideology_name = "Neoliberal Oligarchy"
			current_modifiers = {"foodMult": 1.15, "matMult": 1.25, "happyMult": 1.00, "staMult": 1.00, "subvMult": 1.20, "taxMult": 2.1}
		"2-1-2-0":
			current_ideology_name = "Nationalist Republic"
			current_modifiers = {"foodMult": 0.70, "matMult": 1.30, "happyMult": 0.95, "staMult": 1.20, "subvMult": 0.60, "taxMult": 2}
		"2-1-0-2":
			current_ideology_name = "Privatized Cyber-Oligarchy"
			current_modifiers = {"foodMult": 1.35, "matMult": 1.40, "happyMult": 0.90, "staMult": 1.00, "subvMult": 0.90, "taxMult": 0.8}
		"2-1-0-1":
			current_ideology_name = "Bourgeois Republic"
			current_modifiers = {"foodMult": 1.05, "matMult": 1.30, "happyMult": 0.80, "staMult": 1.15, "subvMult": 0.85, "taxMult": 1.5}
		"2-1-0-0":
			current_ideology_name = "Authoritarian Corporate Junta"
			current_modifiers = {"foodMult": 0.90, "matMult": 1.35, "happyMult": 0.65, "staMult": 1.35, "subvMult": 0.75, "taxMult": 1.85}
		"2-0-1-2":
			current_ideology_name = "Enlightened Despotism"
			current_modifiers = {"foodMult": 1.20, "matMult": 1.20, "happyMult": 0.90, "staMult": 1.25, "subvMult": 0.40, "taxMult": 0.9}
		"2-0-1-1":
			current_ideology_name = "Paternalist Dictatorship"
			current_modifiers = {"foodMult": 1.00, "matMult": 1.25, "happyMult": 0.70, "staMult": 1.40, "subvMult": 0.35, "taxMult": 1.3}
		"2-0-1-0":
			current_ideology_name = "Military Dictatorship"
			current_modifiers = {"foodMult": 0.85, "matMult": 1.30, "happyMult": 0.55, "staMult": 1.60, "subvMult": 0.30, "taxMult": 1.5}
		"2-0-2-1":
			current_ideology_name = "Garrison State"
			current_modifiers = {"foodMult": 0.90, "matMult": 1.45, "happyMult": 0.70, "staMult": 1.45, "subvMult": 0.35, "taxMult": 1.3}
		"1-2-2-0":
			current_ideology_name = "Popular Front Republic"
			current_modifiers = {"foodMult": 1.40, "matMult": 1.10, "happyMult": 0.75, "staMult": 1.10, "subvMult": 1.20, "taxMult": 1.5}
		"1-2-1-0":
			current_ideology_name = "Socialist Police State"
			current_modifiers = {"foodMult": 1.55, "matMult": 0.95, "happyMult": 0.65, "staMult": 1.20, "subvMult": 1.25, "taxMult": 1.1}
		"1-2-0-2":
			current_ideology_name = "Consumerist Social Democracy"
			current_modifiers = {"foodMult": 1.85, "matMult": 1.05, "happyMult": 1.05, "staMult": 0.75, "subvMult": 1.45, "taxMult": 1}
		"1-2-0-1":
			current_ideology_name = "Mixed Economy Democracy"
			current_modifiers = {"foodMult": 1.60, "matMult": 1.00, "happyMult": 0.95, "staMult": 0.85, "subvMult": 1.30, "taxMult": 0.7}
		"1-2-0-0":
			current_ideology_name = "Authoritarian Welfare State"
			current_modifiers = {"foodMult": 1.45, "matMult": 1.05, "happyMult": 0.75, "staMult": 1.10, "subvMult": 1.35, "taxMult": 1.4}
		"1-0-2-2":
			current_ideology_name = "Meritocratic Autocracy"
			current_modifiers = {"foodMult": 1.30, "matMult": 1.45, "happyMult": 0.70, "staMult": 1.30, "subvMult": 0.40, "taxMult": 1}
		"1-0-2-1":
			current_ideology_name = "Nationalist Junta"
			current_modifiers = {"foodMult": 1.10, "matMult": 1.50, "happyMult": 0.55, "staMult": 1.50, "subvMult": 0.35, "taxMult": 1.3}
		"1-0-2-0":
			current_ideology_name = "Strict Police Dictatorship"
			current_modifiers = {"foodMult": 0.95, "matMult": 1.55, "happyMult": 0.40, "staMult": 1.70, "subvMult": 0.30, "taxMult": 1.5}
		"1-0-0-2":
			current_ideology_name = "What the hell is this supposed to be?!?!"
			current_modifiers = {"foodMult": 1.65, "matMult": 1.10, "happyMult": 0.75, "staMult": 1.20, "subvMult": 0.45, "taxMult": 2}
		"1-0-0-1":
			current_ideology_name = "Bureaucratic Dictatorship"
			current_modifiers = {"foodMult": 1.45, "matMult": 1.15, "happyMult": 0.50, "staMult": 1.45, "subvMult": 0.40, "taxMult": 2}
		"0-2-2-1":
			current_ideology_name = "Democratic Socialist State"
			current_modifiers = {"foodMult": 2.10, "matMult": 0.90, "happyMult": 0.75, "staMult": 0.75, "subvMult": 1.40, "taxMult": 1.2}
		"0-2-1-2":
			current_ideology_name = "Decentralized Collectivist Commune"
			current_modifiers = {"foodMult": 2.45, "matMult": 0.70, "happyMult": 1.05, "staMult": 0.55, "subvMult": 1.25, "taxMult": 0.3}
		"0-2-1-1":
			current_ideology_name = "Regulated Socialist Republic"
			current_modifiers = {"foodMult": 2.20, "matMult": 0.80, "happyMult": 0.85, "staMult": 0.75, "subvMult": 1.30, "taxMult": 0.7}
		"0-2-1-0":
			current_ideology_name = "Soviet Democracy"
			current_modifiers = {"foodMult": 2.05, "matMult": 0.85, "happyMult": 0.65, "staMult": 1.00, "subvMult": 1.35, "taxMult": 1.2}
		"0-2-0-1":
			current_ideology_name = "Seize the means of production!"
			current_modifiers = {"foodMult": 2.25, "matMult": 0.90, "happyMult": 0.90, "staMult": 0.70, "subvMult": 1.40, "taxMult": 0.2}
		"0-1-2-2":
			current_ideology_name = "Populist Labour Oligarchy"
			current_modifiers = {"foodMult": 1.80, "matMult": 1.35, "happyMult": 0.70, "staMult": 1.20, "subvMult": 0.75, "taxMult": 0.9}
		"0-1-2-1":
			current_ideology_name = "Controlled Labour State"
			current_modifiers = {"foodMult": 1.65, "matMult": 1.40, "happyMult": 0.55, "staMult": 1.35, "subvMult": 0.70, "taxMult": 1.1}
		"0-1-2-0":
			current_ideology_name = "Spartan Oligarchy"
			current_modifiers = {"foodMult": 1.45, "matMult": 1.50, "happyMult": 0.40, "staMult": 1.55, "subvMult": 0.60, "taxMult": 0.70}
		"0-1-0-2":
			current_ideology_name = "Guild Socialism"
			current_modifiers = {"foodMult": 2.30, "matMult": 0.85, "happyMult": 0.80, "staMult": 1.00, "subvMult": 0.85, "taxMult": 1.9}
		"0-0-2-1":
			current_ideology_name = "Fascist Police State"
			current_modifiers = {"foodMult": 1.75, "matMult": 1.45, "happyMult": 0.45, "staMult": 1.65, "subvMult": 0.25, "taxMult": 2.1}
		"0-0-1-2":
			current_ideology_name = "Feudal Technocracy"
			current_modifiers = {"foodMult": 2.10, "matMult": 1.15, "happyMult": 0.65, "staMult": 1.35, "subvMult": 0.35, "taxMult": 1.7}
		"0-0-1-1":
			current_ideology_name = "Martial Directorate"
			current_modifiers = {"foodMult": 1.85, "matMult": 1.20, "happyMult": 0.45, "staMult": 1.55, "subvMult": 0.30, "taxMult": 3.5}
		"0-1-1-2":
			current_ideology_name = "Libertarian Syndicalist Oligarchy"
			current_modifiers = {"foodMult": 2.10, "matMult": 1.15, "happyMult": 0.85, "staMult": 0.95, "subvMult": 0.80, "taxMult": 1.1}
		"1-0-1-2":
			current_ideology_name = "Enlightened Stratocratic State"
			current_modifiers = {"foodMult": 1.55, "matMult": 1.20, "happyMult": 0.75, "staMult": 1.20, "subvMult": 0.45, "taxMult": 0.95}
		"1-1-0-2":
			current_ideology_name = "Free Market Bureaucracy"
			current_modifiers = {"foodMult": 1.65, "matMult": 0.95, "happyMult": 0.95, "staMult": 0.95, "subvMult": 0.95, "taxMult": 0.1}
		"1-1-2-0":
			current_ideology_name = "State Syndicalist Directorate"
			current_modifiers = {"foodMult": 1.00, "matMult": 1.35, "happyMult": 0.50, "staMult": 1.40, "subvMult": 0.75, "taxMult": 2.1}
		"2-0-0-1":
			current_ideology_name = "Autocratic Privatized Dominion"
			current_modifiers = {"foodMult": 1.05, "matMult": 1.20, "happyMult": 0.55, "staMult": 1.45, "subvMult": 0.45, "taxMult": 2.1}
		"2-1-1-0":
			current_ideology_name = "Conservative Constabulary State"
			current_modifiers = {"foodMult": 0.90, "matMult": 1.15, "happyMult": 0.65, "staMult": 1.35, "subvMult": 0.75, "taxMult": 1.3}
			
	print("New Ideology: ", current_ideology_name)

func update_policy_ui() -> void:
	if rationing_label == null or autocracy_label == null or work_rights_label == null or rights_label == null:
		print("Warning: Policy UI labels are not initialized yet!")
		return
	
	rationing_label.text = RATIONING_NAMES[current_rationing]
	autocracy_label.text = GOVT_NAMES[current_government]
	work_rights_label.text = LABOR_NAMES[current_labor]
	rights_label.text = PERSONAL_NAMES[current_personal]
	government_label.text = current_ideology_name
	statfoodlabel.text = "Food: " + str(current_modifiers.foodMult * 100) + "%"
	statmatlabel.text = "Materials: " + str(current_modifiers.matMult * 100) + "%"
	stathappylabel.text = "Happiness: " + str(current_modifiers.happyMult * 100) + "%"
	statstabilitylabel.text = "Stability: " + str(current_modifiers.staMult * 100) + "%"
	statsubvlabel.text = "Subversion: " + str(current_modifiers.subvMult * 100) + "%"
	stattaxlabel.text = "Taxes: " + str(current_modifiers.taxMult * 100) + "%"
	
	var base_path = "/root/Main/Camera2D/CanvasLayer/PoliciesPanel/GeneralOrdainer/PoliciesColumn/VBoxContainer/List"
	for i in range(1, 11):
		var slot_label = get_node_or_null(base_path + str(i)) as Label
		if slot_label == null: continue
		
		var queue_idx = i - 1
		if queue_idx < policy_queue.size():
			var item = policy_queue[queue_idx]
			slot_label.text = "%d. %s (%dm)" % [i, item["project_name"], item["months_left"]]
		else:
			slot_label.text = "%d. Vacant" % i
