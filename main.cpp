#include <algorithm>
#include <chrono>
#include <cstddef>
#include <cstdint>
#include <ctime>
#include <iomanip>
#include <iostream>
#include <limits>
#include <optional>
#include <vector>

#include "itertools/combinations_with_replacement.hpp"
#include "itertools/permutations.hpp"

namespace
{

using candidate_t = std::uint8_t;
using mask_t = std::uint32_t;
using score_t = int;

struct election
{
	const candidate_t* data;
	std::size_t c;
	std::size_t v;
};

enum tie_variant: bool { TE, TP };
enum winner_model: bool { NUW, UW };

struct cc_pc_subtype
{
	tie_variant tv;
	winner_model wm;
};

constexpr std::size_t factorial(std::size_t n)
{
    std::size_t r = 1;

    for (std::size_t i = 2; i <= n; ++i)
        r *= i;

    return r;
}

template<class T, class U>
constexpr bool bit_test(T x, U b)
{
	return x & (T{ 1 } << b);
}

template<class T>
constexpr bool zero_or_power_of_two(T x)
{
	return !(x & (x - T{ 1 }));
}

mask_t veto(const election& e, mask_t cmask)
{
	if (!cmask)
		return 0;

	score_t tally[std::numeric_limits<mask_t>::digits] = {};

	for (std::size_t i = 0; i < e.v; ++i)
	{
		for (std::size_t j = e.c - 1u; ; --j)
		{
			const candidate_t x = e.data[i * e.c + j];

			if (bit_test(cmask, x))
			{
				++tally[x];
				break;
			}
		}
	}

	score_t min = std::numeric_limits<score_t>::max();

	mask_t wmask = 0;
	mask_t pos = 1;

	for (std::size_t i = 0; i < e.c; ++i)
	{
		if (cmask & pos)
		{
			if (tally[i] < min)
			{
				wmask = pos;
				min = tally[i];
			}
			else if (tally[i] == min)
			{
				wmask |= pos;
			}
		}

		pos <<= 1;
	}

	return wmask;
}

mask_t pc(tie_variant tv, const election& e, mask_t c1, mask_t c2)
{
	mask_t w = veto(e, c1);

	if (tv == TE && !zero_or_power_of_two(w))
		w = 0;

	return veto(e, w | c2);
}

bool cc_pc_contains(cc_pc_subtype t, const election& e, mask_t pmask)
{
	const mask_t mask = (mask_t{ 1 } << e.c) - 1u;
	mask_t partition = mask;

	do
	{
		const mask_t s1 = partition;
		const mask_t s2 = ~partition & mask;

		const mask_t w = pc(t.tv, e, s1, s2);

		if (t.wm == UW && !zero_or_power_of_two(w))
			continue;

		if (w & pmask)
			return true;

	} while (partition--);

	return false;
}

std::optional<std::vector<candidate_t>> search(
	std::size_t c,
	std::size_t v,
	cc_pc_subtype t1,
	cc_pc_subtype t2,
	bool (*predicate)(bool, bool))
{
	using itertools::combinations_with_replacement;
	using itertools::permutations;

	std::vector<candidate_t> pool;
	std::vector<candidate_t> e(c * v);

	const election election = { e.data(), c, v };

	for (const auto vote : permutations(static_cast<candidate_t>(c)))
		pool.insert(pool.end(), vote, vote + c);

	for (const auto indices : combinations_with_replacement(factorial(c), v))
	{
		for (std::size_t i = 0; i < v; ++i)
			std::copy_n(pool.data() + indices[i] * c, c, e.data() + i * c);

		const bool r1 = cc_pc_contains(t1, election, 1u);
		const bool r2 = cc_pc_contains(t2, election, 1u);

		if (predicate(r1, r2))
			return e;
	}

	return std::nullopt;
}

}	// namespace

int main()
{
	using steady_clock = std::chrono::steady_clock;
	using system_clock = std::chrono::system_clock;
	using duration = std::chrono::duration<double>;

	constexpr const char* version = "2022-07-19T20:00:00Z";

	constexpr std::size_t c = 4;
	constexpr std::size_t v = 10;

	constexpr auto nsupseteq = [](bool l, bool r) { return !l && r; };

	const std::time_t time = system_clock::to_time_t(system_clock::now());

	const auto begin = steady_clock::now();
	const auto witness = search(c, v, { TE, NUW }, { TP, UW }, nsupseteq);
	const auto end = steady_clock::now();

	std::cout << "{\n";

	if (witness)
	{
		std::cout << "\t\"C\": " << c << ",\n\t\"V\": [";

		for (std::size_t i = 0; i < v; ++i)
		{
			std::cout << (i ? ",\n\t\t[" : "\n\t\t[");

			for (std::size_t j = 0; j < c; ++j)
			{
				std::cout
					<< (j ? ", \"" : "\"")
					<< static_cast<char>('a' + (*witness)[i * c + j])
					<< '"';
			}

			std::cout << ']';
		}

		std::cout << "\n\t],\n";
	}

	std::cout << "\t\"version\": \"" << version << "\",\n";

	std::cout
		<< "\t\"date\": \""
		<< std::put_time(std::gmtime(&time), "%FT%TZ")
		<< "\",\n";

	std::cout
		<< "\t\"elapsedTime\": "
		<< std::chrono::duration_cast<duration>(end - begin).count()
		<< "\n";

	std::cout << "}\n";

	return 0;
}
