PROGRAM = bubblegum
APP_VERSION = 0.13.1

BUILD_DIR = build

ifndef VALAC
VALAC := valac
endif

PACKAGES =   glib-2.0                       \
			 gee-1.0                        \
		     gio-2.0                        \
		     gstreamer-0.10                 \
		     json-glib-1.0

VALAFLAGS =  -g                             \
             --thread                       \
			 --enable-checking              \
			 --target-glib=2.32             \
			 --pkg=curses

VALA_FILES = main.vala                      \
			 Resources.vala                 \
			 App.vala                       \
			                                \
			 Core/EventLog.vala             \
			 Core/Config.vala               \
			 Core/PlaybackManager.vala      \
			 Core/AudioPlayer.vala          \
			                                \
			 Models/MediaItem.vala          \
			 Models/Playlist.vala           \
			                                \
			 UI/Window.vala                 \
			 UI/ScrollableWindow.vala       \
			 UI/View.vala                   \
			 UI/Layout.vala                 \
			 UI/LayoutManager.vala          \
			 UI/InputManager.vala           \
			 UI/GFX.vala                    \
			                                \
			 UI/StatusView.vala             \
			 UI/PlaylistView.vala           \
			 UI/LogView.vala

CFLAGS =     -lncursesw -O2 -g -pipe -w -lm
VALA_CFLAGS  := `pkg-config --cflags $(PACKAGES) gthread-2.0`
VALA_LDFLAGS := `pkg-config --libs $(PACKAGES) gthread-2.0`
VALA_STAMP   := $(BUILD_DIR)/.stamp

EXPANDED_VALA_FILES := $(foreach src,$(VALA_FILES),src/$(src))
EXPANDED_C_FILES := $(foreach file,$(subst src,$(BUILD_DIR),$(EXPANDED_VALA_FILES)),$(file:.vala=.c))
EXPANDED_O_FILES := $(foreach file,$(subst src,$(BUILD_DIR),$(EXPANDED_VALA_FILES)),$(file:.vala=.o))

all: $(PROGRAM)

$(VALA_STAMP):
	@mkdir -p $(BUILD_DIR)
	@$(VALAC) --ccode --directory=$(BUILD_DIR) --basedir=src \
		$(foreach pkg,$(PACKAGES),--pkg=$(pkg)) \
		$(VALAFLAGS) \
		$(EXPANDED_VALA_FILES)
	@touch $@

$(EXPANDED_C_FILES): $(VALA_STAMP)
	@

$(EXPANDED_O_FILES): %.o: %.c Makefile
	@$(CC) -c $(VALA_CFLAGS) $(CFLAGS) -o $@ $<

$(PROGRAM): $(EXPANDED_O_FILES)
	@$(CC) $(EXPANDED_O_FILES) $(CFLAGS) $(VALA_LDFLAGS) -o $@

clean:
	@rm -f $(EXPANDED_O_FILES)
	@rm -f $(EXPANDED_C_FILES)
	@rm -f $(VALA_STAMP)
	@rm -f $(PROGRAM)
