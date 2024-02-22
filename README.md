# Runtime for KallistiOS
Minimal Ada/SPARK run-time for [KallistiOS](https://github.com/KallistiOS/KallistiOS "KallistiOS").

This is very much Work-In-Progress (with the definition of Progress close to quasistatic progress).

This is based on the Alire [bare_runtime
crate](https://github.com/Fabien-Chouteau/bare_runtime). But all the Alire
support has been removed to avoid any confusion. sh-elf is not a supported
target, alire can't be used yet without various hacks (I initially followed this
route, but figured it would be easier to skip Alire, at least for the moment).

It is currently very minimal and may^Wprobably lacks some connection with the
underlying OS. In particular, the Last_Chance_Handler should be replaced by
corresponding OS exit.
