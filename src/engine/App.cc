#include <map>
#include <fstream>
#include <imp/App>
#include <imp/Wad>
#include <sys/stat.h>

#ifdef __vita__
#include <vitasdk.h>
#include <vitaGL.h>
extern "C" {
int _newlib_heap_size_user = 200 * 1024 * 1024;
};

void early_fatal_error(const char *msg) {
	vglInit(0);
	SceMsgDialogUserMessageParam msg_param;
	sceClibMemset(&msg_param, 0, sizeof(SceMsgDialogUserMessageParam));
	msg_param.buttonType = SCE_MSG_DIALOG_BUTTON_TYPE_OK;
	msg_param.msg = (const SceChar8*)msg;
	SceMsgDialogParam param;
	sceMsgDialogParamInit(&param);
	param.mode = SCE_MSG_DIALOG_MODE_USER_MSG;
	param.userMsgParam = &msg_param;
	sceMsgDialogInit(&param);
	while (sceMsgDialogGetStatus() != SCE_COMMON_DIALOG_STATUS_FINISHED) {
		vglSwapBuffers(GL_TRUE);
	}
	sceKernelExitProcess(0);
}
#endif

#include "SDL.h"

#ifdef main
#undef main
#else
#define SDL_main main
#endif

[[noreturn]]
void D_DoomMain();

[[noreturn]]
void WGen_WadgenMain();

int myargc{};

char **myargv{};

namespace {
  auto &_gparams()
  {
      static std::map<StringView, app::Param *> params;
      return params;
  }

  auto &_params = _gparams();
#ifdef __vita__
  String _base_dir { "ux0:/data/Doom64EX/" };
  String _data_dir { "ux0:/data/Doom64EX/" };
#else
  String _base_dir { "./" };
  String _data_dir { "./" };
#endif
  StringView _program;

  Vector<String> _rest;

  app::StringParam _wadgen_param("wadgen");

  struct ParamsParser {
      using Arity = app::Param::Arity;
      app::Param *param{};

      void process(StringView arg)
      {
          if (arg[0] == '-') {
              arg.remove_prefix(1);
              auto it = _params.find(arg);
              if (it == _params.end()) {
                  println(stderr, "Unknown parameter -{}", arg);
              } else {
                  if (param) {
                      println("");
                  }
                  param = it->second;
                  param->set_have();
                  print("{:16s} = ", arg);
                  if (param->arity() == Arity::nullary) {
                      param = nullptr;
                      println(" true");
                  }
              }
          } else {
              if (!param) {
                  _rest.emplace_back(arg);
                  return;
              }

              param->add(arg);
              print(" {}", arg);
              if (param->arity() != Arity::nary) {
                  param = nullptr;
                  println("");
              }
          }
      }
  };
}

[[noreturn]]
void app::main(int argc, char **argv)
{
#ifdef __vita__
	// Checking for libshacccg.suprx existence
	SceIoStat st1, st2;
	if (!(sceIoGetstat("ur0:/data/libshacccg.suprx", &st1) >= 0 || sceIoGetstat("ur0:/data/external/libshacccg.suprx", &st2) >= 0))
		early_fatal_error("Error: Runtime shader compiler (libshacccg.suprx) is not installed.");

	scePowerSetArmClockFrequency(444);
	scePowerSetBusClockFrequency(222);
	scePowerSetGpuClockFrequency(222);
	scePowerSetGpuXbarClockFrequency(166);
	printf("Starting up vitaGL\n");
	vglUseCachedMem(GL_TRUE);
	vglInitExtended(0x200000, 960, 544, 0x1000000, SCE_GXM_MULTISAMPLE_4X);
#endif

    using Arity = app::Param::Arity;
    myargc = argc;
    myargv = argv;

    _program = argv[0];

#ifndef __vita__
    auto base_dir = SDL_GetBasePath();
    if (base_dir) {
        _base_dir = base_dir;
        SDL_free(base_dir);
    }
#else
	// Init Net
	sceSysmoduleLoadModule(SCE_SYSMODULE_NET);
	int ret = sceNetShowNetstat();
	SceNetInitParam initparam;
	if (ret == SCE_NET_ERROR_ENOTINIT) {
		initparam.memory = malloc(141 * 1024);
		initparam.size = 141 * 1024;
		initparam.flags = 0;
		sceNetInit(&initparam);
	}
#endif

    // Data files have to be in the cwd on Windows for compatibility reasons.
#ifndef _WIN32
    auto data_dir = SDL_GetPrefPath("", "doom64ex");
    if (data_dir) {
        _data_dir = data_dir;
        SDL_free(data_dir);
    }
#endif

    /* Process command-line arguments */
    println("Parameters:");
    ParamsParser parser;
    for (int i = 1; i < argc; ++i) {
        auto arg = argv[i];

        if (arg[0] == '@') {
            std::ifstream f(arg + 1);

            if (!f.is_open()) {
                // TODO: Print error
                continue;
            }

            while (!f.eof()) {
                String arg;
                f >> arg;
                parser.process(arg);
            }
        } else {
            parser.process(arg);
        }
    }
    if (parser.param && parser.param->arity() == Arity::nary)
        println("");

    /* Print rest params */
    if (!_rest.empty()) {
        print("{:16s} = ", "rest");
        for (const auto &s : _rest)
            print(" {}", s);
        println("");
    }

#ifndef _WIN32
    if (_wadgen_param) {
        WGen_WadgenMain();
    } else {
        D_DoomMain();
    }
#else
    D_DoomMain();
#endif
}

bool app::file_exists(StringView path)
{
	return std::ifstream(path.to_string()).is_open();
}

Optional<String> app::find_data_file(StringView name, StringView dir_hint)
{
    String path;

    if (!dir_hint.empty()) {
        path = format("{}{}", dir_hint, name);
        if (app::file_exists(path))
            return { inplace, path };
    }

    path = format("{}{}", _base_dir, name);
    if (app::file_exists(path))
        return { inplace, path };

    path = format("{}{}", _data_dir, name);
    if (app::file_exists(path))
        return { inplace, path };

#if defined(__LINUX__) || defined(__OpenBSD__)
    const char *paths[] = {
        "/usr/local/share/games/doom64ex/",
        "/usr/local/share/doom64ex/",
        "/usr/local/share/doom/",
        "/usr/share/games/doom64ex/",
        "/usr/share/doom64ex/",
        "/usr/share/doom/",
        "/opt/doom64ex/",
    };

    for (auto p : paths) {
        path = format("{}{}", p, name);
        if (app::file_exists(path))
            return { inplace, path };
    }
#endif

    return nullopt;
}

StringView app::program()
{
    return _program;
}

bool app::have_param(StringView name)
{
    return _params.count(name);
}

const app::Param *app::param(StringView name)
{
    auto it = _params.find(name);
    return it != _params.end() ? it->second : nullptr;
}

app::Param::Param(StringView name, app::Param::Arity arity) :
    arity_(arity)
{
    _gparams()[name] = this;
}

int SDL_main(int argc, char **argv)
{
    app::main(argc, argv);
}
