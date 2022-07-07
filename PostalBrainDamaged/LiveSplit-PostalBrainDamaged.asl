state("POSTAL Brain Damaged") { }

startup {
	vars.Log = (Action<object>)(output => print("[POSTAL: Brain Damaged] " + output));

	var bytes = File.ReadAllBytes(@"Components\LiveSplit.ASLHelper.bin");
	var type = Assembly.Load(bytes).GetType("ASLHelper.Unity");
	vars.Helper = Activator.CreateInstance(type, timer, this);
	vars.Helper.LoadSceneManager = true;

	vars.canSplit = false;

	vars.STARTING_LEVEL_NAMES = new string[3]{
        "AD_Neighborhood",  // Straight Outta Suburbia
        "Asylum_Hospital",  // All Are Mad Here, Dude
        "NLM_ComicCon",  // Fluffy Friends Festival O' Fun
    };

	vars.IsStartingLevelName = (Func<string, bool>)((string levelName) => {
        foreach (string f in vars.STARTING_LEVEL_NAMES) {
            if (f == levelName) {
                return true;
            }
        }

        return false;
    });
}

init {
	vars.Helper.TryOnLoad = (Func<dynamic, bool>)(Mono => {
		var LC = Mono.GetClass("LevelController");
		if (LC.Fields.Count == 0) return false;

		var TC = Mono.GetClass("TimeController");
		vars.Helper["doCount"] = LC.Make<bool>("_instance", "_timeController", TC["_count"]);

		var P = Mono.GetClass("Player");
		var PHPC = Mono.GetClass("PlayerHitProcessorComponent");
		var HP = Mono.GetClass("HitPoints");
		vars.Helper["playerHealth"] = P.Make<float>("_instance", "_playerHitProcessor", PHPC["HitPoints"], HP["Current"]);
		vars.Helper["inCutscene"] = P.Make<bool>("_instance", "CancelIncomingDamage");

		var TM = Mono.GetClass("TimeManager");
		if (TM.Fields.Count == 0) return false;

		// for some reason i wasnt able to access _instance from TimeManager, but the parent worked just fine
		var TMP = Mono.GetParent(TM);
		vars.Helper["appTimescale"] = TMP.Make<float>("_instance", TM["_applicationTimeScale"]);

		return true;
	});

	current.Scene = "";

	vars.Helper.Load();
}

update {

	if (!vars.Helper.Update()) return false;

	current.doCount = vars.Helper["doCount"].Current;
	current.playerHealth = vars.Helper["playerHealth"].Current;
	current.inCutscene = vars.Helper["inCutscene"].Current;
	current.appTimescale = vars.Helper["appTimescale"].Current;

	current.Scene = vars.Helper.Scenes.Active.Name ?? old.Scene;
	current.IsValid = vars.Helper.Scenes.Active.IsValid ?? old.IsValid;

	if (current.Scene != old.Scene) vars.canSplit = true;
}

isLoading {
	// the engine is loading a new scene
	if (!current.IsValid) return true;

	// the game instantly puts you into cutscene state when you load a save
	// but the timescale doesnt get set to 0 until everything is finished
	if ((current.inCutscene) && (current.appTimescale == 1.0)) return true;

	// the game is saving

	return false;
}

split {
	// lmao
	// probably will be replaced if we can detect when the end level menu is active
	if ((current.Scene != "Title") && (current.playerHealth > 0.0) && (!current.doCount) && (current.inCutscene) && (current.appTimescale == 0.0) && (vars.canSplit)) {
		vars.canSplit = false;
		return true;
	}

	return false;
}

start {
	// we start when we are playing a starting level, but only once we gain control
	return ((current.doCount) && (!old.doCount) && (vars.IsStartingLevelName(current.Scene)));
}

reset {
	// we reset the moment a starting level finishes loading when coming from the main menu
	// doesnt support IL starts for e2m1 and e3m1 fwiw
	return ((old.Scene == "Title") && (vars.IsStartingLevelName(current.Scene)));
}

exit {
	vars.Helper.Dispose();
}

shutdown {
	vars.Helper.Dispose();
}
