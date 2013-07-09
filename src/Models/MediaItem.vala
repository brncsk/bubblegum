using GLib;
using Gee;
using Gst;

using Bubblegum.Core;

namespace Bubblegum.Models
{

	public class MediaItem : GLib.Object
	{
		private struct TagType { string tag; string fmt; string type; }

		private static const TagType[] TAG_TYPES = {
			{ "artist", "%A", "string" },
			{ "title", "%T", "string" },
			{ "notex", "%N", "string" }
		};

		public string? title {
			get {
				return tags.has_key("title") ? tags["title"].get_string() : null;
			}
		}

		public string? artist {
			get {
				return tags.has_key("artist") ? tags["artist"].get_string() : null;
			}
		}

		private HashMap<string, Gst.Value?> tags = new HashMap<string, Gst.Value?>();

		private string _uri;
		private bool _is_playing;

		public bool is_playing {
			get { return _is_playing; }
		}

		public string uri {
			get { return _uri; }
		}

		public static MediaItem? from_uri (string uri) {
			File f = File.new_for_uri(uri);

			if(!f.query_exists()) {
				return null;
			}

			MediaItem m = new MediaItem();
			m._uri = uri;

			return m;
		}

		public void parse_tags (Gst.TagList tag_list) {


			tag_list.foreach((l, t) => {
				if (t != null) {
					Gst.Value v;
					TagList.copy_value(out v, l, t);
					tags[t] = v;
				}
			});
		}

		public string string_repr (Iterable<string> fmt) {
			foreach (string f in fmt) {
				bool valid = true;
				foreach (TagType t in TAG_TYPES) {
					if (f.index_of(t.fmt) >= 0) {
						if (tags.has_key(t.tag)) {
							switch (t.type) {
								case "string":
									f = f.replace(t.fmt, tags[t.tag].get_string());
									break;
							}
						} else {
							valid = false;
							break;
						}
					}
				}
				if (valid == true) {
					return f;
				}
			}

			return "???";
		}
	}
}
