using GLib;
using Gee;

namespace Bubblegum.UI {

	public errordomain LayoutError
	{
		TERMINAL_TOO_SMALL
	}

	public enum LayoutUnit { PERCENT, ABSOLUTE }

	public class LayoutExtent : Object
	{

		public int q;
		public LayoutUnit u;

		public LayoutExtent (int q, LayoutUnit u) {
			this.q = q; this.u = u;
		}

		public LayoutExtent.DONT_CARE () {
			this.q = -1; this.u = LayoutUnit.ABSOLUTE;
		}

		public LayoutExtent.ZERO () {
			this.q = 0; this.u = LayoutUnit.ABSOLUTE;
		}

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

	public class LayoutExtentPair : Object
	{
		public LayoutExtent height;
		public LayoutExtent width;

		public LayoutExtentPair (LayoutExtent height, LayoutExtent width) {
			this.height = height; this.width = width;
		}

		public LayoutExtentPair.DONT_CARE () {
			this.height = new LayoutExtent.DONT_CARE();
			this.width = new LayoutExtent.DONT_CARE();
		}

		public LayoutExtentPair.ZERO () {
			this.height = new LayoutExtent.ZERO();
			this.width = new LayoutExtent.ZERO();
		}
	}
	
	public struct WindowExtents
	{
		public int nlines;
		public int ncols;
		public int y;
		public int x;
	}

	public interface LayoutComponent : GLib.Object
	{
		public abstract LayoutExtentPair get_minimum_extents ();
		public abstract LayoutExtentPair get_preferred_extents ();
		public abstract LayoutExtentPair get_maximum_extents ();

		public abstract void init ();

		public abstract void compute_layout (WindowExtents w) throws LayoutError;
	}

	public abstract class LayoutContainer : GLib.Object, LayoutComponent
	{
		protected LinkedList<LayoutComponent> children = new LinkedList<LayoutComponent>();		

		public virtual LayoutExtentPair get_preferred_extents () {
			return new LayoutExtentPair.DONT_CARE();
		}
		public virtual LayoutExtentPair get_minimum_extents () {
			return new LayoutExtentPair.DONT_CARE();

		}
		public virtual LayoutExtentPair get_maximum_extents () {
			return new LayoutExtentPair.DONT_CARE();
		}

		public virtual void add_child (LayoutComponent c) {
			children.add(c);
		}

		public virtual void remove_child (LayoutComponent c) {
			children.remove(c);
		}

		public virtual void init () {
			foreach(var child in children) {
				child.init();
			}
		}
		
		public abstract void compute_layout (WindowExtents w) throws LayoutError;
	}

	public class LayoutRoot : LayoutContainer
	{
		public override void compute_layout (WindowExtents w) throws LayoutError {
			children.first().compute_layout(w);
		}
	}

	public class LayoutVBox : LayoutContainer
	{
	
		public override LayoutExtentPair get_minimum_extents () {
			LayoutExtentPair min_extents = new LayoutExtentPair.ZERO();

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

		public override void compute_layout (WindowExtents w) throws LayoutError {
			LayoutExtent min, pref, max;

			int height;
			int remaining = w.nlines;
			bool enable_flex = false;
			int padding = this.get_data<int?>("_layout_padding") ?? 0;
			int spacing = this.get_data<int?>("_layout_spacing") ?? 0;
			
			foreach (var child in children) {
				bool is_flexible;
				min = child.get_minimum_extents().height;
				pref = child.get_preferred_extents().height;

				child.set_data<int?>("_layout_ncols", w.ncols);

				if (pref.is_absolute()) {
					height = pref.q;
					is_flexible = false;
				} else if (pref.is_percent()) {
					height = (int) Math.round((pref.q / 100.0) * w.nlines);
					is_flexible = true;
				} else {
					height = min.q;
					is_flexible = true;
				}

				child.set_data<int?>("_layout_nlines", height);
				child.set_data<bool?>("_layout_is_flexible", is_flexible);
				enable_flex |= is_flexible;
				remaining -= height;
			}

			remaining -= padding * children.size;
			remaining -= spacing * (children.size - 1);

			// If we have children willing to change their size and we have some
			// more space to distribute, start optimizing.
			if (enable_flex && remaining != 0) {
				double flex;
				int pot;
				bool grow = remaining > 0;

				App.log("\n****** Begin flexing. ******");
				App.log("w.nlines = %d, remaining = %d", w.nlines, remaining);

				foreach (var child in children) {
					if (child.get_data<bool?>("_layout_is_flexible") == false) {
						continue;
					}

					min = child.get_minimum_extents().height;
					max = child.get_maximum_extents().height;
					height = child.get_data<int?>("_layout_nlines");
					flex = child.get_data<double?>("_layout_flexibility") ?? 1;

					App.log("height = %d, flexibility = %lf", height, flex);

					child.set_data<double?>("_layout_flexibility", grow ? flex : 1 / flex);
					child.set_data<int?>("_layout_flex_potential", grow
						? ((!max.is_dont_care()) ? max.q - height : int.MAX)
						: ((!min.is_dont_care()) ? height - min.q : int.MIN)
					);
				}

				while (remaining != 0) {
					double flex_step = int.MAX;
					double flex_sum = 0;
					double rounding_offset = 0;

					foreach (var child in children) {
						if (child.get_data<bool?>("_layout_is_flexible") == false) {
							continue;
						}

						flex = child.get_data<double?>("_layout_flexibility");
						pot = child.get_data<int?>("_layout_flex_potential");

						App.log("flex = %lf, pot = %d", flex, pot);

						if (pot > 0) {
							flex_sum += flex;
							flex_step = double.min(flex_step, pot / flex);
						}
					}

					if (flex_sum == 0) {
						break;
					}

					flex_step = double.min(remaining, flex_step * flex_sum) / flex_sum;

					App.log("flex_sum = %lf, flex_step = %lf", flex_sum, flex_step);

					foreach (var child in children) {
						if (child.get_data<bool?>("_layout_is_flexible") == false) {
							continue;
						}

						height = child.get_data<int?>("_layout_nlines");
						flex = child.get_data<double?>("_layout_flexibility");
						pot = child.get_data<int?>("_layout_flex_potential");

						App.log("flex = %lf, old height = %d, old pot = %d", flex, height, pot);

						if (pot > 0) {
							int current_offset = int.min(
								remaining,
								int.min(pot, (int) Math.ceil(flex_step * flex))
							);

							rounding_offset += current_offset - flex_step * flex;
							if (rounding_offset >= 1) {
								rounding_offset -= 1;
								current_offset -= 1;
							}

							child.set_data<int?>("_layout_flex_potential", pot - current_offset);

							child.set_data<int?>(
								"_layout_nlines",
								(int) (height + (grow ?  current_offset : -current_offset)
							));

							App.log("new height = %d, new pot = %d", (int) (height + (grow
									?  current_offset
									: -current_offset
								)), (int) (pot - current_offset));

							remaining -= current_offset;
						}
					}
				}
			}

			if(!enable_flex && remaining < 0) {
				throw new LayoutError.TERMINAL_TOO_SMALL("Terminal too small :(.");
			}

			int offset = padding;

			foreach (var child in children) {
				child.compute_layout(WindowExtents() {
					x = w.x + padding,
					y = w.y + offset,
					ncols = w.ncols - (2 * padding),
					nlines = child.get_data<int?>("_layout_nlines")
				});
				offset += child.get_data<int?>("_layout_nlines") + spacing;
				App.log("offset: %d", offset);
			}
		}
	}
}
