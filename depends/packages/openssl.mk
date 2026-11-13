package=openssl
# OpenSSL 3.0 LTS — required for Ubuntu 22.04+ system parity and modern depends builds.
$(package)_version=3.0.15
$(package)_download_path=https://github.com/openssl/openssl/releases/download/openssl-$($(package)_version)
$(package)_file_name=$(package)-$($(package)_version).tar.gz
$(package)_sha256_hash=23c666d0edf20f14249b3d8f0368acaee9ab585b09e1de82107c66e1f3ec9533

define $(package)_set_vars
$(package)_config_env=AR="$($(package)_ar)" RANLIB="$($(package)_ranlib)" CC="$($(package)_cc)"
$(package)_config_opts=--prefix=$(host_prefix) --openssldir=$(host_prefix)/etc/openssl --libdir=lib
$(package)_config_opts+=no-shared
$(package)_config_opts+=no-module
$(package)_config_opts+=no-dso
$(package)_config_opts+=no-comp
$(package)_config_opts+=no-legacy
$(package)_config_opts+=no-ssl3
$(package)_config_opts+=no-weak-ssl-ciphers
$(package)_config_opts+=no-tests
$(package)_config_opts+=no-ui-console
$(package)_config_opts+=no-afalgeng
$(package)_config_opts+=no-capieng
$(package)_config_opts+=no-padlockeng
$(package)_config_opts_linux=-fPIC -Wa,--noexecstack
$(package)_config_opts_x86_64_linux=linux-x86_64
$(package)_config_opts_i686_linux=linux-generic32
$(package)_config_opts_arm_linux=linux-generic32
$(package)_config_opts_armv7l_linux=linux-generic32
$(package)_config_opts_aarch64_linux=linux-aarch64
$(package)_config_opts_mipsel_linux=linux-generic32
$(package)_config_opts_mips_linux=linux-generic32
$(package)_config_opts_powerpc_linux=linux-generic32
$(package)_config_opts_powerpc64le_linux=linux-ppc64le
$(package)_config_opts_riscv32_linux=linux-generic32
$(package)_config_opts_riscv64_linux=linux-generic64
$(package)_config_opts_s390x_linux=linux64-s390x
$(package)_config_opts_x86_64_darwin=darwin64-x86_64-cc
$(package)_config_opts_x86_64_mingw32=mingw64
$(package)_config_opts_i686_mingw32=mingw
endef

define $(package)_config_cmds
  ./Configure $($(package)_config_opts)
endef

define $(package)_build_cmds
  $(MAKE) -j1 build_libs
endef

define $(package)_stage_cmds
  $(MAKE) DESTDIR=$($(package)_staging_dir) -j1 install_sw install_ssldirs
endef

define $(package)_postprocess_cmds
  rm -rf share bin etc
endef
