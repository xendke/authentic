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
using GLib;
using Gtk;

namespace Authenticator.Services {
public class TOTPTimer {
	bool hasStarted;
	public int timePassed;
	ArrayList<int> timesteps;

	public signal void time_is_up (int period);
	public signal void increase_bar ();

	public TOTPTimer (){
		this.hasStarted = true;
		this.timePassed = 0;
		timesteps = new ArrayList<int> ();
		GLib.Timeout.add_seconds(1, this.tick);
		stdout.printf("totp timer started\n");
	}
	bool tick () {
		// max uint check
		this.timePassed++;
		stdout.printf("%u\n", this.timePassed);
		for (int i = 0; i < timesteps.size; i++) {
			if (timePassed%timesteps[i] == 0){
				time_is_up(timesteps[i]);
			}
		}
		increase_bar();
		return true;
	}
	public void register(int timestep) {
		// unique timesteps only
		if (!this.timesteps.contains(timestep)) {
			this.timesteps.add(timestep);
		}
	}
	public void deregister(int timestep) {
	}
}
}
