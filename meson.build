# project name and programming language
project('com.github.xendke.authentic', 'vala', 'c')

i18n = import('i18n')
gnome = import('gnome')

# Set our translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

# Tell meson where to find our resources file and to compile it as a GResource
styles = gnome.compile_resources(
    'styles',
    'data' / 'cssresource.xml',
    source_dir: 'data'
)

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    meson.project_name(),
    styles,
    'src' / 'Application.vala',
    'src' / 'Window' / 'MainWindow.vala',
    'src' / 'Dialogs' / 'NewAccountDialog.vala',
    'src' / 'Widgets' / 'AccountItem.vala',
    'src' / 'Widgets' / 'AccountWidget.vala',
    'src' / 'Widgets' / 'Spacer.vala',
    'src' / 'Services' / 'StyleManager.vala',
    'src' / 'Services' / 'TOTPTimer.vala',
    'src' / 'Services' / 'TOTPManager.vala',
    dependencies: [
        dependency('gtk+-3.0'),
        dependency('glib-2.0'),
        dependency('granite', version: '>=5.2.4'),
        meson.get_compiler('c').find_library('m', required: false),
    ],
    install: true
)

#Translate and install our .desktop file
i18n.merge_file(
    input: 'data' / 'authentic.desktop.in',
    output: meson.project_name() + '.desktop',
    po_dir: meson.source_root() / 'po',
    type: 'desktop',
    install: true,
    install_dir: get_option('datadir') / 'applications'
)

#Translate and install our .appdata file
i18n.merge_file(
    input: 'data' / 'authentic.appdata.xml.in',
    output: meson.project_name() + '.appdata.xml',
    po_dir: meson.source_root() / 'po',
    install: true,
    install_dir: get_option('datadir') / 'metainfo'
)

subdir('po')

# Install our icons in all the required sizes
icon_sizes = ['16', '24', '32', '48', '64', '128']

foreach i : icon_sizes
    install_data(
        'data' / 'icons' / i  + '.svg',
        install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i / 'apps',
        rename: meson.project_name() + '.svg'
    )
    install_data(
        'data' / 'icons' / i  + '.svg',
        install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i + '@2' / 'apps',
        rename: meson.project_name() + '.svg'
    )
endforeach
