#pragma once

// do not include anything but system utility headers.
// include nothing from any authored directory (e.g. core, platform, etc.)
#include <stdio.h>
#include <assert.h>

namespace bng::test {
	class Test {
		using TestFunc = void(Test*);

	public:
		Test(const char* name, TestFunc* tf) 
			: run(tf), name(name) 
		{
			assert(run && name);
			if (!first()) {
				first() = last() = this;
			} else {
				last()->next = this;
				last() = this;
			}
		}

		static int runAll(const char* suiteName) {
			int count = 0;
			int failed = 0;
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
				printf("%s passed %d tests.", suiteName, count);
				return 0;
			}
			fprintf(stderr,"%s FAILED %d/%d tests", suiteName, failed, count);
			return 1;
		}

	public:
		int checks = 0;
		int errs = 0;

	private:
		static Test*& first() { static Test* t = nullptr; return t; }
		static Test*& last() { static Test* t = nullptr; return t; }
		Test* next = nullptr;
		TestFunc* run = nullptr;
		const char* name;
	};
	#define BNG_TEST(N, BODY) auto N = bng::test::Test(#N, [](bng::test::Test* _t_) BODY)
	#define BT_CHECK(V) do { \
		_t_->checks++; \
		if (!(V)) { \
			_t_->errs++; \
			fprintf(stderr, "CHECK FAILED: %s\n", #V); } \
		} while(0)
} // namepsace bng::test

// test suite entry point.
int main(int argc, const char** argv) {
	(void)argc;
	return bng::test::Test::runAll((argv && argv[0]) ? argv[0] : "test_suite");
}
