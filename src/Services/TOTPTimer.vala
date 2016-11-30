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
	private GLib.Timer timer = new GLib.Timer ();
	private Thread<int> timer_thread;

	public signal void change_totp ();
	int period;
	private bool alive;

	public TOTPTimer (){//period = 30
		alive = true;
		timer_thread = new Thread<int> ("timer_thread", this.timer_loop);
		connect_signals ();
	}
	private  int timer_loop (){
		while (alive) {
			timer.start ();
			stdout.printf ("timer started\n");
			while (timer.elapsed () < 30) {//period
				Thread.usleep (1000000);
				stdout.printf ("%f\n", timer.elapsed ());
				
				if(!alive) {
					Thread.exit (0);
				}
			}
			timer.stop ();
			change_totp ();
		}
		return 0;
	}
	public void kill () {
		this.alive = false;
	}
	private void connect_signals () {
		
	}
}
}
