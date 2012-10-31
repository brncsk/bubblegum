using GLib;
using Gst;

using Bubblegum.Models;

namespace Bubblegum.Core
{

	public class AudioPlayer : GLib.Object
	{
		public signal void media_tags_changed (MediaItem item);
		public signal void finished_playing ();

		private	Gst.Element playbin;
		private Gst.Bus bus;

		private MediaItem current_media;

		public AudioPlayer () {
			playbin = Gst.ElementFactory.make("playbin2", "playbin");
			bus = playbin.get_bus();
			bus.add_signal_watch();
			bus.message.connect(bus_message);
		}

		~AudioPlayer () {
			playbin.set_state(Gst.State.NULL);
		}


		public void play_item (MediaItem m) {
			current_media = m;

			playbin.set_state(Gst.State.NULL);
			playbin.set_property("uri", m.uri);
			playbin.set_state(Gst.State.PLAYING);
		}

		public void toggle () {
			Gst.State current, pending;
			playbin.get_state(out current, out pending, 1);

			if (current == Gst.State.PLAYING) {
				playbin.set_state(Gst.State.PAUSED);
			} else if (current == Gst.State.PAUSED) {
				playbin.set_state(Gst.State.PLAYING);
			}
		}

		public void stop () {
			playbin.set_state(Gst.State.READY);
		}

		private void bus_message (Gst.Bus b, Message m) {
			switch (m.type) {
				case MessageType.EOS:
					playbin.set_state(Gst.State.NULL);
					finished_playing();
					break;

				case MessageType.TAG:
					Gst.TagList tag_list;
					m.parse_tag(out tag_list);
					current_media.parse_tags(tag_list);
					media_tags_changed(current_media);
					break;
			}
		}

	}

}
