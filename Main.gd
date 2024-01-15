extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	#Get controls
	var ParametersLabelControl = $ParametersLabel
	var WebApplicationURLControl = $WebApplicationURLLabel
	var UserNameLabelControl = $UserNameLabel
	var HTTPTokenLabelControl = $HTTPTokenLabel
	
	# Define the variables
	var text_to_display = ""
	var WebApplicationURL = ""
	var paramUserName = ""
	var paramHTTPToken = ""
	
	var cmdline_args = OS.get_cmdline_args()
	#var FirstArguments = "--WebApplicationURL=https://blazorgodot.azurewebsites.net/,--UserName=TestUser,--HTTPToken=1234ABCD#"
	var FirstArguments = cmdline_args[0]
	
	var FirstArgumentsArray = FirstArguments.split(",")
	
	# Get all for text_to_display
	for arg in FirstArgumentsArray:
		text_to_display += arg + ", "
	
	# Remove the last comma and space if there are any arguments
	if FirstArgumentsArray.size() > 0:
		text_to_display = text_to_display.substr(0, text_to_display.length() - 2)
		
	# Set UserName and HTTPToken
	for i in range(FirstArgumentsArray.size()):
		if FirstArgumentsArray[i].begins_with("--WebApplicationURL"):
			var AllKeyParts = FirstArgumentsArray[i].split('=', true, 1)
			WebApplicationURL = AllKeyParts[1]
		if FirstArgumentsArray[i].begins_with("--UserName"):
			var AllKeyParts = FirstArgumentsArray[i].split('=', true, 1)
			paramUserName = AllKeyParts[1]
		if FirstArgumentsArray[i].begins_with("--HTTPToken"):
			var AllKeyParts = FirstArgumentsArray[i].split('=', true, 1)
			paramHTTPToken = AllKeyParts[1]

	ParametersLabelControl.text = "Parameters passed: " + text_to_display
	WebApplicationURLControl.text = WebApplicationURL
	UserNameLabelControl.text = paramUserName
	HTTPTokenLabelControl.text = paramHTTPToken

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_call_blazor_button_pressed():
	var http_request = $HTTPRequestNode
	var WebApplicationURLControl = $WebApplicationURLLabel
	var UserNameLabelControl = $UserNameLabel
	var HTTPTokenLabelControl = $HTTPTokenLabel
	
	# Connect the request_completed signal
	#http_request.connect("request_completed", Callable(self, "_on_request_completed"))	
	#http_request.connect(self._http_request_completed)
	http_request.request_completed.connect(self._on_request_completed)

	# Prepare data to send
	var user_name = UserNameLabelControl.text
	var http_token = HTTPTokenLabelControl.text

	# Send POST request 
	var url = WebApplicationURLControl.text + "ReceiveCallFromGodot/"
	var body_dict = {
		"userName": user_name,
		"hTTPToken": http_token
	}
	
	var json = JSON.new()
	var body = json.stringify(body_dict)
	var headers = ["Content-Type: application/json"]
	http_request.request_completed.connect(self._on_request_completed)
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		print("Error sending request: ", error)  # Print the specific error code
		
	
func _on_request_completed(result, response_code, headers, body):
	var BlazorResponseLabelControl = $BlazorResponseLabel	
	# Check the response code
	if response_code == 200:
		
		var body_string = body.get_string_from_utf8()
		print("Raw response body: ", body_string)
		BlazorResponseLabelControl.text = "Blazor Response: " + body_string
		
		var json = JSON.new()
		var parsed_data = JSON.parse_string(body_string)

		print("Parsed JSON data: ", parsed_data)
		
		# Accessing the message field in the JSON object
		if typeof(parsed_data) == TYPE_DICTIONARY and "message" in parsed_data:
			var message = parsed_data["message"]
			print("Message: ", message)			
			BlazorResponseLabelControl.text = "Blazor Response: " + message
		else:
			print("Unexpected JSON structure")
