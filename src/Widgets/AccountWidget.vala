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

using Granite.Widgets;

using Authenticator.View;
using Authenticator.Dialogs;
using Authenticator.Services;

namespace Authenticator.Widgets {
public class AccountWidget : Gtk.Box {
	private MainWindow window;
	private NewAccountDialog new_account_dialog;
	private Stack main_stack;
	private Gtk.Frame frame;
	private Welcome no_account_screen;
	private ScrolledWindow scrolled_window;
	private ListBox list_box;

	// Right Click Options
	Gtk.Menu right_click_menu;
	Gtk.MenuItem right_click_copy;
	Gtk.Clipboard clipboard;
	Gtk.MenuItem right_click_edit;
	Gtk.MenuItem right_click_delete;
	AccountItem row_targeted; // row selected/right clicked

	public AccountWidget (MainWindow window) {
		Object (orientation: Orientation.VERTICAL, spacing: 0);
		this.window = window;
		clipboard = Clipboard.get_for_display (window.get_display (), Gdk.SELECTION_CLIPBOARD);
		create_layout ();
		create_right_click_menu ();
		connect_signals ();
		update ();
	}
	private void create_layout (){
		main_stack = new Stack ();
		no_account_screen = new Welcome (_("No Accounts Set Up"), _("Click 'Add Account' to get started."));
		no_account_screen.append ("list-add", _("Add Account"), _("Let's Add an Acccount"));
		frame = new Gtk.Frame (null);
		frame.add (no_account_screen);
		frame.show_all ();
		main_stack.add_named (frame, "no-account-view");

		scrolled_window = new ScrolledWindow (null, null);
		scrolled_window.vexpand = true;
		scrolled_window.hexpand = true;

		list_box = new ListBox ();
		//list_box.set_selection_mode (Gtk.SelectionMode.NONE);
		list_box.set_sort_func (sort_account_func);

		scrolled_window.add (list_box);

		frame = new Gtk.Frame (null);
		frame.add (scrolled_window);
		frame.margin = 10;
		frame.show_all ();

		main_stack.add_named (frame, "account-view");

		var grid = new Grid ();
		grid.row_spacing = 12;
		grid.attach (main_stack, 0, 0, 1, 1);
		this.pack_start (grid);
	}
	private void create_right_click_menu (){
		right_click_menu = new Gtk.Menu ();
		right_click_delete = new Gtk.MenuItem.with_label("Delete");
		right_click_edit = new Gtk.MenuItem.with_label ("Edit");
		right_click_copy = new Gtk.MenuItem.with_label ("Copy");
		right_click_delete.activate.connect ( () => {
				remove_account ((AccountItem) row_targeted);
			});
		right_click_copy.activate.connect ( () => {
				clipboard.set_text (row_targeted.current_totp, -1);
//remove_account ((AccountItem) row_targeted);
			});
		right_click_menu.append(right_click_copy);
		right_click_menu.append(right_click_edit);
		right_click_menu.append(right_click_delete);

		right_click_menu.show_all ();
	}
	private void connect_signals () {
		no_account_screen.get_button_from_index(0).clicked.connect(add_account); // connect Welome screen button

	    list_box.button_press_event.connect_after ( (event) => { // clicks on ListBox
				row_targeted = (AccountItem )list_box.get_row_at_y((int)event.y);
				if(row_targeted == null){ // click on non-row
					list_box.unselect_all ();
					return false;
				}
				list_box.select_row(row_targeted); // select row clicked
				if(event.button == 3){ // if click was middle click
					right_click_menu.popup(null, null, null, 0, Gtk.get_current_event_time());
				}
				return false;
		});
	}
	public void add_account () {
		new_account_dialog = new NewAccountDialog(window);
		new_account_dialog.create_account.connect ((a) => {
				append_account (a);
		});
		new_account_dialog.show_all();
	}
	private void remove_account (AccountItem a) {
		list_box.remove (a);
		a.kill();
		update ();
	}
	private void update () {
		list_box.show_all ();

		var inc = list_box.get_children ().length ();

		if (inc == 0) {
			main_stack.set_visible_child_name ("no-account-view");

			//add small delay if daemon loads after application and list is empty
			//if (Hourglass.saved.alarms.length != 0) {
				//message ("hello");
			//	timeout_id = Timeout.add (500, load_alarms_source_func);
			//} else {
			//	load_alarms ();
			//}
		} else {
			main_stack.set_visible_child_name ("account-view");
		}
	}
	private int sort_account_func (ListBoxRow row1, ListBoxRow row2) {
		if (row1 is AccountItem && row2 is AccountItem) {
			var time1 = ((AccountItem) row1).title;
			var time2 = ((AccountItem) row2).title;

			return time1.collate (time2);
		} else {
			return 0;
		}
	}
	private void append_account (AccountItem a) {
		list_box.prepend (a);

		//a.state_toggled.connect ((b) => {
		//      message ("toggled");
		//      Hourglass.dbus_server.toggle_alarm (a.to_string ());
        //});

		//Hourglass.dbus_server.add_alarm (a.to_string ());
		update ();
	}
}
}
