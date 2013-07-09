using Gee;

using Curses;


namespace Bubblegum.UI
{
	public struct ColorPair
	{
		public short fg;
		public short bg;

		public ColorPair(short fg, short bg) {
			this.fg = fg;
			this.bg = bg;
		}

		public static uint hash_func (ColorPair? cp) {
			return (cp != null) ? ((cp.fg << 8) | cp.bg) : 0;
		}
		public static bool equal_func (ColorPair? a, ColorPair? b) {
			return (a != null && b != null) && (a.fg == b.fg) && (a.bg == b.bg);
		}
	}


	public class WindowDecoration
	{
		public string tl; public string tr;
		public string bl; public string br;

		public string h;
		public string v;

		public string tbl;
		public string tbr;

		public string title;
		public TextAttribute ta;

		public ColorPair c;
		public ColorPair b;
		public ColorPair t;
		public ColorPair tb;
		public ColorPair bg;

		public WindowDecoration (
			string tl, string tr,
			string bl, string br,
			string h, string v,
			string tbl, string tbr,

			string title, TextAttribute ta,

			ColorPair c, ColorPair b,
			ColorPair t, ColorPair tb,
			ColorPair bg
		) {
			this.tl = tl; this.tr = tr;
			this.bl = bl; this.br = br;
			this.h = h; this.v = v;
			this.tbl = tbl; this.tbr = tbr;

			this.title = title; this.ta = ta;

			this.c = c; this.b = b;
			this.t = t; this.tb = tb;
			this.bg = bg;
		}
	}

	public enum TextAlignment { LEFT, CENTER, RIGHT }

	[Flags]
	public enum TextAttribute { BOLD, UNDERLINE }

	public abstract class GFX
	{
		[CCode (cname="init_pair")]
		public static extern int init_pair(short pair, short f, short b);

		[CCode (cname="use_default_colors")]
		public static extern int use_default_colors();

		public static WindowDecoration default_decoration; 
		private static HashMap<ColorPair?, short?> pairs;

		public static const short RESERVED_COLORS = 5;

		public static void init () {
			default_decoration = new WindowDecoration(
				"╭", "╮",
				"╰", "╯",
				"─", "│",
				"┤", "├",
				"", 0,
				{Color.WHITE, -1}, {Color.WHITE, -1},
				{Color.WHITE, -1}, {Color.WHITE, -1},
				{Color.WHITE, -1}
			);

			pairs = new HashMap<ColorPair?, short?>(
				(HashFunc<ColorPair?>) ColorPair.hash_func,
				(EqualFunc<ColorPair?>) ColorPair.equal_func,
				Gee.Functions.get_equal_func_for(typeof(short))
			);
		}

		public static string nfillu(size_t length, unichar fill_char) {
			StringBuilder s = new StringBuilder.sized(length);
			for (int x = 0; x < length; x++) {
				s.append_unichar(fill_char);
			}

			return s.str;
		}

		public static void set_colors (Curses.Window w, short fg, short bg) {
			short pair_id = color_pair_id({fg, bg});
			w.bkgdset(Curses.COLOR_PAIR(pair_id));
		}

		public static void set_color_pair(Curses.Window w, ColorPair p) {
			set_colors(w, p.fg, p.bg);
		}

		public static void fill_bg (Curses.Window w, WindowExtents e, ColorPair cp) {
			set_color_pair(w, cp);

			for (int x = 1; x < e.ncols - 1; x++) {
				for (int y = 1; y < e.nlines - 1; y++) {
					w.mvaddch(y, x, ' ');
				}
			}
		}

		public static void set_attrs (Curses.Window w, TextAttribute a) {
			if ((a & TextAttribute.BOLD) > 0) { w.attron(Curses.Attribute.BOLD); }
			if ((a & TextAttribute.UNDERLINE) > 0) { w.attron(Curses.Attribute.UNDERLINE); }
		}

		public static void reset_attrs (Curses.Window w, TextAttribute a) {
			if ((a & TextAttribute.BOLD) > 0) { w.attroff(Curses.Attribute.BOLD); }
			if ((a & TextAttribute.UNDERLINE) > 0) { w.attroff(Curses.Attribute.UNDERLINE); }
		}

		public static short color_pair_id(ColorPair p) {
			short pair_id;
			if (pairs.has_key(p)) {
				pair_id = pairs.get(p);
			} else {
				pair_id = (short) pairs.size + RESERVED_COLORS;

				assert(pair_id < Curses.COLOR_PAIRS);

				App.log("init_pair(%d, %d, %d)", pair_id, p.fg, p.bg);

				init_pair(pair_id, p.fg, p.bg);
				pairs.set({p.fg, p.bg}, pair_id);
			}

			return pair_id;
		}

		public static void decorate_window (
			Curses.Window w, WindowExtents e,
			WindowDecoration? d
		) {
			if(d == null) {
				d = default_decoration;
			}

		// Draw borders.

			set_color_pair(w, d.b);

			for (int x = 1; x < e.ncols - 1; x++) {
				w.mvaddstr(           0, x, d.h);
				w.mvaddstr(e.nlines - 1, x, d.h);
			}

			for (int y = 1; y < e.nlines - 1; y++) {
				w.mvaddstr(y,           0, d.v);
				w.mvaddstr(y, e.ncols - 1, d.v);
			}

		// Draw corners.

			set_color_pair(w, d.c);
				
			w.mvaddstr(0,            0,           d.tl);
			w.mvaddstr(0,            e.ncols - 1, d.tr);
			w.mvaddstr(e.nlines - 1, e.ncols - 1, d.br);
			w.mvaddstr(e.nlines - 1, 0,           d.bl);

		// Draw title bar.

			string title;

			if (d.title.length > 0) {
				int x;

				if (d.title.length > e.ncols - 4) {
					title = d.title.substring(0, e.ncols - 5) + "…";
					x = 2;
				} else {
					title = d.title;
					x = (e.ncols - d.title.length) / 2;
				}

				set_color_pair(w, d.tb);
				w.mvaddstr(0, x - 1, d.tbl);
				w.mvaddstr(0, x + (int) title.char_count(), d.tbr);
				set_color_pair(w, d.t);
				set_attrs(w, d.ta);
				w.mvaddstr(0, x, title);
				reset_attrs(w, d.ta);
			}

		// Fill the background.

			fill_bg(w, e, d.bg);

		}

	}

}
