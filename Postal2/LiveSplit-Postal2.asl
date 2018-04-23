// Notes:
// "Map IDs": https://docs.google.com/spreadsheets/d/1SuWLtANcimPHN2W6exS0NPclKxDseMupCYCgezw2D5w/edit#gid=0
// Right now this script only supports the latest versions of Postal 2 and Paradise Lost (as of March 3rd, 2018).
// It might work for earlier versions but it's extremely doubtful.
// Furthermore, the "Map IDs" might change with with version differences breaking even more functionality.

// Known Bugs:
// Loading a save messes with the "Map ID" (currentLevel) in unpredictable ways.  The way that I've made
// this script should prevent that from mattering for Postal 2 and Apocalypse Weekend, but still remains
// a problem for Paradise Lost.  For Paradise Lost, reloading a save on the Zombie Church Escape or the first 
// Bitch Fight will cause the autosplitter to break for that day.
// Paradise Lost has been crashing a lot, there are various ways to handle this.
// Discord seems to throw a wrench in the load remover, causing it to behave save or lose time, depending on the computer.  Back to square one.

// ToDo:
// Find a method of determining the day without relying on the "MapID" (This will allow people to load saves on the triggering maps)
// Add crash detection (It's rare in P2 or AW in my experience, PL is a little rougher around the edges still)

state("Postal2", "5022")
{
	int isLoading : "Engine.dll", 0x6394EC, 0x228;
	double isLoadingExperimental : "Engine.dll", 0x6394EC, 0x33C, 0x664, 0x40C, 0xD0;

	int currentLevel : "Engine.dll", 0x6394EC, 0x340;
}

state("ParadiseLost", "5022")
{
	int isLoading : "Core.dll", 0xF7F24, 0x68;
	int currentLevel : "Core.dll", 0xF7F24, 0x180;
}

startup
{
	settings.Add("loadRemoval", false, "[Broken] Remove Load Times");
	settings.SetToolTip("loadRemoval", "My old method has proven to be faulty, until it is fixed it will remain for testing purposes");
	settings.Add("experimentalLoadRemoval", true, "[Experimental] Remove Load Times");
	settings.SetToolTip("experimentalLoadRemoval", "This is a new address found by Souzooka, this option supersedes the other load remover if checked");

	//These numbers are based on the Map ID we are going INTO.  So for Postal 2, at the end of each day
	//we go to a cutscene map with value 257.  For Apocalypse Weekend we go from the Hospital (6190) to
	//Lower Paradise 1 (2834), from Lower Paradise 1 we go to Cow Pasture (1268), etc.
	settings.Add("P2", true, "Postal 2 (5022) -> Regular gamemode, Monday through Friday");
	settings.Add("P2_257", true, "Autosplit at the end of each day", "P2");

	settings.Add("AW", true, "Apocalpyse Weekend (5022) -> Expansion gamemode, Saturday and Sunday");
	settings.SetToolTip("AW", "These will split upon completion of a map, cutscene and all, if selected");
	settings.Add("AW_2834", true, "Hospital", "AW");
	settings.Add("AW_1268", true, "Restaurant  (Lower Paradise 1)", "AW");
	settings.Add("AW_3030", true, "Cow Pasture", "AW");
	settings.Add("AW_2742", false, "Bullfish Interactive Opens (Lower Paradise 2)", "AW");
	settings.Add("AW_5520", true, "Bullfish Interactive (Boss: Phraud)", "AW");
	settings.Add("AW_534", true, "Vince's House", "AW");
	settings.Add("AW_620", true, "Elephant Preserve", "AW");
	settings.Add("AW_1248", false, "Entering Training Camp Part 1", "AW");
	settings.Add("AW_4086", false, "Entering Training Camp Part 2", "AW");
	settings.Add("AW_4040", false, "Entering Training Camp Part 3", "AW");
	settings.Add("AW_3513", false, "Inside Training Camp", "AW");
	settings.Add("AW_2089", false, "Escape Training Camp (Inside)", "AW");
	settings.Add("AW_2094", true, "Escape Training Camp (Outside)", "AW");
	settings.Add("AW_2979", false, "Military Base Part 1", "AW");
	settings.Add("AW_2680", false, "Military Base Part 2", "AW");
	settings.Add("AW_2876", false, "Military Base Part 3", "AW");
	settings.Add("AW_2770", true, "Military Base Part 4", "AW");
	settings.Add("AW_3696", false, "Apocalpyse (Lower Paradise 3)", "AW");
	settings.Add("AW_2826", true, "Bullfish Interactive Parking Garage", "AW");
	settings.Add("AW_1791", true, "Dog Pound", "AW");
	settings.Add("AW_9", true, "Bridge (Boss: Mike J)", "AW");

	//Paradise Lost is not that predictable when using the Map ID as a trigger due to loading a save
	//altering this value in (generally) unpredictable ways.
	settings.Add("PL", true, "Paradise Lost (5022) -> Expansion gamemode, Monday through Friday");
	settings.Add("PL_EndOfDay", true, "Autosplit at the end of each day", "PL");
}

init
{
	//Postal 2 and Paradise Lost happen to be the same exe for their latest version (5022)
	//This wasn't always the case and both have had exclusive versions (and thus, module sizes)
	int moduleSize = modules.First().ModuleMemorySize;
	if (game.ProcessName == "Postal2") {
		switch (moduleSize) {
			case 397312:
				version = "5022";
				break;
			default:
				print("[Postal 2] Unknown version");
				break;
		}
	}

	if (game.ProcessName == "ParadiseLost") {
		switch (moduleSize) {
			case 397312:
				version = "5022";
				break;
			default:
				print("[Postal 2] Unknown version");
				break;
		}
	}
}

split
{
	//We get placed on the same map at the end of every day so we just check for that.
	if (settings["P2_257"] && (old.currentLevel != 257 && current.currentLevel == 257))
		return true;

	//This gamemode is very linear so we (more or less) just check if we moved to a new map.
	if (settings["AW_" + current.currentLevel] && (old.currentLevel != current.currentLevel))
		return true;

	//This gamemode is fairly open, and does not have a consistent map we can check for to signify progression.
	//We'll just have to do it this way until we learn some more stuff about how the day/chore progression is stored.
	if (settings["PL_EndOfDay"]) {
		return (old.currentLevel == 922 && current.currentLevel == 3379) //Monday (Won't be an issue)
			|| (old.currentLevel == 3379 && current.currentLevel == 2838) //Tuesday
			|| (old.currentLevel == 1025 && current.currentLevel == 4075) //Wednesday
			|| (old.currentLevel == 324 && current.currentLevel == 2351) //Thursday (Won't be an issue)
			|| (old.currentLevel != 214 && current.currentLevel == 214); //Friday (Won't be an issue)
	}
}

reset
{
	return (old.currentLevel != 56 && current.currentLevel == 56) 
		|| (old.currentLevel != 63 && current.currentLevel == 63) 
		|| (old.currentLevel != 244 && current.currentLevel == 244);
}

isLoading
{
	//Souzooka found another tick address that seems promising at first glance, putting this in here for everyone to test.
	if (settings["experimentalLoadRemoval"]) {
		return (old.isLoadingExperimental == current.isLoadingExperimental);
	}

	//Just hacking this in so people can use the load remover if they still want to do their own testing.
	//As of March 23rd, 2018 we aren't using this feature since Discord interacts with it really awkwardly.
	if (settings["loadRemoval"]) {
		return (old.isLoading == current.isLoading);
	}
}
