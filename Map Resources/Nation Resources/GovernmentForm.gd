extends Node

const GOVFORM_REPUBLIC = "Republic"
const GOVFORM_UNITED_REPUBLIC = "United Republic"
const GOVFORM_KINGDOM = "Kingdom"
const GOVFORM_TSARDOM = "Tsardom"
const GOVFORM_PRINCIPALITY = "Principality"
const GOVFORM_THEOCRACY = "Theocracy"
const GOVFORM_KHANATE = "Khanate"

const GOVPOWER_DEMOCRATIC = "Democratic"
const GOVPOWER_AUTHORITARIAN = "Authoritarian"
const GOVPOWER_OTHER = "Other"

const GOVFORM_POS_PRE = "pre"
const GOVFORM_POS_POST = "post"
const GOVFORM_POS_ADJPRE = "adjpre"
const GOVFORM_POS_ADJPOST = "adjpost"

const GOVFORM_INTER_OF = "of"

const power = {
	GOVFORM_REPUBLIC		: GOVPOWER_DEMOCRATIC,
	GOVFORM_UNITED_REPUBLIC	: GOVPOWER_DEMOCRATIC,
	GOVFORM_KINGDOM			: GOVPOWER_AUTHORITARIAN,
	GOVFORM_TSARDOM			: GOVPOWER_AUTHORITARIAN,
	GOVFORM_PRINCIPALITY	: GOVPOWER_AUTHORITARIAN,
	GOVFORM_THEOCRACY		: GOVPOWER_AUTHORITARIAN,
	GOVFORM_KHANATE			: GOVPOWER_AUTHORITARIAN,
}

const pos = {
	GOVFORM_REPUBLIC		: GOVFORM_POS_PRE,
	GOVFORM_UNITED_REPUBLIC	: GOVFORM_POS_PRE,
	GOVFORM_KINGDOM			: GOVFORM_POS_PRE,
	GOVFORM_TSARDOM			: GOVFORM_POS_PRE,
	GOVFORM_PRINCIPALITY	: GOVFORM_POS_PRE,
	GOVFORM_THEOCRACY		: GOVFORM_POS_ADJPRE,
	GOVFORM_KHANATE			: GOVFORM_POS_ADJPOST,
}

const interject = {
	GOVFORM_REPUBLIC		: GOVFORM_INTER_OF,
	GOVFORM_UNITED_REPUBLIC	: GOVFORM_INTER_OF,
	GOVFORM_KINGDOM			: GOVFORM_INTER_OF,
	GOVFORM_TSARDOM			: GOVFORM_INTER_OF,
	GOVFORM_PRINCIPALITY	: GOVFORM_INTER_OF,
	GOVFORM_THEOCRACY		: "Holy",
	GOVFORM_KHANATE			: "Khanate",
}

func governmentFullName(gf : String, n : String):
	if pos[gf] == GOVFORM_POS_PRE:
		return gf + " " + interject[gf] + " " + n
	elif pos[gf] == GOVFORM_POS_POST:
		return n + " " + interject[gf] + " " + gf
	elif pos[gf] == GOVFORM_POS_ADJPRE:
		return interject[gf] + " " + n
	elif pos[gf] == GOVFORM_POS_ADJPOST:
		return n + " " + interject[gf]
	else:
		return "SOMETHING WENT WRONG"


func power(gf : String):
	return power[gf]















