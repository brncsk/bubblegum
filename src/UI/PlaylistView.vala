using GLib;
using Gee;

using Bubblegum.Core;
using Bubblegum.Models;

namespace Bubblegum.UI
{
	public class PlaylistView : View
	{
		
		private Playlist current_playlist;
		private MediaItem current_media;

		private Window list;

		construct {
			decor = new WindowDecoration(
				"", "",
				"", "",
				" ", " ",
				"", "",
				" Playlist ", 0,
				{239, -1}, {-1, 239},
				{250, -1}, {239, -1},
				{-1, 239}
			);
		}

		public override void compute_layout (WindowExtents e) throws LayoutError {
			current_extents = e;
			window = new UI.Window(e, decorated, decor);

			WindowExtents oe = { e.nlines - 3, e.ncols - 2, 1, 0 };
			list = window.create_subwindow(oe, true, new WindowDecoration(
					"", "",
					"", "",
					" ", " ",
					"", "",
					"", 0,

					{235, 239}, {-1, 235},
					{-1, -1}, {-1, -1},
					{245, 235}
				)
			);

			request_update();
		}

		public override void init () {
			App.playback_manager.playlist_changed.connect((p) => {
				current_playlist = p;
				request_update();
			});

			App.playback_manager.media_changed.connect((m) => {
				current_media = m;
				request_update();
			});

			App.player.media_metadata_changed.connect((m) => {
				if (m in current_playlist) {
					request_update();
				}
			});
		}

		protected override void update () {
			int maxlines = current_extents.nlines - 2;
			int current_line = 0;

			list.erase();

			if (current_playlist == null) {
				return;
			}

			foreach (MediaItem i in current_playlist) {
				
				string tx = i.string_repr(Config.title_format);
	
				list.pretty_print(
					current_line, GFX.format_gst_mmss(i.duration),
					TextAlignment.RIGHT,
					(i == current_media) ? TextAttribute.BOLD : 0,
					(i == current_media) ? ColorPair(254, 235) : ColorPair(245, 235)
				);

				list.pretty_print(
					current_line++, tx,
					TextAlignment.LEFT,
					(i == current_media) ? TextAttribute.BOLD : 0,
					(i == current_media) ? ColorPair(254, 235) : ColorPair(245, 235)
				);

				if (current_line >= maxlines) {
					break;
				}
			}
		}
	}
}
