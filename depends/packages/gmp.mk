package=gmp
$(package)_version=6.1.2
# Prefer the GNU mirror; gmplib.org intermittently fails TLS from some hosts.
$(package)_download_path=https://ftp.gnu.org/gnu/gmp
$(package)_file_name=$(package)-$($(package)_version).tar.bz2
$(package)_sha256_hash=5275bb04f4863a13516b2f39392ac5e272f5e1bb8057b18aec1c9b79d73d8fb2
# GCC 15 defaults to C23 where void g() means no parameters; GMP's configure
# "long long reliability test" still used an unprototyped definition.
$(package)_patches=fix_c23_prototypes.patch

define $(package)_set_vars
$(package)_config_opts=--disable-shared
$(package)_config_opts_mingw32=--enable-mingw
$(package)_config_opts_linux=--with-pic
endef

define $(package)_preprocess_cmds
  patch -p1 < $($(package)_patch_dir)/fix_c23_prototypes.patch
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
