using GLib;
using Gee;

using Curses;

using Bubblegum.Core;

namespace Bubblegum.UI
{
	public class LayoutManager : Object
	{
		public signal void view_changed(View v);
		public bool computing_layout { get; private set; }

		private HashMap<string, Type> component_type_registry = new HashMap<string, Type>();

		public LayoutManager () {
			GFX.init();
			Curses.initscr();
			Curses.start_color();
			GFX.use_default_colors();

			// Register built-in view types
			component_type_registry["StatusView"] = typeof(StatusView);
			component_type_registry["PlaylistView"] = typeof(PlaylistView);
			component_type_registry["LogView"] = typeof(LogView);
			component_type_registry["VBox"] = typeof(LayoutVBox);
			component_type_registry["ScrollableTestView"] = typeof(ScrollableTestView);
//			component_type_registry["HBox"] = typeof(LayoutHBox);
			
		}

		public void run () {
			try {
				computing_layout = true;
				Config.layout_root.compute_layout(WindowExtents() {
					y = 0,
					x = 0,
					nlines = Curses.LINES,
					ncols = Curses.COLS
				});
				Curses.doupdate();
			} catch (Error e) {
				App.log(e.message);
				App.quit();
			} finally {
				computing_layout = false;
			}
		}

		public LayoutComponent? get_component_instance_for_name (string type_name) {
			if (!component_type_registry.has_key(type_name)) {
				return null;
			}

			Object c = Object.new(component_type_registry[type_name]);

			if(c is View) {
				(c as View).init();
			}

			return (LayoutComponent) c;
		}
		
		public void quit () {
			Curses.endwin();
		}
	}
}
