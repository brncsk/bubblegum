using GLib;
using Gst;

namespace Bubblegum {

	public static void main (string[] args) {
		Intl.setlocale(LocaleCategory.ALL, "");
		Gst.init(ref args);
		App.initialize();
	}

}
