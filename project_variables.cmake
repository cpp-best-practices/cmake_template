set(PROJ_EXEC1 "intro")

#directories under src that will be added as subdirectories to the project
set(MY_PROJECT_SUBDIRECTORIES "ftxui_sample;sample_library")

set(DEFAULT_EXEC ${PROJ_EXEC1} CACHE STRING "Default executable to build")

#set(MY_PROJECT_TARGETS "${PROJ_EXEC1} ${SERVER_APP}")
set(MY_PROJECT_TARGETS "${PROJ_EXEC1}")

MESSAGE(STATUS "MY PROJECT TARGETS = ${MY_PROJECT_TARGETS}")
