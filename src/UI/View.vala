using GLib;
using Gee;

namespace Bubblegum.UI
{
	public abstract class View : LayoutComponent, Object
	{
		protected InputDelegateMap bindings = new InputDelegateMap();

		protected UI.Window window;
		protected WindowExtents current_extents;
		protected WindowDecoration decor = GFX.default_decoration;
		protected bool decorated = true;

		protected LayoutExtentPair min_extents = new LayoutExtentPair(
			new LayoutExtent(3, LayoutUnit.ABSOLUTE),
			new LayoutExtent.DONT_CARE()
		);
		protected LayoutExtentPair pref_extents = new LayoutExtentPair.DONT_CARE();
		protected LayoutExtentPair max_extents = new LayoutExtentPair.DONT_CARE();

		protected abstract void update ();
		
		public LayoutExtentPair get_minimum_extents () { return negotiate_extents("min"); }
		public LayoutExtentPair get_preferred_extents () { return negotiate_extents("pref"); }
		public LayoutExtentPair get_maximum_extents () { return negotiate_extents("max"); }

		private LayoutExtentPair negotiate_extents (string key) {
			LayoutExtent? gobj_width = this.get_data<LayoutExtent>("_layout_" + key + "_width");
			LayoutExtent? gobj_height = this.get_data<LayoutExtent>("_layout_" + key + "_height");

			LayoutExtentPair prop_extents = (key == "min")
				? min_extents
				: (key == "max")
					? max_extents
					: pref_extents;

			if(gobj_width == null && gobj_height == null) {
				return prop_extents;
			}

			return new LayoutExtentPair(
				(gobj_height != null && prop_extents.height.is_dont_care())
					? gobj_height
					: prop_extents.height,

				(gobj_width != null && prop_extents.width.is_dont_care())
					? gobj_width
					: prop_extents.width
			);
		}

		public virtual void compute_layout (WindowExtents e) throws LayoutError {
			current_extents = e;
			window = new UI.Window(e, decorated, decor);
			request_update();
		}

		public abstract void init();

		public InputDelegateMap get_bindings () {
			return bindings;
		}

		public void request_update () {
			App.draw_synchronized(() => {
				window.erase();
				update();
				window.refresh(!App.layout_manager.computing_layout);
			});
		}
	}
}
