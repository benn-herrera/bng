if(NOT THIRD_PARTY_DIR)
	message(FATAL_ERROR "set THIRD_PARTY_DIR before including")
endif()

function(AddHeaderLib NAME REPO VERSION)
	set(VERSION_FILE "${THIRD_PARTY_DIR}/${NAME}/.bng_3p_version")
	if (EXISTS "${VERSION_FILE}")
		file(READ "${VERSION_FILE}" CUR_VERSION)
	endif()
	if (NOT CUR_VERSION STREQUAL VERSION)
		file(REMOVE_RECURSE "${THIRD_PARTY_DIR}/${NAME}")
		Git("${THIRD_PARTY_DIR}" clone "${REPO}" -c advice.detachedHead=false --depth 1 --branch "${VERSION}" "${NAME}")
		file(WRITE "${VERSION_FILE}" "${VERSION}")
	endif()
endfunction()
