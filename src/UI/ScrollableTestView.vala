using GLib;

using Bubblegum.Core;
using Bubblegum.Models;

namespace Bubblegum.UI
{
	public class ScrollableTestView : View
	{
		construct {
			decor.c = { 239, -1 };
			decor.b = { 239, -1 };
			decor.bg = { 245, -1 };
			decor.tb = { 239, -1 };
			decor.title = "Scrolling test";
		}

		public override void init () {
			App.input_manager.global_bindings['w'] = () => {
				(window as ScrollableWindow).yoffs -= 1;
				request_update();
			};
			App.input_manager.global_bindings['s'] = () => {
				(window as ScrollableWindow).yoffs += 1;
				request_update();
			};
		}

		public override void compute_layout (WindowExtents e) throws LayoutError {
			current_extents = e;
			window = new UI.ScrollableWindow(e, decorated, decor);

			WindowExtents oe = { e.nlines - 3, e.ncols - 2, 1, 0 };
			request_update();
		}

		public override void update () {
			for (int i = 1; i < 30; i++)
				window.pretty_print(i,
					"TESZT %d".printf(i),
					TextAlignment.LEFT,
					TextAttribute.BOLD,
					ColorPair(158, 108)
				);
		}

	}

}

