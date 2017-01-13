/* Copyright (C) 2016 Xendke
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*/
using Authenticator.Widgets;
using Gee;
namespace Authenticator.Services {
public class TOTPTimer {
	private Thread<int> timer_thread;
	Gee.ArrayList<int> timesteps; // TODO: object should grab all these lists as well as keep coun of how many of each timesteps.
	Gee.ArrayList<int> counters;
	GLib.Timer real_timer;

	private bool alive;
	public signal void time_is_up (int timestep);

	public TOTPTimer (){//period = 30
		alive = true;
		timesteps = new Gee.ArrayList<int> ();
		counters = new Gee.ArrayList<int> ();
		real_timer = new GLib.Timer ();
		timer_thread = new Thread<int> ("timer_thread", timer_loop);
	}

	private int timer_loop (){
		double second = 0;
		ulong elapsed = 0;
		while (alive) {
			if (second >= 1) {
				if (timesteps.size <= 0) { 
					continue;
				}
				stdout.printf("%f\n", second);
				for (int i = 0; i < timesteps.size; i++) { // check all timesteps and their corresponding counters
					counters.set(i, counters.get(i)+1); // add the second that has passed while sleeping
					if (counters.get(i) > timesteps[i]) {
						time_is_up (timesteps[i]);
						stdout.printf("time is up: %d\n", timesteps[i]);
						counters.set (i, 0); // reset counter once time is up
					}
				}
				real_timer.start ();
			}

			second = real_timer.elapsed (out elapsed);
		}
		Thread.exit(0);
		return 0;
	}
	public void register(int timestep) { // only register unique timesteps
		if(timestep_exists(timestep)){
			return;
		} else {
			timesteps.add(timestep);
			counters.add(0);
		}
	}
	public void deregister(int timestep) {

	}
	private bool timestep_exists (int timestep) {
		foreach (int i in timesteps){
			if(i == timestep) return true;
		}
		return false;
	}
	public void kill () {
		alive = false;
	}
}
}
