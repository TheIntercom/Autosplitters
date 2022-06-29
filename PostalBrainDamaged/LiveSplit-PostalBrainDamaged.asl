// Notes:
// manually going backwards to another level will also trigger the autosplitter

state("POSTAL Brain Damaged")
{
	double time : "GameAssembly.dll", 0x026F7EA0, 0xB8, 0x20, 0x78, 0x54;
	int levelId : "GameAssembly.dll", 0x026F7EA0, 0xB8, 0x20, 0x40, 0x30;
	int episodeId : "GameAssembly.dll", 0x026F7EA0, 0xB8, 0x20, 0x40, 0x38, 0x30;
}

isLoading {
	return current.time == old.time;
}

split {
	return (current.levelId != old.levelId);
}
