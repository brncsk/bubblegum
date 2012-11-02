using GLib;
using Gee;

using Bubblegum.UI;
using Bubblegum.Models;

namespace Bubblegum.Core
{
	errordomain ConfigError
	{
		CONFIG_FORMAT_ERROR,
		CONFIG_LAYOUT_ERROR
	}

	public class Config
	{
		public static LayoutRoot layout_root;
		public static Playlist playlist;
		public static ArrayList<string> title_format;

		private static const string CONFIG_FILE = "./.bubblegumrc";

		private static Json.Parser parser;

		public static void init () {
			title_format = new ArrayList<string>();

			parser = new Json.Parser();

			try {
				parser.load_from_file(CONFIG_FILE);
				fetch_from_json();
			} catch (Error e) {
				App.log("Cannot load configuration from %s: %s.", CONFIG_FILE, e.message);
				App.quit();
			}
		}

		private static void fetch_from_json () {

			try {

				Json.Node root_node = parser.get_root();
				if (root_node.get_node_type() != Json.NodeType.OBJECT) {
					throw new ConfigError.CONFIG_FORMAT_ERROR("Root node is not an object.");
				}

				parse_layout(root_node.get_object());

				Json.Object root = root_node.get_object();

				// TODO We could use some error handling here.

				if(root.has_member("preload_playlist")) {
					playlist = Playlist.from_pls(root.get_string_member("preload_playlist"));
				}

				if(root.has_member("title_format")) {
					title_format = new ArrayList<string>();
					root.get_array_member("title_format").foreach_element((a, i, n) => {
						title_format.add(n.get_string());
					});
				}

			} catch (Error e) {
				App.log("Cannot load configuration from %s: %s", CONFIG_FILE, e.message);
				App.quit();
			}

		}

		private static void parse_layout (Json.Object root) throws ConfigError {

			parse_layout_items_recursive(
				root.get_member("layout"),
				layout_root = new LayoutRoot()
			);

		}

		private static void parse_layout_items_recursive (Json.Node n, LayoutContainer c)
			throws ConfigError {

			if (n.get_node_type() != Json.NodeType.OBJECT) {
				throw new ConfigError.CONFIG_LAYOUT_ERROR("Layout item is not an object.");
			}

			Json.Object o = n.get_object();

			if (!o.has_member("type")) {
				throw new ConfigError.CONFIG_LAYOUT_ERROR("Layout item has no 'type' member.");
			}

			Json.Node name;

			if ((name = o.get_member("type")).get_value_type() != typeof(string)) {
				throw new ConfigError.CONFIG_LAYOUT_ERROR("Layout item has invalid 'type' member.");
			}

			LayoutComponent? component = App.layout_manager.get_component_instance_for_name(
				name.get_string()
			);

			if (component == null) {
				throw new ConfigError.CONFIG_LAYOUT_ERROR(
					"No such layout component: %s.",
					name.get_string()
				);
			}

			Json.Node children;

			foreach(string s in new string[] {"min", "max", "pref"}) {
				Json.Node e;
				Json.Array a;
				string key = s + "_extents";

				App.log("%s: %d", key, o.has_member(key));

				if (o.has_member(key)) {
					if((e = o.get_member("min_extents")).get_node_type() != Json.NodeType.ARRAY) {
						throw new ConfigError.CONFIG_LAYOUT_ERROR("'%s' must be an array.'", key);
					}

					a = e.get_array();

					if(a.get_length() != 2) {
						throw new ConfigError.CONFIG_LAYOUT_ERROR("Extents must have two elements.");
					}

					unowned LayoutExtentStruct extents = LayoutExtentStruct();

					extents.width = layout_extent_try_parse(a.get_element(0));
					extents.height = layout_extent_try_parse(a.get_element(1));

					component.set_data<LayoutExtentStruct *>("_layout_" + key, &extents);

				}
			}

			if (o.has_member("children")) {
				if((children = o.get_member("children")).get_node_type() != Json.NodeType.ARRAY) {
					throw new ConfigError.CONFIG_LAYOUT_ERROR(
						"Layout member 'children' not an array."
					);
				}

				if(!(component is LayoutContainer)) {
					throw new ConfigError.CONFIG_LAYOUT_ERROR(
						"Component '%s' cannot have descendants.", name.get_string()
					);
				}
				
				foreach(Json.Node child in children.get_array().get_elements()) {
					parse_layout_items_recursive(child, (LayoutContainer) component);
				}
			}

			c.add_child(component);
		}

		private static LayoutExtent layout_extent_try_parse (Json.Node n) throws ConfigError {
			if (n.get_value_type() == typeof(string)) {

				if(!n.get_string().has_suffix("%")) {
					throw new ConfigError.CONFIG_LAYOUT_ERROR(
						"Invalid extent value: '%s'.",
						n.get_string()
					);
				}

				uint64 q;
				if (!uint64.try_parse(n.get_string().replace("%",""), out q)) {
					throw new ConfigError.CONFIG_LAYOUT_ERROR(
						"Invalid percent value: '%s'.", 
						n.get_string()
					);
				}

				return LayoutExtent () {
					u = LayoutUnit.PERCENT,
					q = (int) q
				};

			} else {

				return LayoutExtent () {
					u = LayoutUnit.ABSOLUTE,
					q = (int) n.get_int()
				};

			}
		}
////////////////////////////////////////////////////////////////////////////////////////////////////

/*					
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
*/
	}
}

