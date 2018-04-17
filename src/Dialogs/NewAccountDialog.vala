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

using Authenticator.Widgets;
using Authenticator.View;

namespace Authenticator.Dialogs {
public class NewAccountDialog : Gtk.Dialog {
	private MainWindow window;
	private Entry name_entry;
	private Entry uri_entry;

	private ButtonBox hbutton_box;
	private new Button add_button;
	private Button cancel_button;

	public signal void create_account (AccountItem a);

	public NewAccountDialog (MainWindow window) {
		set_transient_for (window);
		this.window = window;

		set_resizable (false);
		set_deletable (false);
		set_modal (true);

		create_layout ();
		connect_signals ();
	}

	private void create_layout () {
		var main_grid = new Grid ();
		main_grid.row_spacing = 10;
		main_grid.column_spacing = 8;
		main_grid.margin_left = 10;
		main_grid.margin_right = 10;

		name_entry = new Entry ();
		var label = new Label (_("Name:"));
		label.halign = Gtk.Align.END;
		main_grid.attach (label, 0, 0, 1, 1);
		main_grid.attach (name_entry, 1, 0, 1, 1);

		uri_entry = new Entry ();
		// test
		uri_entry.set_text ("otpauth://totp/Example:alice@google.com?secret=JBSWY3DPEHPK3PXP&issuer=Example&period=10");
		label = new Label (_("URI:"));
		label.halign = Gtk.Align.END;
		main_grid.attach (label , 0, 1, 1, 1);
		main_grid.attach (uri_entry, 1, 1, 1, 1);


		hbutton_box = new ButtonBox (Gtk.Orientation.HORIZONTAL);
		hbutton_box.set_layout (Gtk.ButtonBoxStyle.SPREAD);
		hbutton_box.spacing = 6;
		hbutton_box.margin_top = 5;

		cancel_button = new Button.with_label (_("Cancel"));
		add_button = new Button.with_label (_("Add"));

		hbutton_box.pack_start(cancel_button);
		hbutton_box.pack_start(add_button);
		main_grid.attach (hbutton_box, 0,2,2,1);

		get_content_area ().add (main_grid);
	}
	private void connect_signals () {
		add_button.clicked.connect (() => {
				string title = name_entry.get_text();
				string uri = uri_entry.get_text ();
				if (is_valid_uri (uri) ){
					AccountItem a = new AccountItem (title, uri);
					create_account (a);
					this.destroy ();
				}
		});
		cancel_button.clicked.connect (() => {
				this.destroy ();
		});

	}
	private bool is_valid_uri (string uri) {
		if (!uri.contains ("otpauth://totp/")) {
			return false;
		}
		if (!uri.contains ("secret")) { //TODO
			return false;
		}
		if (!uri.contains ("?")) {
			return false;
		}
		return true;
	}
}
}
