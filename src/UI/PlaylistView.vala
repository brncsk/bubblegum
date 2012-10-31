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

		public override void init (WindowExtents e) {
			this.decor = new WindowDecoration(
				"", "",
				"", "",
				" ", " ",
				"", "",
				" Playlist ", 0,
				{239, -1}, {-1, 239},
				{250, -1}, {239, -1},
				{-1, 239}
			);

			base.init(e);
			
			WindowExtents oe = { e.nlines - 3, e.ncols - 2, 1, 0 };

			list = canvas.create_subwindow(oe, true, new WindowDecoration (
					"", "",
					"", "",
					" ", " ",
					"", "",
					"", 0,

					{235, 239}, {-1, 235},
					{-1, -1}, {-1, -1},
					{245, 235}
				)
			);
			
			App.playback_manager.playlist_changed.connect((p) => {
				current_playlist = p;
				request_update();
			});

			App.playback_manager.media_changed.connect((m) => {
				current_media = m;
				request_update();
			});

			App.player.media_tags_changed.connect((m) => {
				if (m in current_playlist) {
				}
			});
		}

		protected override void update () {
			int maxlines = current_extents.nlines - 2;
			int current_line = 0;

			list.erase();

			foreach (MediaItem i in current_playlist) {
				
				string tx = i.string_repr(Config.title_format);

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
