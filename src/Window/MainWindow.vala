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
using Authenticator.Services;

namespace Authenticator.View {

public class MainWindow : Gtk.Window {

    Gtk.HeaderBar bar;
	Gtk.Button bar_add_button;
	AccountWidget account_widget;
	
	public MainWindow (Granite.Application app) {
		// Window specific stuff
		set_application (app);
		set_default_size (600, 468);
		window_position = Gtk.WindowPosition.CENTER;

		
		StyleManager.add_stylesheet ("style/text.css");
		StyleManager.add_stylesheet ("style/elements.css");
	
		// Set up other GUI elements
		setup_headerbar (app);
		setup_layout ();
		connect_signals ();
	}

	public void setup_headerbar (Granite.Application app) {
		// Header bar
		this.bar = new Gtk.HeaderBar ();
		bar.set_show_close_button (true);
		bar.set_title (app.program_name);
		bar_add_button = new Button.from_icon_name ("list-add-symbolic");
		bar.pack_start (bar_add_button);
		this.set_titlebar (this.bar);
	}

	public void setup_layout () {	
		//  var main_box = new Box (Orientation.VERTICAL, 0);
		account_widget = new AccountWidget (this);
		//  main_box.pack_start (account_widget, true, true, 0);
		this.add (account_widget);
	}

	public void connect_signals () {
		bar_add_button.clicked.connect (account_widget.add_account);
	}
	
}

}
