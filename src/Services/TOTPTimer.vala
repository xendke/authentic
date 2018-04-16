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

namespace Authenticator.Services {
public class TOTPTimer {
	public bool alive;
	public signal void time_is_up ();


	private bool done() {
		time_is_up ();
		stdout.printf("times up\n");
		return this.alive;
	}

	public TOTPTimer (int timestep){
		stdout.printf("totp timer started\n");
		stdout.printf("%u\n",timestep);
		GLib.Timeout.add(timestep*1000, this.done);
	}
	public void register(int timestep) { 
	}
	public void deregister(int timestep) {
	}

	public void kill () {
	}
}
}
