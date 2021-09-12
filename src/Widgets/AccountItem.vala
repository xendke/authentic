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
using Gtk;
using Authenticator.Dialogs;
using Authenticator.Services;

namespace Authenticator.Widgets {
public class AccountItem : Gtk.ListBoxRow {
	public string title;
	public string subtitle;
	public string current_totp;
	private TOTPManager totp_manager;

	Gtk.Label title_label;
	Gtk.Label totp_label;
	Gtk.Label subtitle_label;
	Gtk.ProgressBar progress_bar;

	public signal void changed_totp ();

	public AccountItem (string title, string  URI) {
		totp_manager = new TOTPManager (URI);
		this.title = title; // maybe get title fro totpman
		if (title.length == 0) {
			this.title = totp_manager.title;
		}
		this.subtitle = totp_manager.subtitle;
		create_layout ();		
		initiate_totp ();
		connect_signals ();
	}

	private void create_layout () {
		var grid = new Grid ();
		grid.get_style_context ().add_class ("grid");

		title_label = new Gtk.Label (title);
		title_label.get_style_context ().add_class ("account-title");
		title_label.set_xalign (0);

		subtitle_label = new Gtk.Label (subtitle);
		subtitle_label.get_style_context ().add_class ("account-subtitle");
		subtitle_label.set_xalign (0);

		string text = prettify_totp(current_totp);
		totp_label = new Gtk.Label (text);
		totp_label.get_style_context ().add_class ("account-password");

		progress_bar = new Gtk.ProgressBar ();
		progress_bar.get_style_context ().add_class ("account-progress");

		grid.attach (title_label, 0, 0, 1, 1);
		grid.attach (subtitle_label, 0, 1, 1, 1);  
		grid.attach (new Spacer.w_hexpand (), 1, 0, 1, 2);
		grid.attach (totp_label, 2, 0, 2, 1);
		grid.attach (progress_bar, 2, 1, 2, 1);
		this.add (grid);
	}
	private void initiate_totp () {
		update_totp ();
		// set initial progress bar value
		// find the time passed since last update and set the bar fraction accordingly
		double time_passed = timer.timePassed%(double)this.totp_manager.timestep;
		double progress = time_passed * (1.0/(double)this.totp_manager.timestep);
		this.progress_bar.set_fraction (progress);
	}
	public void update_totp () {
		current_totp = totp_manager.get_current_totp ();
		string text = prettify_totp (current_totp);
		totp_label.set_text (text);
		// reset progress bar after updating to latest totp
		this.progress_bar.set_fraction (0.0);
		changed_totp ();
	}
	private string prettify_totp (string totp){
		string t = "";
		if(totp.length == 6){
			t+=totp[0:3];
			t+=" ";
			t+=totp[3:6];
		} else {
			t+=totp[0:4];
			t+=" ";
			t+=totp[4:8];
		}
		return t;
	}
	private void handle_increase_bar () {
		double progress = this.progress_bar.get_fraction ();
		progress = progress + (1.0/(double)this.totp_manager.timestep);
		this.progress_bar.set_fraction (progress);
	}
	private void check_for_update (int timestep) {
		// update only if the signal received is of the correct timestep
		if (this.totp_manager.timestep == timestep) {
			update_totp ();
		}
	}
	private void connect_signals () {
		timer.register(this.totp_manager.timestep); // make sure timer knows of this timestep
		timer.time_is_up.connect (check_for_update);
		timer.increase_bar.connect (handle_increase_bar);
	}
}
}
