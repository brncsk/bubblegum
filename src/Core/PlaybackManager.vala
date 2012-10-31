using GLib;

using Bubblegum.Models;

namespace Bubblegum.Core
{
	public enum PlaybackState {
		PLAYING, PAUSED, STOPPED
	}

	public class PlaybackManager
	{
		public signal void playback_state_changed (PlaybackState state);
		public signal void media_changed (MediaItem? item);

		public signal void playlist_changed (Playlist playlist);

		public signal void shuffle_changed (bool shuffle);
		public signal void repeat_mode_changed (bool repeat_mode);

		public PlaybackState playback_state {
			get {
				return _playback_state;
			}
		}
		
		public bool shuffle {
			get {
				return _shuffle;
			}
			set {
				_shuffle = value;
				if (_current_playlist != null) {
					_current_playlist.shuffle = value;
				}
				shuffle_changed(value);
				App.log("Shuffle %s.", value ? "ON" : "OFF");
			}
		}

		public bool repeat_mode {
			get {
				return _repeat_mode;
			}
			set {
				_repeat_mode = value;
				if (_current_playlist != null) {
					_current_playlist.repeat_mode = value
						? RepeatMode.REPEAT_ALL
						: RepeatMode.REPEAT_OFF;
				}
				repeat_mode_changed(value);
				App.log("Repeat %s.", value ? "ON" : "OFF");
			}
		}

		public Playlist current_playlist {
			get {
				return _current_playlist;
			}
			set {
				_current_playlist = value;
				playlist_changed(_current_playlist);
			}
		}

		public MediaItem current_media {
			get {
				return _current_media;
			}
		}

		private MediaItem _current_media;
		private Playlist _current_playlist;
		private PlaybackState _playback_state = PlaybackState.STOPPED;

		private bool _shuffle = false;
		private bool _repeat_mode = false;

		public PlaybackManager () {
			App.player.finished_playing.connect(() => {
				next();
			});

			media_changed.connect((m) => {
				_current_media = m;
			});
		}

		
		public void previous () {
			MediaItem m;
			if ((m = _current_playlist.previous_item()) != null) {
				App.player.play_item(m);

				if (_playback_state != PlaybackState.PLAYING) {
					_playback_state = PlaybackState.PLAYING;
					playback_state_changed(_playback_state);
				}
			} else {
				App.player.stop();
				_playback_state = PlaybackState.STOPPED;
				playback_state_changed(_playback_state);
			}

			media_changed(m);
		}

		public void next () {
			MediaItem m;
			if ((m = _current_playlist.next_item()) != null) {
				App.player.play_item(m);

				if (_playback_state != PlaybackState.PLAYING) {
					_playback_state = PlaybackState.PLAYING;
					playback_state_changed(_playback_state);
				}
			} else {
				App.player.stop();
				_playback_state = PlaybackState.STOPPED;
				playback_state_changed(_playback_state);
			}

			media_changed(m);
		}

		public void toggle () {
			if (_playback_state == PlaybackState.STOPPED) {
				return;
			}

			App.player.toggle();
			_playback_state = (_playback_state == PlaybackState.PLAYING)
				? PlaybackState.PAUSED
				: PlaybackState.PLAYING;
			playback_state_changed(_playback_state);
		}

	}
}
