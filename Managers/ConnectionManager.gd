extends Node

var IP_ADDRESS = "50.47.173.115"
var PORT = 9002

var socket = WebSocketPeer.new()
@onready var blip = preload("res://Managers/MinimapBlip.tscn")

func _ready():
	var certy = TLSOptions.client(load("res://serverCAS.crt"))
	socket.connect_to_url("wss://" + IP_ADDRESS + ":" + str(PORT), certy )

func _process(delta):
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		$"../SendDataButton".visible = true
		while socket.get_available_packet_count():
			var packbarr = socket.get_packet().get_string_from_utf8()
			print("Packet: ", packbarr)
			var Coords : Array = packbarr.split("|")
			
			if Coords.size() < 1:
				return
			
			for item in Coords:
				var comps : Array = item.split(",")
				if comps.size() < 2:
					return
				var b = blip.instantiate()
				add_child(b)
				b.position = Vector2(830 + int(comps[0])/2.0, int(comps[1])/2.0 + 320)
			
			
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false) # Stop processing.

func _on_send_data_button_pressed():
	socket.send_text("0,1,1,2,2")
