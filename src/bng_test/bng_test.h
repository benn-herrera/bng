// BNG Test Harness Header
// usage: in a cpp file under tests/ directory of a lib project add a source file
// e.g. tests/my_math.cpp
// #include "my_math_api.h"
// #include "bng_test/bng_test.h"
// BNG_TEST(foo_test, { // names can be reused (e.g. name all tests _) 
//		BT_CHECK(my_math_func_a(val) == expected0);
//		BT_CHECK(my_math_func_b(val) == expected1); 
//	});
// BNG_TEST(0foo, { // names can start with number or be simply numeric
//		BT_CHECK(my_math_func_c(val) == expected2);
//		BT_CHECK(my_math_func_d(val) == expected3); 
//	});
// tests are executed in file order
// entry point for test suite exe is in bng_test.h. just add tests and you're done.
// cmake system will automatically add target my_math_test to the test projects.
// each library has a run_<lib_name>_tests target that will execute all tests for it.
#pragma once

// * do not include anything but system utility headers in this file.
//   * include no utility code from any authored directory (e.g. core, platform, etc.)
//   * do not include stdlib C++ headers if you can possibly help it.
//   * this test harness cheap and simple. it's < 100 lines all in. let's keep it that way.
#include <stdio.h>
#include <assert.h>

namespace bng::test {
	class Test {
		using TestFunc = void(Test*);
	public:
		Test(const char* name, TestFunc* tf) 
			: run(tf), name(name) 
		{
			assert(run && name && *name);
			if (!first()) {
				first() = last() = this;
			} else {
				last()->next = this;
				last() = this;
			}
		}

		static int run_all(const char* suite_name) {
			assert(first());
			for (const char* sn = suite_name; *sn; ++sn) {
				if (*sn == '/' || *sn == '\\') { suite_name = sn + 1; }
			}

			printf("running suite %s\n", suite_name);
			int count = 0, failed = 0;
			for (auto t = first(); t; t = t->next) {
				++count;
				t->run(t);
				if (!t->errs) {
					printf("%s passed %d checks.\n", t->name, t->checks);
				}
				else {
					++failed;
					fprintf(stderr, "%s FAILED %d/%d checks.\n", t->name, t->errs, t->checks);
				}
			}

			if (!failed) {
				printf("%s passed %d tests.\n", suite_name, count);
				return 0;
			}
			fprintf(stderr,"%s FAILED %d/%d tests\n", suite_name, failed, count);
			return 1;
		}

	public:
		int checks = 0, errs = 0;

	private:
		static Test*& first() { static Test* t = nullptr; return t; }
		static Test*& last() { static Test* t = nullptr; return t; }
		Test* next = nullptr;
		TestFunc* run = nullptr;
		const char* name = nullptr;
	};
	#define BNG_TEST(N, BODY) \
		auto test_##N##__LINE__ = bng::test::Test(#N, [](bng::test::Test* _t_) BODY)
	#define BT_CHECK(V) do { \
		_t_->checks++; \
		if (!(V)) { \
			_t_->errs++; \
			fprintf(stderr, "%s(%d): CHECK " #V " FAILED!\n", __FILE__, __LINE__); } \
		} while(0)
} // namepsace bng::test

int main(int /*argc*/, const char** argv) {
	return bng::test::Test::run_all((argv && argv[0]) ? argv[0] : "test_suite");
}
