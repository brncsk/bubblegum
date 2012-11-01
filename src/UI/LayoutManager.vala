using GLib;
using Gee;

using Curses;

using Bubblegum.Core;

namespace Bubblegum.UI
{
	public class LayoutManager : Object
	{
		public signal void view_changed(View v);

		private ViewLayout current_layout;
		private View current_view;
		private int current_index;

		private HashMap<string, Type> view_type_registry = new HashMap<string, Type>();

		public LayoutManager () {
			GFX.init();
			Curses.initscr();
			Curses.start_color();
			GFX.use_default_colors();

			// Register built-in view types
			view_type_registry["StatusView"] = typeof(StatusView);
			view_type_registry["PlaylistView"] = typeof(PlaylistView);
			view_type_registry["LogView"] = typeof(LogView);
		}

		public void set_layout (ViewLayout l) {
			if (l.items.is_empty) {
				return;
			}

			current_layout = l;
			foreach (ViewLayoutItem i in current_layout.items) {
				if(!view_type_registry.has_key(i.type)) {
					App.log("Invalid view type: %s.", i.type);
					continue;
				}

				i.view = (View) Object.new(view_type_registry[i.type]);
				i.view.init(i.extents);
			}

			set_view(current_index = 0);
		}

		public void set_view (int index) {
			View v = current_layout.items[index].view;
			current_view = v;
			view_changed(v);
			v.request_update();
		}

		public void cycle_views () {
			if (++current_index == current_layout.items.size) {
				current_index = 0;
			}

			set_view(current_index);
		}

		public void quit () {
			Curses.endwin();
		}
	}
}
