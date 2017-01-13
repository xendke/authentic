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

	public signal void changed_totp ();

	public AccountItem (string title, string  URI) {
		totp_manager = new TOTPManager (URI);
		this.title = title; // maybe get title fro totpman
		if (title.length == 0) {
			this.title = totp_manager.title;
		}
		this.subtitle = totp_manager.subtitle;
		update_totp ();
		create_layout ();
		connect_signals ();
	}

	private void create_layout () {
		var grid = new Grid();

		title_label = new Label (title);
		title_label.get_style_context ().add_class ("account-title");

		subtitle_label = new Label (subtitle);
		subtitle_label.get_style_context ().add_class ("account-subtitle");

		totp_label = new Label (prettify_totp(current_totp));
		totp_label.get_style_context ().add_class ("account-password");

		grid.attach (title_label, 0, 0, 1, 1);
		grid.attach (subtitle_label, 0, 1, 1, 1);
		grid.attach (new Spacer.w_hexpand (), 1, 0, 1, 2);
    grid.attach (totp_label, 2, 0, 2, 2);
		this.add (grid);
	}
	public void update_totp () {
		current_totp = totp_manager.get_current_totp ();
		totp_label.set_text (prettify_totp(current_totp));
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
	public void kill () {
		totp_manager.change_totp.disconnect (update_totp);
	}
	private void connect_signals () {
		totp_manager.change_totp.connect (update_totp);
	}
}
}
