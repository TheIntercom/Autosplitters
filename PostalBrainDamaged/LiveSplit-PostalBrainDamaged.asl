// Notes:
// manually going backwards to another level will also trigger the autosplitter
// loading a save for a stage you are not on breaks the ingame timer, which breaks this

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
	// this only triggers when the timer isnt running so we dont have to worry about anything weird
	// no episodeId check here to support chapter runs
	if ((current.levelId == 0) && (old.timePtr == 0) && (current.timePtr != old.timePtr)) return true;
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

	// basic final boss check
	// if the timer actually stops (finish the level, die, load a save, or go back to the main menu) when youre playing the final stage, split
	// ill find a better way to do this lmao
	if ((current.episodeId == 2) && (current.levelId == 4) && (current.doCount == false) && (current.time == old.time) && (current.time != 0) && (current.playerHealth < 0)) return true;

	// split when the new level finishes loading
	return ((current.episodeId != old.episodeId) || (current.levelId != old.levelId));
}
