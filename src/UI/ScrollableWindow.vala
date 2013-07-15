namespace Bubblegum.UI
{
	public class ScrollableWindow : UI.Window
	{
		public static const int PAD_INITIAL_NLINES = 25;
		public static const int PAD_INITIAL_NCOLS = 80;

		private int _xoffs = 0;
		private int _yoffs = 0;

		public int xoffs {
			get { return _xoffs; }
			set { _xoffs = value.clamp(0, current_ncols - extents.ncols + 2); }
		}

		public int yoffs {
			get { return _yoffs; }
			set { _yoffs = value.clamp(0, current_nlines - extents.nlines + 2); }
		}
	
		public int current_nlines { get; private set; }
		public int current_ncols  { get; private set; }

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
				GFX.decorate_window(this.decor_win, e, this.decoration);
			} else {
				this.canvas = new Curses.Pad(e.nlines, e.ncols);
			}
		}

		public override void pretty_print(int y, string s,
			TextAlignment t = TextAlignment.LEFT,
			TextAttribute a = 0,
			ColorPair cp = {-1, -1}
		) {
			if (s.char_count() > current_ncols) {
				canvas.resize(current_nlines, current_ncols = s.char_count());
			}

			if (y > current_nlines - 1) {
				canvas.resize(current_nlines = y + 1, current_ncols);
			}

			base.pretty_print(y, s, t, a, cp);
		}

		public override void refreshwin (bool output = true) {
			int ret;
			decor_win.refresh();
			if (decorated) {
				if (output) {
					ret = ((Curses.Pad) canvas).refresh(
						yoffs, xoffs,
						extents.y + 1, extents.x + 1,
						extents.y + extents.nlines - 2,
						extents.x +  extents.ncols - 2
					);
				} else {
					ret = ((Curses.Pad) canvas).noutrefresh(
						yoffs, xoffs,
						extents.y + 1, extents.x + 1,
						extents.y + extents.nlines - 2,
						extents.x + extents.ncols - 2
					);
				}
			} else {
				if (output) {
					canvas.refresh();
				} else {
					canvas.noutrefresh();
				}
			}

			foreach(UI.Window w in subwindows) {
				w.refreshwin(output);
			}
		}

		
	}
}
