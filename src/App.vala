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

using Authenticator.Services;

namespace Authenticator {
public class App : Granite.Application {

    View.MainWindow main_window;

	construct {
        program_name = "Authentic";
    }

    public override void activate() {
        // Logging
        Granite.Services.Logger.DisplayLevel = Granite.Services.LogLevel.DEBUG;
        Granite.Services.Logger.initialize (this.program_name);

        main_window = new View.MainWindow (this);
        main_window.show_all ();
    }

    public static int main (string[] args) {
        Gtk.init (ref args);
        var app = new App ();

		return app.run(args);
    }
}

}
