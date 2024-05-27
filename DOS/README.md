# Sprinter DOS source code

There is sources, mixed from original source codes and recovered by me from binary files of v1.62.100.

You can use [SjasmPlus](https://github.com/z00m128/sjasmplus) to compile this code.


`sjasmplus --fullpath "--raw=system.dos dos-main.asm`

[Sprinter computer site](https://sprinter.ru)

[Sprinter in Telegram](https://t.me/zx_sprinter)


## Original README

This is a source code of Sprinter DOS (called Estex Disk Sub System or Estex DSS) for 8-bit
computer PetersPlus Sprinter (Sp2000) that used Z80-compatible microprocessor running on 21 MHz
frequency and Altera PLD that performed all magic. To compile the code you need to use AS80.EXE
assembler for DOS (v1.31) included in this repo (referenced in A.BAT files as c:\asm\as80).

* [20000817.152][] -> DSS v1.52
* [20010208.152][] -> DSS v1.52
* [20010806.155][] -> DSS v1.55 ( [oldtree][] )
* [20021215.160][] -> DSS v1.60 RC
* [20030214.160][] -> DSS v1.60 R ( [tree][] )
* [20030423.170][] -> DSS v1.70 beta ( current )

[tree]:https://gitlab.com/sprinter-computer/dos/-/tree/v1.60R
[oldtree]:https://gitlab.com/sprinter-computer/dos/-/tree/v1.55
[20000817.152]:https://gitlab.com/sprinter-computer/dos/-/commit/06cf3fe3cd9141489941175c75f0df35623fc215
[20010208.152]:https://gitlab.com/sprinter-computer/dos/-/commit/d0d5a70d405effc3664e1d31f1b8854a8daaef50
[20010806.155]:https://gitlab.com/sprinter-computer/dos/-/commit/20586b76791ac1d9c2d0797911f8057419a916a2
[20021215.160]:https://gitlab.com/sprinter-computer/dos/-/commit/438f52ce179efb8d1fda2cb177818a7b201f6412
[20030214.160]:https://gitlab.com/sprinter-computer/dos/-/commit/f541c51c29289f22784c288df06c22299743235b
[20030423.170]:https://gitlab.com/sprinter-computer/dos/-/commit/0f7350186a6002d1774b20f516e1d7bdc5ab95b1

Tagged source code of the kernel v1.60R: https://gitlab.com/sprinter-computer/dos/-/tree/v1.60R

Binary release of v1.60R you can find in [release][] subdirectory of this repo.

[release]:https://gitlab.com/sprinter-computer/dos/-/tree/master/release

Estex DSS v1.60 R was last officially released binary distribution of Sprinter DOS
(released by Peters Plus Ltd in February 2003), but the source code was publicly released
to community only in 2009 (we believe it was done under PUBLIC DOMAIN terms).
Note: there is a community supported continuation of DSS v1.6X branch, disassembled by enthusiasts
before this public release happened, so for real work with modern reincarnations of Sprinter computer
you need to use other versions of the DOS. Purpose of this particular repo is just to store officially
released sources AS IS in browsable manner for historical and educational purposes.
Feel free to fork it if you want to do anything with it.

For more info see Sprinter Unofficial http://sprinter.nedopc.org

