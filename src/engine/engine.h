#pragma once

namespace bng::engine {
	class Engine {
	public:
		Engine() = default;
		virtual ~Engine() = default;
		int foo() const;
	};
}