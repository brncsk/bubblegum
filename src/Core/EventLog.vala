using GLib;

namespace Bubblegum.Core
{	
	public class EventLog : GLib.Object
	{
		public delegate void MessageDispatcher(string s);
		public signal void message(string s);
		
		private const string LOG_PATH = "bubblegum.log";
		private StringBuilder log;

		public EventLog () {
			log = new StringBuilder();
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
