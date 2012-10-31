using GLib;
using Gee;

using Curses;

using Bubblegum.Core;
using Bubblegum.Models;

namespace Bubblegum.UI
{
	public class StatusView : View
	{
		public override void init (WindowExtents e) {
			decor = new WindowDecoration (
					"", "",
					"", "",
					" ", " ",
					"", "",
					
					" Welcome to Bubblegum pre-alpha! ",
					TextAttribute.BOLD,

					{108, -1}, {-1, 108},
					{204, -1}, {108, -1},
					{59, 108}
			);

			base.init (e);

			App.playback_manager.media_changed.connect((m) => { request_update(); });
			App.playback_manager.playback_state_changed.connect((s) => { request_update(); });
			App.playback_manager.repeat_mode_changed.connect((s) => { request_update(); });
			App.playback_manager.shuffle_changed.connect((s) => { request_update(); });
		}

		protected override void update () {
			canvas.pretty_print(0, "[REPEAT]",
				TextAlignment.RIGHT,
				App.playback_manager.repeat_mode ? TextAttribute.BOLD : 0,
				App.playback_manager.repeat_mode ? ColorPair(158, 108) : ColorPair(59, 108)
			);

			canvas.pretty_print(0, "[SHUFFLE]",
				TextAlignment.LEFT,
				App.playback_manager.shuffle ? TextAttribute.BOLD : 0,
				App.playback_manager.shuffle ? ColorPair(158, 108) : ColorPair(59, 108)
			);
				
			if (App.playback_manager.current_media != null) {
				canvas.pretty_print(2,
					App.playback_manager.current_media.string_repr(Config.title_format),
					TextAlignment.CENTER,
					TextAttribute.BOLD,
					ColorPair(158, 108)
				);
			}
		
		}
	}
}

