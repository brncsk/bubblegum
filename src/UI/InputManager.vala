using GLib;
using Gee;

namespace Bubblegum.UI
{
	public delegate void InputCallback();

	public class InputDelegateMap : HashMap<uint, InputDelegate>
	{
		protected class InputDelegate
		{
			public InputCallback cb { get; owned set; }
			public InputDelegate (InputCallback cb) { this.cb = cb; }
		}

		public new void set(uint c, InputCallback cb) {
			base.set(c, new InputDelegate(cb));
		}

		public new InputCallback get(uint c) {
			return (InputCallback)(((InputDelegate) base.get(c)).cb);
		}
	}

	public class InputManager : Object
	{		

		private Thread input_thread;
		private bool running = false;

		private InputDelegateMap global_bindings = new InputDelegateMap();
		private InputDelegateMap view_bindings = new InputDelegateMap();

		public InputManager (InputDelegateMap global_bindings)  {
			Curses.curs_set(0);
			Curses.noecho();
			Curses.halfdelay(10);
			Curses.stdscr.keypad(true);

			foreach(uint k in global_bindings.keys) {
				this.global_bindings[k] = global_bindings[k];
			}
			
			App.layout_manager.view_changed.connect(view_changed);

			running = true;

			try {
				input_thread = new Thread<void*>.try("input-thread", this.run_input_thread);
			} catch(Error e) {
				stderr.printf("Failed to create UI thread.");
			}
		}

		private void view_changed (View v) {
			view_bindings.clear();
			var bindings = v.get_bindings();
			foreach(uint k in bindings.keys) {
				view_bindings[k] = bindings[k];
			}
		}

		private void* run_input_thread () {
			
			while (running) {
				uint ch = (uint) Curses.getch();

				if (global_bindings.has_key(ch)) {
					global_bindings[ch]();
				} else if (view_bindings.has_key(ch)) {
					view_bindings[ch]();
				}
			}

			return null;
		}

		public void quit () {
			this.running = false;
		}


	}

}
