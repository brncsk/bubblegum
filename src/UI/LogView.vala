using GLib;

using Bubblegum.Core;
using Bubblegum.Models;

namespace Bubblegum.UI
{
	private const string PLAYLIST_URI = "file:///data/music/test.pls";

	public class LogView : View
	{
		public override void init (WindowExtents e) {
			decor.c = { 239, -1 };
			decor.b = { 239, -1 };
			decor.bg = { 245, -1 };
			decor.tb = { 239, -1 };
			decor.title = "Event log";
			base.init(e);
			
			App.event_log.connect((m) => {
				canvas.printw("%s\n", m);
				refresh();
			});
		}

		public override void update () {
		}

	}

}
