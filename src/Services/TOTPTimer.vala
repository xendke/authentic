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
namespace Authenticator.Services {
public class TOTPTimer {
	private Thread<int> timer_thread;
	int[] timesteps;
	int[] counters;

	private bool alive;
	public signal void time_is_up (int timestep);

	public TOTPTimer (){//period = 30
		alive = true;
		timer_thread = new Thread<int> ("timer_thread", timer_loop);
	}

	private int timer_loop (){
		while (alive) {
			Thread.usleep (1000000);
			if (timesteps.length <= 0) {
				continue;
			}
			for (int i = 0; i < timesteps.length; i++) {
				if (counters[i] > timesteps[i]) {
					time_is_up (timesteps[i]);
					stdout.printf("time is up: %d", timesteps[i]);
					counters[i] = 0;
				}
				counters[i]++;
			}
		}
		Thread.exit(0);
		return 0;
	}
	public void register(int timestep) {
		if(timestep_exists(timestep)){
			return;
		} else {
			timesteps+=timestep;
			counters+=0;
		}
	}
	private bool timestep_exists (int timestep) {
		for (int i = 0; i < timesteps.length; i++) {
			if(timesteps[i] == timestep) return true;
		}
		return false;
	}
	public void kill () {
		alive = false;
	}
}
}
