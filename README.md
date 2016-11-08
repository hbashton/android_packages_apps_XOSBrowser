# XOS BROWSER Build Scripts

1. Setup build environment as it is described [here](https://www.codeaurora.org/xwiki/bin/Chromium+for+Snapdragon/Setup)
2. Clone this repo to the directory you want to build
3. Change *LogsDir* in **./build/run.sh** if necessary
4. Make sure that you're in the dir where to build
5. To get ready to build, run  **./build/init.sh**   (hint: use *--unsupported* parameter for forcible install) 
   5a. In case of non-Ubuntu please check with [official packages manual](https://chromium.googlesource.com/chromium/src/+/master/docs/linux_build_instructions_prerequisites.md)
6. To build run **./build/make.sh**
7. Result is in **src/out/Default/apks**

Credits go to:
- [Chromium.org](https://www.chromium.org/);
- *CodeAurora* for their [code](https://codeaurora.org/cgit/quic/chrome4sdp/chromium/src);

And please check out the [halogenOS Github](https://github.com/halogenOS)
