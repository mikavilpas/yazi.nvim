project('hycov', 'cpp',
  version: '0.1',
  default_options: ['buildtype=release'],
)

cpp_compiler = meson.get_compiler('cpp')
if cpp_compiler.has_argument('-std=c++23')
  add_global_arguments('-std=c++23', language: 'cpp')
elif cpp_compiler.has_argument('-std=c++2b')
  add_global_arguments('-std=c++2b', language: 'cpp')
else
  error('Could not configure current C++ compiler (' + cpp_compiler.get_id() + ' ' + cpp_compiler.version() + ') with required C++ standard (C++23)')
endif

add_project_arguments(
  [
    '-DWLR_USE_UNSTABLE', 
    '-g', '-Wall', '-Wextra', '-Wno-unused-parameter',
    '-Wno-unused-value', '-Wno-missing-field-initializers',
    '-Wno-narrowing', '-Wno-pointer-arith',
  ],
  language: 'cpp')

src = [
  'src/main.cpp',
  'src/dispatchers.cpp',
  'src/GridLayout.cpp',
  'src/globaleventhook.cpp',
]

shared_module(meson.project_name(), src,
  dependencies: [
    dependency('hyprland'),
    dependency('pixman-1'),
    dependency('libdrm'),
    dependency('pango'),
    dependency('pangocairo')
  ],
  install: true,
)
