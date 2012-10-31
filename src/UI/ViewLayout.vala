using GLib;
using Gee;

namespace Bubblegum.UI
{
	public struct WindowExtents
	{
		public int nlines;
		public int ncols;
		public int y;
		public int x;

		public string to_string () {
			return "(%d, %d, %d, %d)".printf(nlines, ncols, y, x);
		}
	}

	public class ViewLayoutItem : Object
	{
		public string type;
		public View view;
		public WindowExtents extents;

		public ViewLayoutItem (string type, WindowExtents extents) {
			this.type = type;
			this.extents = extents;
		}
	}

	public class ViewLayout : Object
	{
		public LinkedList<ViewLayoutItem?> items = new LinkedList<ViewLayoutItem?>();

		public ViewLayout () { }

		public void add_item (string t, WindowExtents e) {
			items.add(new ViewLayoutItem(t, e));
		}
	}
}
