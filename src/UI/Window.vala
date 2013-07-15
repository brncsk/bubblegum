using GLib;
using Gee;

namespace Bubblegum.UI {
	
	public class Window : GLib.Object {

		public Curses.Window canvas { get; protected owned set; }
		public WindowExtents extents { get; protected set; }

		public bool is_subwindow { get; protected set; }
		public bool decorated { get; protected set; }

		public WindowDecoration? decoration { get; protected set; }

		protected Curses.Window decor_win;
		protected LinkedList<UI.Window> subwindows = new LinkedList<UI.Window>();

		public Window (
			WindowExtents e,
			bool decorated = true,
			WindowDecoration? decoration = null,
			Curses.Window? parent = null
		) {
			this.decorated = decorated;
			this.is_subwindow = (parent != null);
			this.decoration = decoration;
			this.extents = e;

			Curses.Window w;

			if (parent != null) {
				w = parent.derwin(e.nlines, e.ncols, e.y, e.x);
			} else {
				w = new Curses.Window(e.nlines, e.ncols, e.y, e.x);
			}

			if (decorated) {
				decoration = decoration ?? GFX.default_decoration;
				this.decor_win = (owned) w;
				this.canvas = decor_win.derwin(e.nlines - 2, e.ncols - 2, 1, 1);
				GFX.decorate_window(this.decor_win, e, this.decoration);
			} else {
				this.canvas = (owned) w;
			}
		}

		public Window create_subwindow (
			WindowExtents e,
			bool decorated,
			WindowDecoration? d = null
		) {
			UI.Window w = new Window(e, decorated, d, canvas);
			subwindows.add(w);
			return w;
		}

		public void add_subwindow (UI.Window w) {
			subwindows.add(w);
		}

		public void erase () {
			if (is_subwindow && decorated) {
				GFX.decorate_window(decor_win, extents, decoration);
			}
			GFX.fill_bg(canvas, extents, decoration.bg);
		}

		public void mvaddstr(int y, int x, string s) {
			canvas.mvaddstr(y, x, s);
		}

		public void mvaddch(int y, int x, unichar ch) {
			canvas.mvaddch(y, x, ch);
		}

		public void cprintw(ColorPair p, string s) {
			GFX.set_color_pair(canvas, p);
			canvas.printw(s);
		}

		public void mvcprintw(int y, int x, ColorPair p, string s) {
			GFX.set_color_pair(canvas, p);
			canvas.mvprintw(y, x, s);
		}

		public void printw(string s, ...) {
			GFX.set_color_pair(canvas, decoration.bg);
			canvas.printw(s.vprintf(va_list()));
		}

		public void mvprintw(int y, int x, string s) {
			GFX.set_color_pair(canvas, decoration.bg);
			canvas.mvprintw(y, x, s);
		}

		public void pretty_print(int y, string s,
			TextAlignment t = TextAlignment.LEFT,
			TextAttribute a = 0,
			ColorPair cp = {-1, -1}
		) {
			int x, maxcols = extents.ncols - 2;
			string ss;

			switch(t) {
				default:
				case TextAlignment.LEFT:
					x = 0;
					if (s.char_count() > maxcols) {
						ss = s.slice(0, maxcols - 1);
					} else {
						ss = s;
					}
					break;
				case TextAlignment.CENTER:
					if (s.char_count() > maxcols) {
						x = 0;
						ss = s.substring((s.char_count() - maxcols) / 2, maxcols);
					} else {
						x = (maxcols - s.char_count()) / 2;
						ss = s;
					}
					break;
				case TextAlignment.RIGHT:
					if (s.length > maxcols) {
						x = 0;
						ss = s.slice(s.length - maxcols, s.length - 1);
					} else {
						x = maxcols - s.char_count();
						ss = s;
					}
					break;
			}

			GFX.set_color_pair(canvas, (cp != ColorPair(-1, -1)) ? cp : decoration.bg);

			GFX.set_attrs(canvas, a);

			canvas.mvprintw(y, x, ss);

			GFX.reset_attrs(canvas, a);
		}

		public virtual void refreshwin (bool output = true) {
			if (decorated) {
				if (output) {
					decor_win.refresh();
					canvas.refresh();
				} else {
					decor_win.noutrefresh();
					canvas.noutrefresh();
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
