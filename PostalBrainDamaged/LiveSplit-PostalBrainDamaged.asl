// Notes:
// i forgot how to write these lmfao

state("POSTAL Brain Damaged")
{
	double time : "GameAssembly.dll", 0x026F7EA0, 0xB8, 0x20, 0x78, 0x54;
}

gameTime {
	return;
}

isLoading {
	return current.time == old.time;
}
