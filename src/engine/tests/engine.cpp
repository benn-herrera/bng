#include "engine.h"
#include "bng_test/bng_test.h"

using namespace bng::engine;

BNG_TEST(test_1, {
	Engine engine;
	BT_CHECK(engine.foo() == 1);
});

BNG_TEST(test_2, {
	Engine engine;
	BT_CHECK(true);
	BT_CHECK(engine.foo() != 2);
});
