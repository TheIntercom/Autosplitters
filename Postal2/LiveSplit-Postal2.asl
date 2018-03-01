 state("Postal2")
{
	int isLoading : "Engine.dll", 0x6394EC, 0x228;
	int currentLevel : "Engine.dll", 0x6394EC, 0x340;
}

split
{
	return (old.currentLevel != 257 && current.currentLevel == 257);
}

reset
{
	return (old.currentLevel != 56 && current.currentLevel == 56);
}

isLoading
{
	return (old.isLoading == current.isLoading);
}