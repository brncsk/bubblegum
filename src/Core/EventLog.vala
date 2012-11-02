using GLib;

namespace Bubblegum.Core
{	
	public class EventLog : GLib.Object
	{
		public delegate void MessageDispatcher(string s);
		public signal void message(string s);
		
		private const string LOG_PATH = "bubblegum.log";
		private const LogLevelFlags level_flags =
			LogLevelFlags.FLAG_FATAL | LogLevelFlags.FLAG_RECURSION |
			LogLevelFlags.LEVEL_ERROR | LogLevelFlags.LEVEL_CRITICAL |
			LogLevelFlags.LEVEL_WARNING | LogLevelFlags.LEVEL_MESSAGE | LogLevelFlags.LEVEL_INFO;
			
		private StringBuilder log;

		public EventLog () {
			log = new StringBuilder();

			Log.set_handler(null, level_flags, (d, l, m) => {
				add(m);
			});
		}

		public new void connect (MessageDispatcher d) {
			message.connect((s) => d(s));
		}

		public void add (string s, ...) {
			vadd (s, va_list());
		}

		public void vadd (string s, va_list v) {
			string m = s.vprintf(v);
			log.append_printf("%s\n", m);
			message(m);	
		}
		
		public void quit () {
			try {
				File.new_for_path(LOG_PATH).replace_contents(
					log.data, null, false, FileCreateFlags.NONE, null, null
				);
			} catch (Error e) {
				stderr.printf("Cannot write log file.");
			}
		}
	}
}
