using Curses;

namespace Bubblegum.UI
{

	public class ScrollableWindow : Window
	{
		public ScrollableWindow(int nlines, int ncols, int begin_y, int begin_x) {
			base(nlines, ncols, begin_y, begin_x);
		}
	}

}
