extends Node

var gName = Nationality.NAT_DELUGIA
var governmentForm = GovernmentForm.GOVFORM_REPUBLIC


func init(n : String):
	pass


func fullName() -> String:
	return GovernmentForm.governmentFullName(governmentForm, gName)
