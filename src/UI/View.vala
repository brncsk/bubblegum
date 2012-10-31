using GLib;
using Gee;

using Curses;

namespace Bubblegum.UI
{
	public abstract class View : Object
	{
		protected InputDelegateMap bindings = new InputDelegateMap();
		protected UI.Window canvas;

		protected WindowExtents current_extents;

		protected WindowDecoration decor = GFX.default_decoration;
		protected bool decorated = true;

		protected abstract void update ();

		public InputDelegateMap get_bindings () {
			return bindings;
		}

		public virtual void init(WindowExtents e) {
			current_extents = e;

			canvas = new Window(e, decorated, decor);
		}

		public void request_update () {
			App.draw_synchronized(() => {
				canvas.erase();
				update();
				canvas.refresh();
			});
		}

		public void refresh () {
			assert_not_reached();
		}
	}
}
