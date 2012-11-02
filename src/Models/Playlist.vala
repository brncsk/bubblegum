using GLib;
using Gee;

using Bubblegum.Core;

namespace Bubblegum.Models
{
	public enum RepeatMode
	{
		REPEAT_OFF,
		REPEAT_ONE,
		REPEAT_ALL
	}

	public class Playlist : GLib.Object
	{
		public signal void finished();


		public bool shuffle = false;
		public RepeatMode repeat_mode = RepeatMode.REPEAT_OFF;

		protected HashMap<int, MediaItem> items = new HashMap<int, MediaItem>();

		private LinkedList<int> previous_indices = new LinkedList<int>();
		private LinkedList<int> available_indices = new LinkedList<int>();
		private int current_index = -1;
		private bool playing = false;

		private Playlist () {
			finished.connect(() => {
				playing = false;
				current_index = -1;
				available_indices.clear();
				previous_indices.clear();
			});
		}

		public static Playlist from_uri_list(string[] uris) {
			Playlist p = new Playlist();

			foreach(string uri in uris) {
				MediaItem m;

				if((m = MediaItem.from_uri(uri)) != null) {
					p.items.set(p.items.size, m);
				}
			}

			return p;
		}

		public static Playlist from_media_items (Collection<MediaItem> items) {
			return new Playlist();
		}

		public static Playlist from_file_enumerator (FileEnumerator e) {
			Playlist p = new Playlist();
			FileInfo fi;

			try {
				while ((fi = e.next_file(null)) != null) {
					MediaItem m;

					if ((m = MediaItem.from_uri(fi.get_name())) != null) {
						p.items.set(p.items.size, m);
					}
				}
			} catch (Error e) {
				
			}

			return p;
		}

		public static Playlist? from_pls (string pfn){
			Playlist p = new Playlist();
			File f = File.new_for_uri(pfn);

			if (!f.query_exists()) {
				App.log("Playlist file not found.");
				return null;
			}

			try {
				DataInputStream dis = new DataInputStream(f.read());
				string line;

				while ((line = dis.read_line(null)) != null) {
					if (line.has_prefix("File")) {
						MediaItem m;
						string scheme;
						string fn = line.split("=", 2)[1];

						// There might be files with relative paths
					
						if ((scheme = Uri.parse_scheme(fn)) == null) {
							if (!Path.is_absolute(fn)) {
								fn = Path.build_filename(
									Path.get_dirname(pfn),
									fn
								);
							}
						}

						if ((m = MediaItem.from_uri(fn)) != null) {
							p.items.set(p.items.size, m);
						}
					}
				}
			} catch {
			}

			return p;
		}

		public Iterator<MediaItem> iterator () {
			return items.values.read_only_view.iterator();
		}

		public bool contains (MediaItem i) {
			return items.values.contains(i);
		}

		public MediaItem? previous_item () {
			if (!playing) {
				return null;
			}

			if (items.size == 0) {
				finished();
				return null;
			}

			if (shuffle) {
				
				if (previous_indices.size == 0) {
					finished();
					return null;
				}

				if (current_index != -1) {
					available_indices.add(current_index);
				}

				current_index = previous_indices[previous_indices.size - 1];
				previous_indices.remove(current_index);

				return items[current_index];

			} else {

				if (current_index == 0) {
					if (repeat_mode == RepeatMode.REPEAT_ALL) {
						return items[current_index = (items.size - 1)];
					} else {
						finished();
						return null;
					}
				}

				return items[--current_index];

			}
		}

		public MediaItem? next_item () {
			if (items.size == 0) {
				finished();
				return null;
			}
			
			if (!playing) {
				playing = true;
			}

			if (shuffle) {

				if (available_indices.size == 0) {
					if (current_index == -1 || repeat_mode == RepeatMode.REPEAT_ALL) {
						foreach (int k in items.keys) {
							available_indices.add(k);
						}
					} else {
						finished();
						return null;
					}
				}

				if (current_index != -1) {
					previous_indices.add(current_index);
				}

				int rand_index = Random.int_range(0, available_indices.size);

				current_index = (int) available_indices[rand_index];
				available_indices.remove(current_index);

				return items[current_index];

			} else {

				if (current_index == (items.size - 1)) {
					if (repeat_mode == RepeatMode.REPEAT_ALL) {
						return items[current_index = 0];
					} else {
						finished();
						return null;
					}
				}

				return items[++current_index];

			}
		}

/*		private void debug_status () {
			App.log("  Current: %d", current_index);

			StringBuilder sb = new StringBuilder("  Available: ");
			foreach(int x in available_indices) {
				sb.append_printf("%d, ", x);
			}

			sb.append("\n  Previous: ");

			foreach(int x in previous_indices) {
				sb.append_printf("%d, ", x);
			}

			App.log("%s", sb.str);
		}
*/
	}
}
