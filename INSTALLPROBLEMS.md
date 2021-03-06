# Problems installing the pipeline?

This file contains a bunch of common pipeline installation problems and their solutions.

## Wrong Architecture Errors

If you get an error like this:

```
            % DRPBACKBONE::ERRORHANDLER: ERROR in drpBackbone::ErrorHandler - -379: CALL_EXTERNAL: Error loading sharable executable.
                Symbol: osiris_wait_on_sem_signal, File = ./modules/source/libosiris_drp_ext_null.so.0.0
                dlopen(./modules/source/libosiris_drp_ext_null.so.0.0, 1): no suitable image found.  
                Did find: ./modules/source/libosiris_drp_ext_null.so.0.0: mach-o, but wrong
                architecture

```

There is a mismatch between your compiled architectures somewhere between CFITSIO, IDL and ``libosiris`` (the compiled portion of the OSIRIS DRP). You can check the compiled architechture with ``lipo -info``, e.g. for ``libosiris``:

```
    $ lipo -info ./modules/source/libosiris_drp_ext_null.so.0.0
    Non-fat file: ./modules/source/libosiris_drp_ext_null.so.0.0 is architecture: x86_64
```

You should see an architecture like ``x86_64``. You should check the architecture of ``libosiris`` and ``cfitsio``. They need to match the architecture of IDL. You can find out your IDL architecture from within IDL with the following:

```
    IDL> print, !VERSION.arch
    x86_64
```

If you need to explicitly tell your compilier to target a specific architecutre, you might try the following copiler flags:

- For 32 bit systems, either ``-m32`` or ``-arch i386``
- For 64 bit systems, ``-arch x86_64``

