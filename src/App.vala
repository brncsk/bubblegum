using GLib;
using Gee;

using Bubblegum.Core;
using Bubblegum.UI;
using Bubblegum.Models;

namespace Bubblegum
{
	public abstract class App : Object
	{
		
		public static LayoutManager layout_manager { get; private set; }
		public static InputManager input_manager { get; private set; }
		public static PlaybackManager playback_manager { get; private set; }
		public static AudioPlayer player { get; private set; }
		public static EventLog event_log { get; private set; }

		public delegate void SynchronizedLambda ();
		private static StaticMutex draw_mutex;

		private static MainLoop mainloop;
		private static InputDelegateMap bindings;

		public static void initialize () {
			_event_log = new EventLog();
			_layout_manager = new LayoutManager();
			_player = new AudioPlayer();
			_playback_manager = new PlaybackManager();

			Config.init();
			
			bindings = new InputDelegateMap();
			bindings['p'] = playback_manager.previous;
			bindings['n'] = playback_manager.next;
			bindings[' '] = playback_manager.toggle;
			bindings['q'] = quit;
			bindings['S'] = () => { playback_manager.shuffle = !playback_manager.shuffle; };
			bindings['R'] = () => { playback_manager.repeat_mode = !playback_manager.repeat_mode; };
			bindings[ 9 ] = layout_manager.cycle_views;

			input_manager = new InputManager(bindings);
			playback_manager.current_playlist = Config.playlist;

			layout_manager.run();
	
			mainloop = new MainLoop(null, false);
			mainloop.run();
		}

		public static void log (string s, ...) {
			event_log.vadd(s, va_list());
		}

		public static void draw_synchronized (SynchronizedLambda d) {
			
			draw_mutex.lock();
			d();
			draw_mutex.unlock();
		}

		public static void quit () {
			input_manager.quit();
			layout_manager.quit();
			event_log.quit();
			mainloop.quit();
		}
	}
}
