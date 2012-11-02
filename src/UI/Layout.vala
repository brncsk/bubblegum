using GLib;
using Gee;

namespace Bubblegum.UI {

	public enum LayoutUnit { PERCENT, ABSOLUTE }

	public struct LayoutExtent
	{
		public static const LayoutExtent DONT_CARE = {-1, LayoutUnit.ABSOLUTE};
		public static const LayoutExtent ZERO = {0, LayoutUnit.ABSOLUTE};

		public int q;
		public LayoutUnit u;

		public bool is_dont_care () {
			return (this.q == -1) && (this.u == LayoutUnit.ABSOLUTE);
		}

		public bool is_absolute () {
			return (this.q > 0) && (this.u == LayoutUnit.ABSOLUTE);
		}

		public bool is_percent () {
			return (this.q > 0) && (this.u == LayoutUnit.PERCENT);
		}
	}

	public struct LayoutExtentStruct
	{
		public LayoutExtent height;
		public LayoutExtent width;
	}

	public interface LayoutComponent : GLib.Object
	{
		public abstract LayoutExtentStruct get_minimum_extents ();
		public abstract LayoutExtentStruct get_preferred_extents ();
		public abstract LayoutExtentStruct get_maximum_extents ();

		public abstract void compute_layout (WindowExtents w);
	}

	public abstract class LayoutContainer : GLib.Object, LayoutComponent
	{
		protected LinkedList<LayoutComponent> children = new LinkedList<LayoutComponent>();		

		public virtual LayoutExtentStruct get_preferred_extents () {
			return { LayoutExtent.DONT_CARE, LayoutExtent.DONT_CARE };
		}
		public virtual LayoutExtentStruct get_minimum_extents () {
			return { LayoutExtent.DONT_CARE, LayoutExtent.DONT_CARE };
		}
		public virtual LayoutExtentStruct get_maximum_extents () {
			return { LayoutExtent.DONT_CARE, LayoutExtent.DONT_CARE };
		}

		public virtual void add_child (LayoutComponent c) {
			children.add(c);
		}

		public virtual void remove_child (LayoutComponent c) {
			children.remove(c);
		}
		
		public abstract void compute_layout (WindowExtents w);
	}

	public class LayoutRoot : LayoutContainer {

		public override void compute_layout (WindowExtents w) {
			children.first().compute_layout(w);
		}

	}

	public class LayoutVBox : LayoutContainer {
	
		public override LayoutExtentStruct get_minimum_extents () {
			LayoutExtentStruct min_extents = {
				LayoutExtent.ZERO,
				LayoutExtent.ZERO
			};

			foreach (var child in children) {
				var ce = child.get_minimum_extents();

				if ((ce.width.u == LayoutUnit.ABSOLUTE) && (ce.width.q > min_extents.width.q)) {
					min_extents.width = ce.width;
				}
				if ((ce.height.u == LayoutUnit.ABSOLUTE)) {
					min_extents.height.q += ce.height.q;
				}
			}

			return min_extents;
		}

		public override void compute_layout (WindowExtents w) {
			LayoutExtent min, max, pref;

			int allocated_height = 0;
			bool enable_flex = false;
			
			foreach (var child in children) {
				int height;
				bool is_flexible;
				min = child.get_minimum_extents().height;
				pref = child.get_preferred_extents().height;

				child.set_data("_layout_ncols", w.ncols);
				child.set_data("_layout_finished", false);

				
				if (pref.is_absolute()) {
					height = pref.q;
					child.set_data("_layout_finished", true);
					is_flexible = false;

				} else if (pref.is_percent()) {
					height = (pref.q * w.nlines);
					is_flexible = true;

				} else {
					height = min.q;
					is_flexible = true;
				}
				
				child.set_data("_layout_nlines", height);
				child.set_data("_layout_is_flexible", (bool) is_flexible);
				enable_flex |= is_flexible;
				allocated_height += height;
			}

			// If we have children willing to change their size and we have some
			// more space to distribute, start optimizing.
			if (enable_flex && allocated_height != w.nlines) {

				bool grow = allocated_height < w.nlines; 
				int remaining = (w.nlines - allocated_height).abs();

				foreach (var child in children) {

					if (child.get_data<bool>("_layout_is_flexible") == false) {
						continue;
					}

					min = child.get_minimum_extents().height;
					max = child.get_maximum_extents().height;
					int height = child.get_data("_layout_nlines");
					int flexibility = child.get_data("_layout_flexibility");

					child.set_data("_layout_flex_potential", grow
						? ((!max.is_dont_care()) ? max.q - height : -1)
						: ((!min.is_dont_care()) ? height - min.q : -1)
					);

					child.set_data("_layout_flexibility", grow
						? flexibility
						: 1 / flexibility);

					child.set_data("_layout_flex_offset", 0);
				}

				while (remaining != 0) {
					int flex_step = int.MAX;
					int flex_sum = 0;
					int flex, offset, pot;

					foreach (var child in children) {
						flex = child.get_data("_layout_flexibility");
						pot = child.get_data("_layout_flex_potential");

						if (pot > 0) {
							flex_sum += flex;
							flex_step = int.min(flex_step, pot / flex);
						}
					}

					if (flex_sum == 0) {
						break;
					}

					flex_step = int.min(remaining, flex_step * flex_sum) / flex_sum;

					var rounding_offset = 0;

					foreach (var child in children) {
						flex = child.get_data("_layout_flexibility");
						offset = child.get_data("_layout_flex_offset");
						pot = child.get_data("_layout_flex_potential");

						if (pot > 0) {
							int current_offset = int.min(
								remaining,
								int.min(pot, (int) Math.ceil(flex_step* flex))
							);

							rounding_offset += current_offset - flex_step * flex;
							if (rounding_offset >= 1) {
								rounding_offset -= 1;
								current_offset -= 1;
							}

							child.set_data("_layout_flex_potential", flex - current_offset);
							child.set_data("_layout_flex_offset", offset + (grow
								?  current_offset
								: -current_offset
							));

							remaining -= current_offset;
						}
					}
				}
			}
		}
	}
}
