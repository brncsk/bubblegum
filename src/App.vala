using GLib;
using Gee;

using Bubblegum.Core;
using Bubblegum.UI;
using Bubblegum.Models;

namespace Bubblegum
{
	public abstract class App : Object
	{
		
		public static LayoutManager layout_manager { get { return _layout_manager; } }
		public static InputManager input_manager { get { return _input_manager; } }
		public static PlaybackManager playback_manager { get { return _playback_manager; } }
		public static AudioPlayer player { get { return _player; } }
		public static EventLog event_log { get { return _event_log; }}

		private static LayoutManager _layout_manager;
		private static InputManager _input_manager;
		private static PlaybackManager _playback_manager;
		private static AudioPlayer _player;
		private static EventLog _event_log;
		
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
			bindings['p'] = _playback_manager.previous;
			bindings['n'] = _playback_manager.next;
			bindings[' '] = _playback_manager.toggle;
			bindings['q'] = quit;
			bindings['S'] = () => { _playback_manager.shuffle = !_playback_manager.shuffle; };
			bindings['R'] = () => { _playback_manager.repeat_mode = !_playback_manager.repeat_mode; };
			bindings[ 9 ] = layout_manager.cycle_views;

			_input_manager = new InputManager(bindings);
			_playback_manager.current_playlist = Config.playlist;

			_layout_manager.run();
	
			mainloop = new MainLoop(null, false);
			mainloop.run();
		}

		public static void log (string s, ...) {
			_event_log.vadd(s, va_list());
		}

		public static void draw_synchronized (SynchronizedLambda d) {
			
			draw_mutex.lock();
			d();
			draw_mutex.unlock();
		}

		public static void quit () {
			_input_manager.quit();
			_layout_manager.quit();
			_event_log.quit();
			mainloop.quit();
		}
	}
}
