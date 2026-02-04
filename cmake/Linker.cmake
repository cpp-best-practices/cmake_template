macro(myproject_configure_linker project_name)
  set(myproject_USER_LINKER_OPTION
    "DEFAULT"
      CACHE STRING "Linker to be used")
    set(myproject_USER_LINKER_OPTION_VALUES "DEFAULT" "SYSTEM" "LLD" "GOLD" "BFD" "MOLD" "SOLD" "APPLE_CLASSIC" "MSVC")
  set_property(CACHE myproject_USER_LINKER_OPTION PROPERTY STRINGS ${myproject_USER_LINKER_OPTION_VALUES})
  list(
    FIND
    myproject_USER_LINKER_OPTION_VALUES
    ${myproject_USER_LINKER_OPTION}
    myproject_USER_LINKER_OPTION_INDEX)

  if(${myproject_USER_LINKER_OPTION_INDEX} EQUAL -1)
    message(
      STATUS
        "Using custom linker: '${myproject_USER_LINKER_OPTION}', explicitly supported entries are ${myproject_USER_LINKER_OPTION_VALUES}")
  endif()

  set_target_properties(${project_name} PROPERTIES LINKER_TYPE "${myproject_USER_LINKER_OPTION}")
endmacro()
