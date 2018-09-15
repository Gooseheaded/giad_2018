
/*
This is copied from the filters reference
*/
atom/proc/WaterEffect(WAVE_COUNT = 4)
	var/start = filters.len
	var/X,Y,rsq,i,f
	for(i=1, i<=WAVE_COUNT, ++i)
		// choose a wave with a random direction and a period between 10 and 30 pixels
		do
			X = 60*rand() - 30
			Y = 60*rand() - 30
			rsq = X*X + Y*Y
		while(rsq<100 || rsq>900)
		// keep distortion small, from 0.5 to 3 pixels
		// choose a random phase
		filters += filter(type="wave", x=X, y=Y, size=rand()*2.5+0.5, offset=rand())

	for(i=1, i<=WAVE_COUNT, ++i)
		// animate phase of each wave from its original phase to phase-1 and then reset;
		// this moves the wave forward in the X,Y direction
		f = filters[start+i]
		animate(f, offset=f:offset, time=0, loop=-1, flags=ANIMATION_PARALLEL)
		animate(offset=f:offset-1, time=rand()*20+10)