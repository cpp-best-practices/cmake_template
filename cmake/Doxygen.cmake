# Documentation pipeline: Doxygen (XML) → Breathe → Sphinx (HTML)
#
# Doxygen parses C++ sources and generates XML.
# Breathe is a Sphinx extension that reads the Doxygen XML.
# Exhale auto-generates the API reference tree from Breathe.
# Sphinx renders the final HTML with the Read the Docs theme.
#
# Targets:
#   docs        - Full documentation (runs Doxygen then Sphinx)
#   doxygen-xml - Doxygen XML generation only

function(myproject_enable_doxygen)
  find_package(Doxygen OPTIONAL_COMPONENTS dot)
  if(NOT DOXYGEN_FOUND)
    message(${myproject_WARNING_TYPE} "Doxygen not found. Install from https://www.doxygen.nl/")
    return()
  endif()

  find_program(SPHINX_BUILD sphinx-build)
  if(NOT SPHINX_BUILD)
    message(${myproject_WARNING_TYPE} "sphinx-build not found. Install with: pip install -r docs/requirements.txt")
    return()
  endif()

  # Configure Doxygen to generate XML for Breathe (not HTML)
  set(DOXYGEN_GENERATE_HTML NO)
  set(DOXYGEN_GENERATE_XML YES)
  set(DOXYGEN_QUIET YES)
  set(DOXYGEN_RECURSIVE YES)
  set(DOXYGEN_EXTRACT_ALL YES)
  set(DOXYGEN_CALLER_GRAPH YES)
  set(DOXYGEN_CALL_GRAPH YES)
  set(DOXYGEN_DOT_IMAGE_FORMAT svg)
  set(DOXYGEN_DOT_TRANSPARENT YES)
  set(DOXYGEN_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/docs/doxygen")

  # Expand export macros so Breathe can parse the declarations
  set(DOXYGEN_ENABLE_PREPROCESSING YES)
  set(DOXYGEN_MACRO_EXPANSION YES)
  set(DOXYGEN_EXPAND_ONLY_PREDEF YES)
  set(DOXYGEN_PREDEFINED "SAMPLE_LIBRARY_EXPORT=")

  if(NOT DOXYGEN_EXCLUDE_PATTERNS)
    set(DOXYGEN_EXCLUDE_PATTERNS "${CMAKE_CURRENT_BINARY_DIR}/_deps/*")
  endif()

  # Only document project sources
  set(_doxygen_inputs
    "${PROJECT_SOURCE_DIR}/include"
    "${PROJECT_SOURCE_DIR}/src")

  doxygen_add_docs(doxygen-xml
    ${_doxygen_inputs}
    COMMENT "Generating Doxygen XML...")

  # Sphinx + Breathe + Exhale → HTML
  set(SPHINX_SOURCE_DIR "${PROJECT_SOURCE_DIR}/docs")
  set(SPHINX_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/docs/html")
  set(DOXYGEN_XML_DIR "${CMAKE_CURRENT_BINARY_DIR}/docs/doxygen/xml")

  add_custom_target(docs
    COMMAND ${CMAKE_COMMAND} -E env
      "DOXYGEN_XML_DIR=${DOXYGEN_XML_DIR}"
      "PROJECT_SOURCE_DIR=${PROJECT_SOURCE_DIR}"
      ${SPHINX_BUILD} -b html
      "${SPHINX_SOURCE_DIR}"
      "${SPHINX_OUTPUT_DIR}"
    DEPENDS doxygen-xml
    COMMENT "Generating documentation: ${SPHINX_OUTPUT_DIR}/index.html"
    VERBATIM)

  message(STATUS "Documentation targets: 'docs' (Sphinx + Breathe), 'doxygen-xml' (Doxygen XML only)")
endfunction()
