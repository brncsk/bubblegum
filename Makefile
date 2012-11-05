all:
	@valac \
		-g                            \
		--thread                      \
		--pkg gee-1.0                 \
		--pkg gio-2.0                 \
		--pkg curses                  \
		--pkg gstreamer-0.10          \
		--pkg json-glib-1.0           \
		--target-glib=2.32            \
		-X -lncursesw                 \
		-X -w                         \
		-o bubblegum                  \
		                              \
		src/main.vala                 \
		src/Resources.vala            \
		src/App.vala                  \
		                              \
		src/Core/EventLog.vala        \
		src/Core/Config.vala          \
		src/Core/PlaybackManager.vala \
		src/Core/AudioPlayer.vala     \
		                              \
		src/Models/MediaItem.vala     \
		src/Models/Playlist.vala      \
		                              \
		src/UI/Window.vala            \
		src/UI/View.vala              \
		src/UI/Layout.vala            \
		src/UI/LayoutManager.vala     \
		src/UI/ViewLayout.vala        \
		src/UI/InputManager.vala      \
		src/UI/GFX.vala               \
		                              \
		src/UI/StatusView.vala        \
		src/UI/PlaylistView.vala      \
		src/UI/LogView.vala

run: all
	@clear
	@./bubblegum
	@cat bubblegum.log

