const rl = @import("raylib");

pub const MusicTrack = enum {
    menu,
    intro,
    game,
};

pub const AudioManager = struct {
    menuMusic: rl.Music,

    currentTrack: ?MusicTrack,

    clickSound: rl.Sound,
    hoverSound: rl.Sound,

    pub fn init() !AudioManager {
        rl.initAudioDevice();

        return AudioManager{
            .menuMusic = try rl.loadMusicStream("src/assets/music/main_menu.mp3"),
            .clickSound = try rl.loadSound("src/assets/sound/click_sound.mp3"),
            .hoverSound = try rl.loadSound("src/assets/sound/hover_sound.mp3"),
            .currentTrack = null,
        };
    }

    pub fn getMusic(self: *AudioManager, track: MusicTrack) rl.Music {
        return switch (track) {
            .menu => self.menuMusic,
            .intro => self.menuMusic,
            .game => self.menuMusic,
        };
    }

    pub fn playMusic(self: *AudioManager, track: MusicTrack) void {
        if (self.currentTrack) |current| {
            if (current == track) return;
            rl.stopMusicStream(self.getMusic(current));
        }
        rl.playMusicStream(self.getMusic(track));
        self.currentTrack = track;
    }

    pub fn stopMusic(self: *AudioManager) void {
        if (self.currentTrack) |current| {
            rl.stopMusicStream(self.getMusic(current));
            self.currentTrack = null;
        }
    }

    pub fn update(self: *AudioManager) void {
        if (self.currentTrack) |current| {
            rl.updateMusicStream(self.getMusic(current));
        }
    }

    pub fn playClick(self: *AudioManager) void {
        rl.playSound(self.clickSound);
    }

    pub fn playHover(self: *AudioManager) void {
        rl.playSound(self.hoverSound);
    }

    pub fn deinit(self: *AudioManager) void {
        self.stopMusic();
        rl.unloadMusicStream(self.menuMusic);
        rl.unloadSound(self.clickSound);
        rl.unloadSound(self.hoverSound);
        rl.closeAudioDevice();
    }
};
