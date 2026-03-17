import os

project = 'myproject'
copyright = ''
author = ''

extensions = [
    'breathe',
    'exhale',
]

# -- Breathe (Doxygen XML → Sphinx) -----------------------------------------

# CMake passes the XML path via environment variable; fall back to a
# conventional location so that standalone sphinx-build also works.
_doxygen_xml_dir = os.environ.get(
    'DOXYGEN_XML_DIR',
    os.path.join(os.path.dirname(__file__), '..', 'build', 'docs', 'doxygen', 'xml'))

breathe_projects = {'myproject': _doxygen_xml_dir}
breathe_default_project = 'myproject'

# -- Exhale (auto-generate API tree from Breathe) ---------------------------

_project_source_dir = os.environ.get(
    'PROJECT_SOURCE_DIR',
    os.path.join(os.path.dirname(__file__), '..'))

exhale_args = {
    'containmentFolder': './api',
    'rootFileName': 'library_root.rst',
    'rootFileTitle': 'API Reference',
    'doxygenStripFromPath': _project_source_dir,
    'createTreeView': True,
}

# -- Theme -------------------------------------------------------------------

html_theme = 'sphinx_rtd_theme'
