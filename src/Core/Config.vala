using GLib;
using Gee;

using Bubblegum.UI;
using Bubblegum.Models;

namespace Bubblegum.Core
{
	public class Config
	{
		public static ViewLayout layout;
		public static Playlist playlist;
		public static ArrayList<string> title_format;

		private static const string CONFIG_FILE = "./.bubblegumrc";

		public static void init () {
			layout = new ViewLayout();
			title_format = new ArrayList<string>();

			var parser = new Json.Parser();

			parser.object_member.connect((o, k) => {
				switch(k) {
					case "layout":
						o.get_array_member("layout").foreach_element((a, i, n) => {
							var lo = n.get_object();

							var e = lo.get_array_member("extents");

							layout.add_item(lo.get_string_member("view_type"), {
								(int) e.get_int_element(0),
								(int) e.get_int_element(1),
								(int) e.get_int_element(2),
								(int) e.get_int_element(3)
							});
						});
						break;
					
					case "preload_playlist":
						playlist = Playlist.from_pls(o.get_string_member("preload_playlist"));
						break;

					case "title_format":
						o.get_array_member("title_format").foreach_element((a, i, n) => {
							title_format.add(n.get_string());
						});
						break;
				}
			});

			try	{
				parser.load_from_file(CONFIG_FILE);
			} catch (Error e) {
				App.log("Cannot load configuration from %s: %s.", CONFIG_FILE, e.message);
				App.quit();
			}
		}
	}
}
