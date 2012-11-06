using GLib;
using Gee;

using Curses;

using Bubblegum.Core;
using Bubblegum.Models;

namespace Bubblegum.UI
{
	public class StatusView : View
	{
		private bool first_update = true;

		construct {
			pref_extents.height.q = 8;
			decor = new WindowDecoration (
					"", "",
					"", "",
					" ", " ",
					"", "",
					
					" Bubblegum! ",
					TextAttribute.BOLD,

					{108, -1}, {-1, 108},
					{204, -1}, {108, -1},
					{59, 108}
			);
		}

		public override void init () {
			App.playback_manager.media_changed.connect((m) => { request_update(); });
			App.playback_manager.playback_state_changed.connect((s) => { request_update(); });
			App.playback_manager.repeat_mode_changed.connect((s) => { request_update(); });
			App.playback_manager.shuffle_changed.connect((s) => { request_update(); });
		}

		protected override void update () {
			if (first_update) {
				first_update = false;

				window.pretty_print(1, "┏┓ ╻ ╻┏┓ ┏┓ ╻  ┏━╸┏━╸╻ ╻┏┳┓╻",
					TextAlignment.CENTER, TextAttribute.BOLD, ColorPair(158, 108));

				window.pretty_print(2, "┣┻┓┃ ┃┣┻┓┣┻┓┃  ┣╸ ┃╺┓┃ ┃┃┃┃╹",
					TextAlignment.CENTER, TextAttribute.BOLD, ColorPair(158, 108));
				
				window.pretty_print(3, "┗━┛┗━┛┗━┛┗━┛┗━╸┗━╸┗━┛┗━┛╹ ╹╹",
					TextAlignment.CENTER, TextAttribute.BOLD, ColorPair(158, 108));

				window.pretty_print(5, Resources.APP_VERSION,
					TextAlignment.CENTER, 0, ColorPair(36, 108));

				Timeout.add(5000, () => { request_update(); return false; });

				return;
			}

			window.pretty_print(0, "[REPEAT]",
				TextAlignment.RIGHT,
				App.playback_manager.repeat_mode ? TextAttribute.BOLD : 0,
				App.playback_manager.repeat_mode ? ColorPair(158, 108) : ColorPair(59, 108)
			);

			window.pretty_print(0, "[SHUFFLE]",
				TextAlignment.LEFT,
				App.playback_manager.shuffle ? TextAttribute.BOLD : 0,
				App.playback_manager.shuffle ? ColorPair(158, 108) : ColorPair(59, 108)
			);

			if (App.playback_manager.current_media != null) {
				window.pretty_print(2,
					App.playback_manager.current_media.string_repr(Config.title_format),
					TextAlignment.CENTER,
					TextAttribute.BOLD,
					ColorPair(158, 108)
				);
			}
		
		}
	}
}

