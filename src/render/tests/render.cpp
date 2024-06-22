#include "render.h"
#include "bng_test/bng_test.h"

using namespace bng::render;

BNG_TEST(test_1, {
	Render render;
	BT_CHECK(render.foo() == 3);
});

BNG_TEST(test_2, {
	Render render;
	BT_CHECK(true);
	BT_CHECK(render.foo() != 2);
});
