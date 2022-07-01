// Notes:
// manually going backwards to another level will also trigger the autosplitter
// loading a save for a stage you are not on breaks the ingame timer, which breaks this until you go to main menu or load a good save
// while theres basic support for starting chapter runs, i dont actually detect the first or second boss yet so it splits weird

state("POSTAL Brain Damaged")
{
	long timePtr : "GameAssembly.dll", 0x026F7EA0, 0xB8, 0x20, 0x78, 0x10;
	bool doCount : "GameAssembly.dll", 0x026F7EA0, 0xB8, 0x20, 0x78, 0x50;
	double time : "GameAssembly.dll", 0x026F7EA0, 0xB8, 0x20, 0x78, 0x54;
	int levelId : "GameAssembly.dll", 0x026F7EA0, 0xB8, 0x20, 0x40, 0x30;
	int episodeId : "GameAssembly.dll", 0x026F7EA0, 0xB8, 0x20, 0x40, 0x38, 0x30;
	float playerHealth : "GameAssembly.dll", 0x026F7EA0, 0xB8, 0x20, 0x50, 0x70, 0x290, 0x98, 0x1C;
}

start {
	// this only triggers when the timer isnt running so logic is a little loose
	// if we start the first stage in a chapter and we came from the main menu
	// no episodeId check here to support chapter runs
	if ((current.levelId == 0) && (old.timePtr == 0) && (current.timePtr != old.timePtr)) return true;
}

reset {
	// if we start the first stage in a chapter and the episode number doesnt move forward then we can probably reset
	if ((current.levelId == 0) && (old.levelId != 0) && (current.episodeId <= old.episodeId)) return true;

	// if we re-select the first stage in a chapter and we came from the main menu
	if ((current.levelId == 0) && (old.levelId == 0) && (old.timePtr == 0) && (current.timePtr != old.timePtr)) return true;
}

isLoading {
	// always count time on the main menu
	if (current.timePtr == 0) return false;

	// dont count the time between stages (end-level menu, brain-proceed menu) or time loading saves
	return ((!current.doCount) && (current.time == old.time));
}

split {
	// dont split when entering the first mission of any episode (unless the previous level was a boss stage)
	// no episodeId check here to support chapter runs
	if ((current.levelId == 0) && (old.levelId != 4)) return false;

	// health check is to prevent a fake split from losing all of your health
	if (current.playerHealth < 0) return false;

	// basic final boss check
	// if you finish the final stage, split
	// ill find a better way to do this lmao
	if ((current.episodeId == 2) && (current.levelId == 4) && (current.doCount == false) && (current.time == old.time) && (current.time != 0)) return true;

	// split when the new level finishes loading
	return ((current.episodeId != old.episodeId) || (current.levelId != old.levelId));
}
