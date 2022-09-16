TARGET		:= Doom64EX
TITLE		:= DOOM64EX1

LIBS = -lfluidsynth -lSDL2 -lSDL2_net -lvitaGL -lvitashark -lSceShaccCgExt -ltaihen_stub -lSceShaccCg_stub -lfreetype \
	-lvorbisfile -lvorbis -logg  -lspeexdsp -lmpg123 -lSceCommonDialog_stub -lSceAudio_stub -lSceLibKernel_stub \
	-lpthread -lmathneon -lSceNet_stub -lSceNetCtl_stub -lpng -lSceDisplay_stub -lSceGxm_stub \
	-lSceSysmodule_stub -lSceCtrl_stub -lSceTouch_stub -lSceMotion_stub -lm -lSceAppMgr_stub \
	-lSceAppUtil_stub -lScePgf_stub -ljpeg -lSceRtc_stub -lScePower_stub -lcurl -lssl -lcrypto -lz \
	-lSceKernelDmacMgr_stub -lSceHid_stub -lSceAudioIn_stub -lSceIme_stub

COMMON_OBJS = \
	src/engine/wadgen/deflate-N64.o \
	src/engine/wadgen/gfx.o \
	src/engine/wadgen/level.o \
	src/engine/wadgen/png.o \
	src/engine/wadgen/rom.o \
	src/engine/wadgen/sndfont.o \
	src/engine/wadgen/sound.o \
	src/engine/wadgen/sprite.o \
	src/engine/wadgen/texture.o \
	src/engine/wadgen/wad.o \
	src/engine/wadgen/wadgen.o \
	src/engine/system/i_cpu_posix.o \
	src/engine/App.o \
	src/engine/Globals.o \
	src/engine/automap/am_draw.o \
	src/engine/automap/am_map.o \
	src/engine/common/info.o \
	src/engine/common/md5.o \
	src/engine/common/tables.o \
	src/engine/common/Property.o \
	src/engine/console/con_console.o \
	src/engine/doom_main/d_devstat.o \
	src/engine/doom_main/d_main.o \
	src/engine/doom_main/d_net.o \
	src/engine/finale/f_finale.o \
	src/engine/finale/in_stuff.o \
	src/engine/fmt/format.o \
	src/engine/fmt/ostream.o \
	src/engine/game/g_actions.o \
	src/engine/game/g_demo.o \
	src/engine/game/g_game.o \
	src/engine/game/g_settings.o \
	src/engine/gfx/Image.o \
	src/engine/gfx/PngImage.o \
	src/engine/gfx/DoomImage.o \
	src/engine/gfx/Pixel.o \
	src/engine/intermission/wi_stuff.o \
	src/engine/misc/m_cheat.o \
	src/engine/misc/m_fixed.o \
	src/engine/misc/m_keys.o \
	src/engine/misc/m_menu.o \
	src/engine/misc/m_misc.o \
	src/engine/misc/m_password.o \
	src/engine/misc/m_random.o \
	src/engine/misc/m_shift.o \
	src/engine/net/net_client.o \
	src/engine/net/net_common.o \
	src/engine/net/net_dedicated.o \
	src/engine/net/net_io.o \
	src/engine/net/net_loop.o \
	src/engine/net/net_packet.o \
	src/engine/net/net_query.o \
	src/engine/net/net_sdl.o \
	src/engine/net/net_server.o \
	src/engine/net/net_structrw.o \
	src/engine/opengl/dgl.o \
	src/engine/opengl/gl_draw.o \
	src/engine/opengl/gl_main.o \
	src/engine/opengl/gl_texture.o \
	src/engine/opengl/glad.o \
	src/engine/parser/sc_main.o \
	src/engine/playloop/p_ceilng.o \
	src/engine/playloop/p_doors.o \
	src/engine/playloop/p_enemy.o \
	src/engine/playloop/p_floor.o \
	src/engine/playloop/p_inter.o \
	src/engine/playloop/p_lights.o \
	src/engine/playloop/p_macros.o \
	src/engine/playloop/p_map.o \
	src/engine/playloop/p_maputl.o \
	src/engine/playloop/p_mobj.o \
	src/engine/playloop/p_plats.o \
	src/engine/playloop/p_pspr.o \
	src/engine/playloop/p_saveg.o \
	src/engine/playloop/p_setup.o \
	src/engine/playloop/p_sight.o \
	src/engine/playloop/p_spec.o \
	src/engine/playloop/p_switch.o \
	src/engine/playloop/p_telept.o \
	src/engine/playloop/p_tick.o \
	src/engine/playloop/p_user.o \
	src/engine/playloop/Map.o \
	src/engine/renderer/r_bsp.o \
	src/engine/renderer/r_clipper.o \
	src/engine/renderer/r_drawlist.o \
	src/engine/renderer/r_lights.o \
	src/engine/renderer/r_main.o \
	src/engine/renderer/r_scene.o \
	src/engine/renderer/r_sky.o \
	src/engine/renderer/r_things.o \
	src/engine/renderer/r_wipe.o \
	src/engine/sound/s_sound.o \
	src/engine/statusbar/st_stuff.o \
	src/engine/system/i_audio.o \
	src/engine/system/i_main.o \
	src/engine/system/i_png.o \
	src/engine/system/i_system.o \
	src/engine/system/i_video.o \
	src/engine/system/SdlVideo.o \
	src/engine/wad/Wad.o \
	src/engine/wad/DoomWad.o \
	src/engine/wad/RomWad.o \
	src/engine/wad/ZipWad.o \
	src/engine/zone/z_zone.o

PREFIX  = arm-vita-eabi
CXX      = $(PREFIX)-g++
CXXFLAGS  = -Wl,-q -fsigned-char -O3 -g -fno-short-enums -mtune=cortex-a9 -mfpu=neon -I$(VITASDK)/$(PREFIX)/include/SDL2 -fno-optimize-sibling-calls \
	-Iinclude -Isrc/engine -Isrc/engine/automap -Isrc/engine/common -Isrc/engine/console -Isrc/engine/doom_main -Isrc/engine/finale \
	-Isrc/engine/fmt -Isrc/engine/game -Isrc/engine/gfx -Isrc/engine/intermission -Isrc/engine/misc -Isrc/engine/net -Isrc/engine/opengl \
	-Isrc/engine/parser -Isrc/engine/playloop -Isrc/engine/renderer -Isrc/engine/sound -Isrc/engine/statusbar -Isrc/engine/system \
	-Isrc/engine/wadgen -Isrc/engine/zone

ASFLAGS = $(CFLAGS)

all: $(TARGET).vpk

$(TARGET).vpk: $(TARGET).velf
	vita-make-fself -c -s $< build/eboot.bin
	vita-mksfoex -s TITLE_ID=$(TITLE) -d ATTRIBUTE2=12 "Doom64EX" build/sce_sys/param.sfo
	vita-pack-vpk -s build/sce_sys/param.sfo -b build/eboot.bin \
		--add build/sce_sys/icon0.png=sce_sys/icon0.png \
		--add build/sce_sys/pic0.png=sce_sys/pic0.png \
		--add build/sce_sys/bg.png=sce_sys/livearea/contents/bg.png \
		--add build/sce_sys/startup.png=sce_sys/livearea/contents/startup.png \
		--add build/sce_sys/template.xml=sce_sys/livearea/contents/template.xml \
		Doom64EX.vpk
	
%.velf: %.elf
	cp $< $<.unstripped.elf
	$(PREFIX)-strip -g $<
	vita-elf-create $< $@

$(TARGET).elf: $(COMMON_OBJS)
	$(CXX) $(CXXFLAGS) $^ $(LIBS) -o $@
	
%.o: %.cc
	$(CXX) $(CXXFLAGS) -c $^ -o $@

clean:
	@rm -rf $(TARGET).velf $(TARGET).elf $(COMMON_OBJS) $(TARGET).elf.unstripped.elf $(TARGET).vpk build/eboot.bin build/sce_sys/param.sfo
