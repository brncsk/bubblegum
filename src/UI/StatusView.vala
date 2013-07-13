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
					"", "",
					"", "",
					" ", " ",
					"", "",
					
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
					TextAlignment.CENTER, 0, ColorPair(85, 108));

				Timeout.add(5000, () => {
					request_update();
					Timeout.add(100, () => {
						request_update();
						return true;
					});
					return false;
				});

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
	
			if (App.player.current_position != Gst.CLOCK_TIME_NONE) {

				string se = "" + GFX.nfillu(current_extents.ncols - 4, '') + "";
				string sf = "" + GFX.nfillu(current_extents.ncols - 4, '') + "";

				window.pretty_print(3,
					se,
					TextAlignment.CENTER,
					TextAttribute.BOLD,
					ColorPair(158, 108)
				);



				int len =
					"".length * 
					(int) (
						((double) (current_extents.ncols - 2)) *
						((double) App.player.current_position) /
						((double) App.player.current_duration)
					);

				window.pretty_print(3, 
					sf.substring(0, len),
					TextAlignment.LEFT,
					TextAttribute.BOLD,
					ColorPair(158, 108)
				);

				window.pretty_print(4, 
					GFX.format_gst_mmss(App.player.current_position),
					TextAlignment.LEFT,
					TextAttribute.BOLD,
					ColorPair(158, 108)
				);

				window.pretty_print(4, 
					GFX.format_gst_mmss(App.player.current_duration),
					TextAlignment.RIGHT,
					TextAttribute.BOLD,
					ColorPair(158, 108)
				);
			}
		}
	}
}

