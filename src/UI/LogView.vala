using GLib;

using Bubblegum.Core;
using Bubblegum.Models;

namespace Bubblegum.UI
{
	public class LogView : View
	{
		construct {
			decor.c = { 239, -1 };
			decor.b = { 239, -1 };
			decor.bg = { 245, -1 };
			decor.tb = { 239, -1 };
			decor.title = "Event log";
		}

		public override void init () {
			App.event_log.connect((m) => {
//				canvas.printw("%s\n", m);
			});
		}

		public override void update () {
		}

	}

}
