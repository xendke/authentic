//  using Authenticator.Services;

namespace Authenticator {

public class Application : Gtk.Application {
    View.MainWindow main_window;
    public string program_name = "Authentic";

    public Application () {
        Object (
            application_id: "com.github.xendke.authentic",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        main_window = new View.MainWindow (this);
        main_window.show_all ();
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }
}

}
