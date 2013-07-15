namespace Bubblegum.UI
{
	public class ScrollableWindow : UI.Window
	{
		public static const int PAD_INITIAL_NLINES = 25;
		public static const int PAD_INITIAL_NCOLS = 80;


		public ScrollableWindow (
			WindowExtents e,
			bool decorated = true,
			WindowDecoration? decoration = null,
			Curses.Window? parent = null
		) {	
			Object();

			this.decorated = decorated;
			this.is_subwindow = (parent != null);
			this.decoration = decoration;
			this.extents = e;

			if (parent != null) {
			
			}

			if (decorated) {
				decoration = decoration ?? GFX.default_decoration;
				this.decor_win = new Curses.Window(e.nlines, e.ncols, e.y, e.x);
				this.canvas = new Curses.Pad(e.nlines - 2, e.ncols - 2);
				App.log("canvas = %p", this.canvas);
				GFX.decorate_window(this.decor_win, e, this.decoration);
			} else {
				this.canvas = new Curses.Pad(e.nlines, e.ncols);
			}
		}

		public new void refresh (bool output = true) {
			int ret;
			if (decorated) {
				if (output) {
					ret = ((Curses.Pad) canvas).refresh(
						0, 0,
						extents.y + 1, extents.x + 1,
						extents.y + extents.nlines - 4,
						extents.x +  extents.ncols - 4
					);
				} else {
					ret = ((Curses.Pad) canvas).noutrefresh(
						1, 1,
						extents.y + 1, extents.x + 1,
						extents.y + extents.nlines - 4,
						extents.x + extents.ncols - 4
					);
				}
				App.log("ret = %d", ret);
			} else {
				if (output) {
					canvas.refresh();
				} else {
					canvas.noutrefresh();
				}
			}

			foreach(UI.Window w in subwindows) {
				w.refresh(output);
			}
		}
	}
}