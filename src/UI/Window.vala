using GLib;

namespace Bubblegum.UI {
	
	public class Window {

		public Curses.Window c { get { return _canvas; } }
		public WindowExtents extents { get { return _extents; } }

		private Curses.Window _win;
		private Curses.Window _canvas;
		private WindowExtents _extents;

		private bool is_subwindow = false;

		public bool decorated = true;
		public WindowDecoration? decor = GFX.default_decoration;

		public Window (WindowExtents e, bool decorated = true, WindowDecoration? d = null) {
			this.decorated = decorated;
			this._extents = e;

			if (d != null) {
				decor = d;
			}

			if (decorated) {
				_win = new Curses.Window (e.nlines, e.ncols, e.y, e.x);
				_win.clearok(true);

				_canvas = _win.derwin(e.nlines - 2, e.ncols - 2, 1, 1);

				GFX.decorate_window(_win, e, d);
				_win.refresh();
			} else {
				_canvas = new Curses.Window (e.nlines, e.ncols, e.y, e.x);
				_canvas.refresh();
			}
		}

		private Window.subwindow (UI.Window w, WindowExtents e, bool decorated, WindowDecoration? d =
		null) {
			this.decorated = decorated;
			this.is_subwindow = true;
			this._extents = e;

			if (d != null) {
				decor = d;
			}

			if (decorated) {
				_win = w.c.derwin(e.nlines, e.ncols, e.y, e.x);
				_win.clearok(true);

				_canvas = _win.derwin(e.nlines - 2, e.ncols - 2, 1, 1);
				_canvas.clearok(true);

				GFX.decorate_window(_win, e, d);
				_win.refresh();
			} else {
				_canvas = new Curses.Window (e.nlines, e.ncols, e.y, e.x);
				_canvas.clearok(true);
				_canvas.refresh();
			}
		}

		public Window create_subwindow (WindowExtents e, bool decorated, WindowDecoration? d = null) {
			return new Window.subwindow(this, e, decorated, d);
		}

		public void erase () {
			if (is_subwindow && decorated) {
				GFX.decorate_window(_win, _extents, decor);
			}
			GFX.fill_bg(_canvas, _extents, decor.bg);
		}

		public void mvaddstr(int y, int x, string s) {
			_canvas.mvaddstr(y, x, s);
		}

		public void mvaddch(int y, int x, unichar ch) {
			_canvas.mvaddch(y, x, ch);
		}

		public void cprintw(ColorPair p, string s) {
			GFX.set_color_pair(_canvas, p);
			_canvas.printw(s);
		}

		public void mvcprintw(int y, int x, ColorPair p, string s) {
			GFX.set_color_pair(_canvas, p);
			_canvas.mvprintw(y, x, s);
		}

		public void printw(string s, ...) {
			GFX.set_color_pair(_canvas, decor.bg);
			_canvas.printw(s.vprintf(va_list()));
		}

		public void mvprintw(int y, int x, string s) {
			GFX.set_color_pair(_canvas, decor.bg);
			_canvas.mvprintw(y, x, s);
		}

		public void pretty_print(int y, string s,
			TextAlignment t = TextAlignment.LEFT,
			TextAttribute a = 0,
			ColorPair cp = {-1, -1}
		) {
			int x, maxcols = _extents.ncols - 2;
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

			GFX.set_color_pair(_canvas, (cp != ColorPair(-1, -1)) ? cp : decor.bg);

			GFX.set_attrs(_canvas, a);

			_canvas.mvprintw(y, x, ss);

			GFX.reset_attrs(_canvas, a);
		}

		public void refresh () {
			if (decorated) {
				_win.redrawwin();
				_win.refresh();
			} else {
				_canvas.redrawwin();
				_canvas.refresh();
			}
		}
	}
}
