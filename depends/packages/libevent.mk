package=libevent
$(package)_version=2.1.8-stable
$(package)_download_path=https://github.com/libevent/libevent/archive/
$(package)_file_name=release-$($(package)_version).tar.gz
$(package)_sha256_hash=316ddb401745ac5d222d7c529ef1eada12f58f6376a66c1118eee803cb70f83d
# glibc provides arc4random but not arc4random_addrandom; GCC 14+ errors on the
# resulting implicit declaration in evutil_rand.c (Ubuntu 24.10/26).
$(package)_patches=fix_arc4random_addrandom.patch

define $(package)_preprocess_cmds
  patch -p1 < $($(package)_patch_dir)/fix_arc4random_addrandom.patch && \
  ./autogen.sh
endef

define $(package)_set_vars
  $(package)_config_opts=--disable-shared --disable-openssl --disable-libevent-regress --disable-samples
  $(package)_config_opts_release=--disable-debug-mode
  $(package)_config_opts_linux=--with-pic
endef

define $(package)_config_cmds
  $($(package)_autoconf)
endef

define $(package)_build_cmds
  $(MAKE)
endef

define $(package)_stage_cmds
  $(MAKE) DESTDIR=$($(package)_staging_dir) install
endef

define $(package)_postprocess_cmds
endef
