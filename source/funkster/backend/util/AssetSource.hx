package funkster.backend.util;

enum abstract AssetSource(Null<Bool>) from Bool from Null<Bool> to Null<Bool> {
	var SOURCE = true;
	var MODS = false;
	var BOTH = null;
}