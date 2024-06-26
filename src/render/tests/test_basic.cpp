#include "render.h"
#include "test_harness/test_harness.h"

using namespace bng::render;

BNG_TEST(test_a, {
	Render render;
	BT_CHECK(render.foo() == 3);
});

BNG_TEST(test_b, {
	Render render;
	BT_CHECK(true);
	BT_CHECK(render.foo() != 2);
});
