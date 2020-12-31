# Type 2 AppImage runtime

This repository holds the code of the AppImage runtime, specifically the AppImage type 2 runtime. It is written in C.


## Building

__NOTE:__ The project supplies [binaries](releases/tag/continuous) that application developers can use. These binaries are built in Docker containers on GitHub actions.

Our build system is based on Docker. To build your own binaries, please install Docker first. Then, follow the following steps:

```
git clone --recursive https://github.com/AppImageX/type2-runtime.c
cd type2-runtime.c/
bash ci/build.sh
```

This will create the binaries in a directory called `out/`.
